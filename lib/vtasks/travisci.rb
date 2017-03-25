module Vtasks
  require 'rake/tasklib'

  # Release tasks
  # Add the following gems to your Gemfile:
  #     gem 'dotenv', require: false
  #     gem 'travis', require: false
  class TravisCI < ::Rake::TaskLib
    # Include utility modules
    require 'vtasks/utils/output'
    include Vtasks::Utils::Output

    def initialize
      define_tasks
    end

    def define_tasks
      # Include libraries
      require 'dotenv'

      begin
        require 'travis/auto_login'
      rescue LoadError
        nil # Might be in a group that is not installed
      rescue Travis::Client::AutoLogin::NoTokenError
        warn 'No suitable github token found'
      end

      desc 'Sync environment with TravisCI'
      task :sync_travis_env do
        info "Hello #{::Travis::User.current.name}!"

        # Update environment variables
        dotenv.each do |key, value|
          info "Updating #{key}"
          env_vars.upsert(key, value, public: false)
        end

        # Remove remote environment variables
        env_vars.each do |var|
          unless dotenv.keys.include?(var.name)
            warn "Deleting #{var.name}"
            var.delete
          end
        end
      end
    end # def define_tasks

    def travis_slug
      @travis_slug ||= `git config --get travis.slug`.chomp
    end

    def env_vars
      @env_vars ||= ::Travis::Repository.find(travis_slug).env_vars
    end

    def dotenv
      @dotenv ||= ::Dotenv.load
    end
  end # class TravisCI
end # module Tasks
