# frozen_string_literal: true

require "test_helper"
require "securerandom"

describe "FilesTest" do
  delegate(
    :append,
    :write,
    :replace_first_line,
    :inject_line_before,
    :inject_line_after,
    :inject_line_after_last,
    to: "ViteRuby::CLI::FileUtils",
  )

  def root
    @root ||= Pathname.new(Dir.pwd).join("tmp", SecureRandom.uuid).tap(&:mkpath)
  end

  def teardown
    FileUtils.remove_entry_secure(root)
  end

  def assert_content(path, content)
    expect(content).to_include(path.read)
  end

  test "fresh installation" do
    app_root = root.join("test_fresh_install").tap(&:mkpath)
    Dir.chdir(app_root) { `bundle exec vite install` }

    expect(app_root.join("vite.config.ts")).to_be(:exist?)
    expect(app_root.join("package.json")).to_be(:exist?)
    expect(JSON.parse(app_root.join("package.json").read)["type"]) == "module"
  end

  test "write" do
    path = root.join("write")
    write(path, "Hello\nWorld")

    expect(path).to_be(:exist?)
    assert_content path, "Hello\nWorld"
  end

  test "append" do
    path = root.join("append.rb")
    content = <<~CONTENT
      class Append
      end
    CONTENT

    write(path, content)
    append(path, "\nFoo.register Append")

    assert_content path, <<~CONTENT
      class Append
      end

      Foo.register Append
    CONTENT
  end

  test "replace first line" do
    path = root.join("replace_string.rb")
    content = <<~CONTENT
      class Replace
        def self.perform
        end
      end
    CONTENT

    write(path, content)
    replace_first_line(path, "perform", "  def self.call(input)")

    assert_content path, <<~CONTENT
      class Replace
        def self.call(input)
        end
      end
    CONTENT
  end

  test "injects line before" do
    path = root.join("inject_before_string.rb")
    content = <<~CONTENT
      class InjectBefore
        def self.call
        end
      end
    CONTENT

    write(path, content)
    inject_line_before(path, "call", "  # It performs the operation")

    assert_content path, <<~CONTENT
      class InjectBefore
        # It performs the operation
        def self.call
        end
      end
    CONTENT
  end

  test "injects line after" do
    path = root.join("inject_after.rb")
    content = <<~CONTENT
      class InjectAfter
        def self.call
        end
      end
    CONTENT

    write(path, content)
    inject_line_after(path, "call", "    :result")

    assert_content path, <<~CONTENT
      class InjectAfter
        def self.call
          :result
        end
      end
    CONTENT
  end

  test "injects line after last" do
    path = root.join("inject_after_last.rb")
    content = <<~CONTENT
      class InjectAfter
        def self.call
        end
        def self.call
        end
      end
    CONTENT

    write(path, content)
    inject_line_after_last(path, "call", "    :result")

    assert_content path, <<~CONTENT
      class InjectAfter
        def self.call
        end
        def self.call
          :result
        end
      end
    CONTENT
  end
end
