module Vtasks
  require 'vtasks/utils/semver'
  extend Vtasks::Utils::Semver
  VERSION = semver.values.compact.first(3).join('.')
end # module Vtasks
