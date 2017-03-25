module Vtasks
module Utils
  # Semver module
  module Semver
    SEM_LEVELS = [:major, :minor, :patch].freeze

    # Semantic version (from git tags)
    def gitver
      `git describe --always --tags 2>/dev/null || echo '0.0.0-0-0'`.chomp
    end

    # Create semantic version hash
    def semver
      @semver ||= begin
        {}.tap do |h|
          h[:major], h[:minor], h[:patch], h[:rev], h[:rev_hash] = gitver[1..-1].split(/[.-]/)
        end
      end
    end

    # Increment the version number
    def bump(level)
      new_version = semver.dup
      new_version[level] = new_version[level].to_i + 1
      to_zero = SEM_LEVELS[SEM_LEVELS.index(level) + 1..SEM_LEVELS.size]
      to_zero.each { |z| new_version[z] = 0 }
      new_version
    end
  end # module Version
end # module Utils
end # module Vtasks
