# frozen_string_literal: true

# Internal: Value object with information about the last build.
ViteRuby::Build = Struct.new(:success, :timestamp, :digest, :current_digest) do
  # Internal: Combines information from a previous build with the current digest.
  def self.from_previous(attrs, current_digest)
    new(attrs['success'], attrs['timestamp'] || 'never', attrs['digest'] || 'none', current_digest)
  end

  # Internal: Returns true if watched files have changed since the last build.
  def stale?
    digest != current_digest
  end

  # Internal: Returns true if watched files have not changed since the last build.
  def fresh?
    !stale?
  end

  # Internal: Returns a new build with the specified result.
  def with_result(success)
    self.class.new(success, Time.now.strftime('%F %T'), current_digest)
  end

  # Internal: Returns a JSON string with the metadata of the build.
  def to_json(*_args)
    JSON.pretty_generate(to_h)
  end
end
