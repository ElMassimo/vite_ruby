# frozen_string_literal: true

require "spec_helper"
require "securerandom"

RSpec.describe "ViteRuby::CLI::FileUtils" do
  delegate(
    :append,
    :write,
    :replace_first_line,
    :inject_line_before,
    :inject_line_after,
    :inject_line_after_last,
    to: "ViteRuby::CLI::FileUtils",
  )

  let(:root) { Pathname.new(Dir.pwd).join("tmp", SecureRandom.uuid).tap(&:mkpath) }

  after do
    FileUtils.remove_entry_secure(root)
  end

  it "fresh_installation" do
    app_root = root.join("test_fresh_install").tap(&:mkpath)
    Dir.chdir(app_root) {
      `bundle exec vite install`
    }

    expect(app_root.join("vite.config.ts")).to exist
    expect(app_root.join("package.json")).to exist
    expect(JSON.parse(app_root.join("package.json").read)["type"]).to eq("module")
  end

  it "write" do
    path = root.join("write")
    write(path, "Hello\nWorld")

    expect(path).to exist
    expect_content path, "Hello\nWorld"
  end

  it "append" do
    path = root.join("append.rb")
    content = <<~CONTENT
      class Append
      end
    CONTENT

    write(path, content)
    append(path, "\nFoo.register Append")

    expect_content path, <<~CONTENT
      class Append
      end

      Foo.register Append
    CONTENT
  end

  it "replace_first_line" do
    path = root.join("replace_string.rb")
    content = <<~CONTENT
      class Replace
        def self.perform
        end
      end
    CONTENT

    write(path, content)
    replace_first_line(path, "perform", "  def self.call(input)")

    expect_content path, <<~CONTENT
      class Replace
        def self.call(input)
        end
      end
    CONTENT
  end

  it "injects_line_before" do
    path = root.join("inject_before_string.rb")
    content = <<~CONTENT
      class InjectBefore
        def self.call
        end
      end
    CONTENT

    write(path, content)
    inject_line_before(path, "call", "  # It performs the operation")

    expect_content path, <<~CONTENT
      class InjectBefore
        # It performs the operation
        def self.call
        end
      end
    CONTENT
  end

  it "injects_line_after" do
    path = root.join("inject_after.rb")
    content = <<~CONTENT
      class InjectAfter
        def self.call
        end
      end
    CONTENT

    write(path, content)
    inject_line_after(path, "call", "    :result")

    expect_content path, <<~CONTENT
      class InjectAfter
        def self.call
          :result
        end
      end
    CONTENT
  end

  it "injects_line_after_last" do
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

    expect_content path, <<~CONTENT
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

  def expect_content(path, content)
    expect(content).to include(path.read)
  end
end
