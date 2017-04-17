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

    attr_reader :write_changelog, :ci_status

    def initialize(options = {})
      @write_changelog = options.fetch(:write_changelog, false)
      @ci_status = options.fetch(:ci_status, false)
      define_tasks
    end

    # Configure the github_changelog_generator/task
    def changelog(config, release: nil)
      config.bug_labels         = 'Type: Bug'
      config.enhancement_labels = 'Type: Enhancement'
      config.future_release     = "v#{release}" if release
    end

    def define_tasks
      namespace :release do
        begin
          require 'github_changelog_generator/task'
        rescue LoadError
          nil # Might be in a group that is not installed
        end

        # Create unreleased task
        ::GitHubChangelogGenerator::RakeTask.new(:unreleased) do |config|
            changelog(config)
        end

        SEM_LEVELS.each do |level|
          desc "Release #{level} version"
          task level.to_sym do
            new_version = bump(level)
            release = "#{new_version[:major]}.#{new_version[:minor]}.#{new_version[:patch]}"
            release_branch = "release_v#{release.gsub(/[^0-9A-Za-z]/, '_')}"
            initial_branch = git_branch

            # Create a release task
            ::GitHubChangelogGenerator::RakeTask.new(:latest_release) do |config|
              changelog(config, release: release)
            end

            info 'Check if the repository is clean'
            git_clean_repo

            if write_changelog == true
              info 'Create a new release branch'
              sh "git checkout -b #{release_branch}"

              info 'Generate new changelog'
              task('latest_release').invoke

              info 'Push the new changes'
              sh "git commit --gpg-sign --message 'Update change log for v#{release}' CHANGELOG.md"
              sh "git push --set-upstream origin #{release_branch}"

              if ci_status == true
                info 'Waiting for CI to finish'
                sleep 5 until git_ci_status(release_branch) == 'success'
              end

              info 'Merge release branch'
              sh "git checkout #{initial_branch}"
              sh "git merge --gpg-sign --no-ff --message 'Release v#{release}' #{release_branch}"
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
