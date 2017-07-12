module Vtasks
class Docker
# Docker Image class
class Image
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
    args = {
      build_date: build_date,
      build_tag: build_tag
    }
    build = Vtasks::Docker::Image::Build.new(image, path, args)
    if has_build_args
      build.with_arguments
    else
      build.without_arguments
    end
  end

  # Tag image
  def tag
    tags.each do |tag|
      Vtasks::Docker::Image::Tag.new(image, build_tag, tag)
    end
  end

  # Build image with tags
  def build_with_tags
    build
    tag
  end

  # Push image
  def push
    tags.each do |tag|
      Vtasks::Docker::Image::Push.new(image, tag)
    end
  end
end # class Image
end # class Docker
end # module Vtasks
