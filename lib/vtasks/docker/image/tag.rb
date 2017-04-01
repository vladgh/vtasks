module Vtasks
class Docker
class Image
# Docker Tag module
class Tag < Image
  def initialize(image, tag, newtag)
    info "Tagging #{image}:#{newtag}"
    system "docker image tag #{image}:#{tag} #{image}:#{newtag}"
  end
end # class Tag
end # class Image
end # class Docker
end # module Vtasks
