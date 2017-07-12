module Vtasks
  require 'rake/tasklib'

  # Docker tasks
  class Docker < ::Rake::TaskLib
    # Include utility modules
    require 'vtasks/utils/output'
    include Vtasks::Utils::Output
    require 'vtasks/utils/system'
    include Vtasks::Utils::System

    # Include utility classes
    require 'vtasks/docker/image'

    attr_reader :args, :repo

    def initialize(args = {})
      @args ||= args
      @repo ||= args.fetch(:repo)

      check_docker
      define_tasks
    end

    def define_tasks
      namespace :docker do
        list_images
        garbage_collect
        tasks

        dockerfiles.each do |dockerfile|
          path = File.basename(dockerfile)
          add_namespace("#{repo}/#{path}", path)
        end # dockerfiles.each
      end # namespace :docker
    end # def define_tasks

    # Image namespace
    def add_namespace(image, path)
      namespace path.to_sym do |_args|
        require 'rspec/core/rake_task'
        ::RSpec::Core::RakeTask.new(:spec) do |task|
          task.pattern = "#{path}/spec/*_spec.rb"
        end

        docker_image = Vtasks::Docker::Image.new(image, path, args)

        lint_image(path)

        desc 'Build and tag docker image'
        task :build do
          docker_image.build_with_tags
        end

        desc 'Publish docker image'
        task :push do
          docker_image.push
        end
      end
    end

    # Tasks
    def tasks
      # Run tasks one by one for all images
      [:spec, :lint].each { |task_name| run_task(task_name) }
      # Run tasks in parallel for all images
      [:build, :push].each { |task_name| run_task_parallel(task_name) }
    end

    # Run a task for all images
    def run_task(name)
      desc "Run #{name} for all images in repository"
      task name => dockerfiles
        .collect { |image| "docker:#{File.basename(image)}:#{name}" }
    end

    # Run a task for all images in parallel
    def run_task_parallel(name)
      desc "Run #{name} for all images in repository in parallel"
      multitask name => dockerfiles
        .collect { |image| "docker:#{File.basename(image)}:#{name}" }
    end

    # List all folders containing Dockerfiles
    def dockerfiles
      @dockerfiles = Dir.glob('*').select do |dir|
        File.directory?(dir) && File.exist?("#{dir}/Dockerfile")
      end
    end

    # Check Docker is installed
    def check_docker
      task :docker do
        raise 'These tasks require docker to be installed' unless command? 'docker'
      end
    end

    # List all images
    def list_images
      desc 'List all Docker images'
      task :list do
        info dockerfiles.map { |image| File.basename(image) }
      end
    end

    # Lint image
    def lint_image(path)
      desc 'Run Hadolint against the Dockerfile'
      task :lint do
        dockerfile = "#{path}/Dockerfile"
        info "Running Hadolint to check the style of #{dockerfile}"
        system "docker container run --rm -i lukasmartinelli/hadolint hadolint --ignore DL3008 --ignore DL3013 - < #{dockerfile}"
      end
    end

    # Garbage collect
    def garbage_collect
      desc 'Garbage collect unused docker data'
      task :gc do
        system 'docker system prune --all --force'
      end
    end
  end # class Docker
end # module Vtasks
