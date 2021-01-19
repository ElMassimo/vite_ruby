# frozen_string_literal: true

say 'Copying binstubs'
directory "#{ __dir__ }/bin", 'bin'

chmod 'bin', 0o755 & ~File.umask, verbose: false
