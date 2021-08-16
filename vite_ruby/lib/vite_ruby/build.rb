# frozen_string_literal: true

require 'time'

# Internal: Value object with information about the last build.
ViteRuby::Build = Struct.new(:success, :timestamp, :vite_ruby, :digest, :current_digest) do
  # Internal: Combines information from a previous build with the current digest.
  def self.from_previous(attrs, current_digest)
    new(
      attrs['success'],
      attrs['timestamp'] || 'never',
      attrs['vite_ruby'] || 'unknown',
      attrs['digest'] || 'none',
      current_digest,
    )
  end

  # Internal: A build is considered stale when watched files have changed since
  # the last build, or when a certain time has ellapsed in case of failure.
  def stale?
    digest != current_digest || retry_failed? || vite_ruby != ViteRuby::VERSION
  end

  # Internal: A build is considered fresh if watched files have not changed, or
  # the last failed build happened recently.
  def fresh?
    !stale?
  end

  # Internal: To avoid cascading build failures, if the last build failed and it
  # happened within a short time window, a new build should not be triggered.
  def retry_failed?
    !success && Time.parse(timestamp) + 3 < Time.now # 3 seconds
  rescue ArgumentError
    true
  end

  # Internal: Returns a new build with the specified result.
  def with_result(success)
    self.class.new(
      success,
      Time.now.strftime('%F %T'),
      ViteRuby::VERSION,
      current_digest,
    )
  end

  # Internal: Returns a JSON string with the metadata of the build.
  def to_json(*_args)
    JSON.pretty_generate(to_h)
  end
end
