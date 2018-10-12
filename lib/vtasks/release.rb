module Vtasks
  require 'rake/tasklib'

  # Release tasks
  class Release < ::Rake::TaskLib
    # Include utility modules
    require 'vtasks/utils/git'
    include Vtasks::Utils::Git
    require 'vtasks/utils/output'
    include Vtasks::Utils::Output
    require 'vtasks/utils/semver'
    include Vtasks::Utils::Semver

    attr_reader :write_changelog,
                :require_pull_request,
                :wait_for_ci_success,
                :bug_labels,
                :enhancement_labels

    def initialize(options = {})
      @write_changelog = options.fetch(:write_changelog, false)
      @require_pull_request = options.fetch(:require_pull_request, false)
      @wait_for_ci_success = options.fetch(:wait_for_ci_success, false)
      @bug_labels = options.fetch(:bug_labels, 'bug')
      @enhancement_labels = options.fetch(:enhancement_labels, 'enhancement')
      define_tasks
    end

    # Configure the github_changelog_generator/task
    def changelog(config, release: nil)
      config.bug_labels         = bug_labels #'Type: Bug'
      config.enhancement_labels = enhancement_labels #'Type: Enhancement'
      config.future_release     = "v#{release}" if release
    end

    def define_tasks
      desc "Release patch version"
      task release: ['release:patch']

      namespace :release do
        begin
          require 'github_changelog_generator/task'

          # Create release:changes task
          ::GitHubChangelogGenerator::RakeTask.new(:changes) do |config|
              changelog(config)
          end
        rescue LoadError
          nil # Might be in a group that is not installed
        end

        SEM_LEVELS.each do |level|
          desc "Release #{level} version"
          task level.to_sym do
            new_version = bump(level)
            release = "#{new_version[:major]}.#{new_version[:minor]}.#{new_version[:patch]}"
            initial_branch = git_branch

            if require_pull_request == true
              release_branch = "release_v#{release.gsub(/[^0-9A-Za-z]/, '_')}"
            else
              release_branch = initial_branch
            end

            info 'Check if the repository is clean'
            git_clean_repo

            # Write changelog
            # Create a separate release branch (works with  protected branches as well)
            if write_changelog == true
              info 'Generate new changelog'
              ::GitHubChangelogGenerator::RakeTask.new(:latest_release) do |config|
                changelog(config, release: release)
              end
              task('latest_release').invoke

              if system 'git diff --quiet HEAD'
                info 'CHANGELOG has not changed. Skipping...'
              else
                if require_pull_request == true
                  info 'Create a new release branch'
                  sh "git checkout -b #{release_branch}"
                end

                info 'Commit the new changes'
                sh "git commit --gpg-sign --message 'Update change log for v#{release}' CHANGELOG.md"

                if wait_for_ci_success == true
                  info 'Waiting for CI to finish'
                  sleep 5 until git_ci_status(release_branch) == 'success'
                end

                if require_pull_request == true
                  info 'Merge release branch'
                  sh "git checkout #{initial_branch}"
                  sh "git merge --gpg-sign --no-ff --message 'Release v#{release}' #{release_branch}"
                end
              end
            end

            info "Tag #{release}"
            sh "git tag --sign v#{release} --message 'Release v#{release}'"
            sh 'git push --follow-tags'
          end # task
        end # LEVELS
      end # namespace :release
    end # def define_tasks
  end # class Release
end # module Vtasks
