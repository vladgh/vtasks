module Vtasks
class Docker
class Image
# Docker Build class
class Build
  # Include utility modules
  require 'vtasks/utils/git'
  include Vtasks::Utils::Git
  require 'vtasks/utils/output'
  include Vtasks::Utils::Output

  attr_reader :image, :path, :build_date, :build_tag

  def initialize(image, path, args={})
    @image      ||= image
    @path       ||= path
    @build_date ||= args.fetch(:build_date)
    @build_tag  ||= args.fetch(:build_tag)

    @cmd = 'docker image build'
  end

  def without_arguments
    info "Pulling #{image}" # to speed up the building process
    system "docker pull #{image}" unless ENV['DOCKER_NO_CACHE']

    info "Building #{image}:#{build_tag}"
    system "#{@cmd} -t #{image}:#{build_tag} #{path}"

    if $?.exitstatus != 0
      error 'Build command failed!'
      abort
    end
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

end # class Build
end # class Image
end # class Docker
end # module Vtasks
