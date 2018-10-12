module Vtasks
module Utils
# DockerSharedContext module
module DockerSharedContext
  require 'rspec/core'

  begin
    require 'serverspec'
    require 'docker'
  rescue LoadError
    nil # Might be in a group that is not installed
  end

  # Docker image context
  module Image
    extend ::RSpec::Core::SharedContext

    before(:all) do
      @image = ::Docker::Image.build_from_dir(DOCKER_IMAGE_DIRECTORY)
      set :backend, :docker
    end
  end

  # Clean-up
  module CleanUp
    extend ::RSpec::Core::SharedContext

    after(:all) do
      @container.kill
      @container.delete(force: true)
    end
  end

  # Docker container context
  module Container
    extend ::RSpec::Core::SharedContext

    include Image

    before(:all) do
      @container = ::Docker::Container.create('Image' => @image.id)
      @container.start

      set :docker_container, @container.id
    end

    include CleanUp
  end

  # Docker always running container
  # Overwrite the entrypoint so that we can run the tests
  module RunningEntrypointContainer
    extend ::RSpec::Core::SharedContext

    include Image

    before(:all) do
      @container = ::Docker::Container.create(
        'Image' => @image.id,
        'Entrypoint' => ['sh', '-c', 'while true; do sleep 1; done']
      )
      @container.start

      set :docker_container, @container.id
    end

    include CleanUp
  end

  # Docker always running container
  # Overwrite the command so that we can run the tests
  module RunningCommandContainer
    extend ::RSpec::Core::SharedContext

    include Image

    before(:all) do
      @container = ::Docker::Container.create(
        'Image' => @image.id,
        'Cmd' => ['sh', '-c', 'while true; do sleep 1; done']
      )
      @container.start

      set :docker_container, @container.id
    end

    include CleanUp
  end
end # module DockerSharedContext
end # module Utils
end # module Vtasks
