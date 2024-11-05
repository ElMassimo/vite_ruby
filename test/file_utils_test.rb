# frozen_string_literal: true

require "test_helper"
require "securerandom"

class FilesTest < ViteRuby::Test
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

  def test_fresh_installation
    app_root = root.join("test_fresh_install").tap(&:mkpath)
    Dir.chdir(app_root) {
      `bundle exec vite install`
    }

    assert_path_exists app_root.join("vite.config.ts")
    assert_path_exists app_root.join("package.json")
    assert_equal "module", JSON.parse(app_root.join("package.json").read)["type"]
  end

  def test_write
    path = root.join("write")
    write(path, "Hello\nWorld")

    assert_predicate path, :exist?
    assert_content path, "Hello\nWorld"
  end

  def test_append
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

  def test_replace_first_line
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

  def test_injects_line_before
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

  def test_injects_line_after
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

  def test_injects_line_after_last
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

private

  def assert_content(path, content)
    assert_includes content, path.read
  end
end
