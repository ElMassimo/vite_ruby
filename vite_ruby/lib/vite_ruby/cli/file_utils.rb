# frozen_string_literal: true

require 'pathname'
require 'fileutils'

# NOTE: Extracted from dry-cli version 0.6.0, which later removed this file as
# it was refactored and extracted into the more complete (and complex) dry-files.
module ViteRuby::CLI::FileUtils
  class << self
    # Creates a new file or rewrites the contents of an existing file.
    #
    # @since 1.2.11
    # @api private
    def write(path, *content)
      mkdir_p(path)
      File.open(path, File::CREAT | File::WRONLY | File::TRUNC) do |file|
        file.write(Array(content).flatten.join)
      end
    end

    # Copies source into destination.
    #
    # @since 1.2.11
    # @api private
    def cp(source, destination)
      mkdir_p(destination)
      FileUtils.cp(source, destination)
    end

    # Adds a new line at the bottom of the file.
    #
    # @since 1.2.11
    # @api private
    def append(path, contents)
      mkdir_p(path)

      content = File.readlines(path)
      content << "\n" unless content.last.end_with?("\n")
      content << "#{ contents }\n"

      write(path, content)
    end

    # Replace first line in `path` that contains `target` with `replacement`.
    #
    # @since 1.2.11
    # @api private
    def replace_first_line(path, target, replacement)
      content = File.readlines(path)
      content[index(content, path, target)] = "#{ replacement }\n"

      write(path, content)
    end

    # Inject `contents` in `path` before `target`.
    #
    # @since 1.2.11
    # @api private
    def inject_line_before(path, target, contents)
      _inject_line_before(path, target, contents, method(:index))
    end

    # Inject `contents` in `path` after `target`.
    #
    # @since 1.2.11
    # @api private
    def inject_line_after(path, target, contents)
      _inject_line_after(path, target, contents, method(:index))
    end

    # Inject `contents` in `path` after last `target`.
    #
    # @since 1.2.11
    # @api private
    def inject_line_after_last(path, target, contents)
      _inject_line_after(path, target, contents, method(:rindex))
    end

  private

    # Creates all parent directories for the given file path.
    #
    # @since 1.2.11
    # @api private
    def mkdir_p(path)
      Pathname.new(path).dirname.mkpath
    end

    # @since 1.2.11
    # @api private
    def index(content, path, target)
      content.index { |line| line.include?(target) } ||
        raise(ArgumentError, "Cannot find `#{ target }' inside `#{ path }'.")
    end

    # @since 1.2.11
    # @api private
    def rindex(content, path, target)
      content.rindex { |line| line.include?(target) } ||
        raise(ArgumentError, "Cannot find `#{ target }' inside `#{ path }'.")
    end

    # @since 1.2.11
    # @api private
    def _inject_line_before(path, target, contents, finder)
      content = File.readlines(path)
      i = finder.call(content, path, target)

      content.insert(i, "#{ contents }\n")
      write(path, content)
    end

    # @since 1.2.11
    # @api private
    def _inject_line_after(path, target, contents, finder)
      content = File.readlines(path)
      i = finder.call(content, path, target)

      content.insert(i + 1, "#{ contents }\n")
      write(path, content)
    end
  end
end
