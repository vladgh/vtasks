module Vtasks
class Docker
class Image
# Docker Push class
class Push < Image
  def initialize(image, tag)
    info "Pushing #{image}:#{tag}"
    system "docker image push #{image}:#{tag}"
  end
end # class Push
end # class Image
end # class Docker
end # module Vtasks
