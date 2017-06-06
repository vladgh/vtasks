require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

# Create a test task
task :test => :spec

# Separate bundler gems
namespace :bundler do
  require "bundler/gem_tasks"
end

# Release tasks
require 'vtasks/release'
Vtasks::Release.new(
  write_changelog: true,
  bug_labels: 'Type: Bug',
  enhancement_labels: 'Type: Enhancement'
)

# lint tasks
require 'vtasks/lint'
Vtasks::Lint.new

# Display version
desc 'Display version'
task :version do
  require 'vtasks/version'
  include Vtasks::Utils::Semver
  puts "Current version: #{gitver}"
end

# Create a list of contributors from GitHub
desc 'Populate CONTRIBUTORS file'
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end

task :default do
  system 'rake -T'
end
