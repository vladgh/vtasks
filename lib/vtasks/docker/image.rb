module Vtasks
class Docker
# Docker Image class
class Image < Docker
  # Include utility modules
  require 'vtasks/utils/git'
  include Vtasks::Utils::Git
  require 'vtasks/utils/semver'
  include Vtasks::Utils::Semver

  # Include utility classes
  require 'vtasks/docker/image/build'
  require 'vtasks/docker/image/push'
  require 'vtasks/docker/image/tag'

  attr_reader :image, :path, :has_build_args, :tags

  def initialize(image, path, args = {})
    @image          ||= image
    @path           ||= path
    @has_build_args ||= args.fetch(:has_build_args, false)
  end

  def tags
    major, minor, patch = [
      semver[:major],
      semver[:minor],
      semver[:patch]
    ].freeze
    @tags = [
      "#{major}.#{minor}.#{patch}",
      "#{major}.#{minor}",
      "#{major}",
      'latest'
    ]
  end

  # Compose build date
  def build_date
    @build_date ||= ::Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
  end

  # Compose build tag
  def build_tag
    @build_tag ||= gitver.to_s
  end

  # Build image
  def build
    build = Vtasks::Docker::Image::Build.new(image, path)
    if has_build_args
      build.with_arguments
    else
      build.without_arguments
    end
  end

  # Build image with tags
  def build_with_tags
    desc 'Build and tag docker image'
    task build: :docker do
      build
      tag
    end
  end

  # Build image without tags
  def build_without_tags
    desc 'Build and tag docker image'
    task build: :docker do
      build
    end
  end

  # Tag image
  def tag
    tags.each do |tag|
      Vtasks::Docker::Image::Tag.new(image, build_tag, tag)
    end
  end

  # Push image
  def push
    desc 'Publish docker image'
    task push: :docker do
      tags.each do |tag|
        Vtasks::Docker::Image::Push.new(image, tag)
      end
    end
  end

  # Lint image
  def lint
    desc 'Run Hadolint against the Dockerfile'
    task lint: :docker do
      dockerfile = "#{path}/Dockerfile"
      info "Running Hadolint to check the style of #{dockerfile}"
      system "docker container run --rm -i lukasmartinelli/hadolint hadolint --ignore DL3008 --ignore DL3013 - < #{dockerfile}"
    end
  end
end # class Image
end # class Docker
end # module Vtasks
