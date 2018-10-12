module Vtasks
module Utils
# Git module
module Git
  GITHUB_TOKEN = ENV['GITHUB_TOKEN']

  # Get git short commit hash
  def git_commit
    `git rev-parse --short HEAD`.strip
  end

  # Get the branch name
  def git_branch
    return ENV['GIT_BRANCH'] if ENV['GIT_BRANCH']
    return ENV['TRAVIS_BRANCH'] if ENV['TRAVIS_BRANCH']
    return ENV['CIRCLE_BRANCH'] if ENV['CIRCLE_BRANCH']
    `git symbolic-ref HEAD --short 2>/dev/null`.strip
  end

  # Get the URL of the origin remote
  def git_url
    `git config --get remote.origin.url`.strip
  end

  # Get the CI Status (needs https://hub.github.com/)
  def git_ci_status(branch = 'master')
    `hub ci-status #{branch}`.strip
  end

  # Check if the repo is clean
  def git_clean_repo
    # Check if there are uncommitted changes
    unless system 'git diff --quiet HEAD'
      abort('ERROR: Commit your changes first.')
    end

    # Check if there are untracked files
    unless `git ls-files --others --exclude-standard`.to_s.empty?
      abort('ERROR: There are untracked files.')
    end

    true
  end

  # Deepen repository history
  # In case there is a shallow clone (only the tip of the specified branch). This has the advantage of minimizing the amount of data transfer necessary from the repository and speeding up the build because it pulls only the minimal code necessary.
  # Because of this, if you need to perform a custom action that relies on a different branch, you won’t be able to checkout that branch, unless you do one of the following:
  #    $ git pull --depth=50
  #    $ git fetch --unshallow origin
  def git_deepen_repo
    git_dir = `git rev-parse --git-dir`.strip
    if File.file?("#{git_dir}/shallow")
      info 'Deepen repository history'
      sh "git fetch --unshallow origin"
    end
  end
end # module Git
end # module Utils
end # module Vtasks
