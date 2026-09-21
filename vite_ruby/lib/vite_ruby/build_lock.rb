# frozen_string_literal: true

# Internal: Synchronizes Vite builds and manifest reads across threads and processes.
class ViteRuby::BuildLock
  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
    @mutex = Mutex.new
  end

  def synchronize(mode)
    @mutex.synchronize do
      lock_path.dirname.mkpath
      lock_path.open(File::RDWR | File::CREAT, 0o644) do |lock|
        lock.flock(mode)
        yield
      end
    end
  end

private

  extend Forwardable

  def_delegator :@vite_ruby, :config

  # The lock is kept outside the build cache so clobbering the cache cannot
  # replace the locked file while another process is waiting on it.
  def lock_path
    Pathname.new("#{config.build_cache_dir}.lock")
  end
end
