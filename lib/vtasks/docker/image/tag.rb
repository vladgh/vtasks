module Vtasks
class Docker
class Image
# Docker Tag module
class Tag
  # Include utility modules
  require 'vtasks/utils/output'
  include Vtasks::Utils::Output

  def initialize(image, oldtag, newtag)
    info "Tagging #{image}:#{newtag}"
    system "docker image tag #{image}:#{oldtag} #{image}:#{newtag}"
  end
end # class Tag
end # class Image
end # class Docker
end # module Vtasks
