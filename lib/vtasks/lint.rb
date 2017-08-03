module Vtasks
  require 'rake/tasklib'

  # Lint tasks
  class Lint < ::Rake::TaskLib
    attr_reader :file_list

    def initialize(options = {})
      @file_list ||= options.fetch(:file_list, FileList['{lib,spec}/**/*.rb'])
      define_tasks
    end

    # Define tasks
    def define_tasks
      desc 'Check for code smells with Reek and Rubocop'
      task lint: ['lint:reek', 'lint:rubocop']

      namespace :lint do
        rubocop
        reek
        rubycritic
      end
    end

    # RuboCop
    def rubocop
      begin
        require 'rubocop/rake_task'
      rescue LoadError
        nil # Might be in a group that is not installed
      end
      desc 'Run RuboCop on the tasks and lib directory'
      ::RuboCop::RakeTask.new(:rubocop) do |task|
        task.patterns = file_list
        task.options  = ['--display-cop-names', '--extra-details']
      end
    end

    # Reek
    def reek
      begin
        require 'reek/rake/task'
      rescue LoadError
        nil # Might be in a group that is not installed
      end
      ::Reek::Rake::Task.new do |task|
        task.source_files  = file_list
        task.fail_on_error = false
        task.reek_opts     = '--wiki-links --color'
      end
    end

    # Ruby Critic
    def rubycritic
      begin
        require 'rubycritic/rake_task'
      rescue LoadError
        nil # Might be in a group that is not installed
      end
      ::RubyCritic::RakeTask.new do |task|
        task.paths = file_list
      end
    end
  end # class Lint
end # module Vtasks
