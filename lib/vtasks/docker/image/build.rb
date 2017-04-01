module Vtasks
class Docker
class Image
# Docker Build class
class Build < Image
  # Include utility modules
  require 'vtasks/utils/git'
  include Vtasks::Utils::Git

  attr_reader :image, :path

  def initialize(image, path)
    @image ||= image
    @path  ||= path

    @cmd = 'docker image build'
  end

  def with_arguments
    build_args = {
      'BUILD_DATE' => build_date,
      'VERSION'    => build_tag,
      'VCS_URL'    => git_url,
      'VCS_REF'    => git_commit
    }

    build_args.map do |key, value|
      @cmd += " --build-arg #{key}=#{value}"
    end

    without_arguments
  end

  def without_arguments
    info "Building #{image}:#{build_tag}"
    system "#{@cmd} -t #{image}:#{build_tag} #{path}"
  end
end # class Build
end # class Image
end # class Docker
end # module Vtasks
