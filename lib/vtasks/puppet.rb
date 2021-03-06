module Vtasks
  require 'rake/tasklib'

  # Puppet tasks
  class Puppet < ::Rake::TaskLib
    # Include utility modules
    require 'vtasks/utils/git'
    include Vtasks::Utils::Git
    require 'vtasks/utils/output'
    include Vtasks::Utils::Output

    require 'json'
    require 'open-uri'
    require 'yaml'

    attr_reader :exclude_paths

    def initialize(options = {})
      # Fix for namespaced :syntax task
      task syntax: ['puppet:syntax']

      namespace :puppet do
        begin
          require 'r10k/cli'
          require 'r10k/puppetfile'
          require 'puppet_forge'
          require 'puppetlabs_spec_helper/rake_tasks' # ORDER IS VERY IMPORTANT BECAUSE IT OVERRIDES A LOT OF OTHER TASKS; AS OF NOW IT NEEDS TO BE AFTER `r10k` and `puppet_forge` (BECAUSE OF FAST_GETTEXT INITIALIZATION) BUT BEFORE puppet-strings (BECAUSE ERROR: `Don't know how to build task 'spec_prep'`)
          require 'metadata-json-lint/rake_task'
          require 'puppet-syntax/tasks/puppet-syntax'
          require 'puppet-lint/tasks/puppet-lint'
          require 'puppet-strings/tasks'
          require 'puppet_blacksmith/rake_tasks'
        rescue LoadError
          nil # Might be in a group that is not installed
        end

        @exclude_paths ||= options.fetch(
          :exclude_paths,
          [
            'bundle/**/*',
            'modules/**/*',
            'pkg/**/*',
            'spec/**/*',
            'tmp/**/*',
            'vendor/**/*'
          ]
        )

        define_tasks
      end # namespace :puppet
    end

    def define_tasks
      ::PuppetLint::RakeTask.new :lint do |config|
        config.relative = true
        config.with_context = true
        config.fail_on_warnings = true
        config.ignore_paths = exclude_paths
        config.disable_checks = [
          '140chars'
        ]
      end

      # Puppet syntax tasks
      ::PuppetSyntax.exclude_paths = exclude_paths

      desc 'Run syntax, lint, and spec tests'
      task test: [
        :metadata_lint,
        :syntax,
        :lint,
        :unit
      ]

      desc 'Run unit tests'
      task unit: [
        :r10k_install_modules,
        :spec_prep,
        :spec_standalone
      ]

      desc 'Run acceptance tests'
      task integration: [
        :spec_prep,
        :beaker
      ]

      desc 'Clean all test files'
      task clean: [:spec_clean]

      desc 'Use R10K to download all modules'
      task :r10k_install_modules do
        r10k_install_modules
      end

      desc 'Generates a new .fixtures.yml from a Puppetfile'
      task :generate_fixtures do
        generate_fixtures
      end

      desc 'Print outdated Puppetfile modules'
      task :puppetfile_inspect do
        check_puppetfile_versions
      end
    end # def define_tasks

    def puppetfile
      @puppetfile ||= ::R10K::Puppetfile.new(pwd)
    end

    def check_puppetfile
      puppetfile.load
      error 'Puppetfile was not found or is empty!' if puppetfile.modules.empty?
    end

    def r10k_install_modules
      info 'Updating modules with R10K'
      ::R10K::CLI.command.run(%w(puppetfile install --force --verbose))
    rescue SystemExit # because R10K::CLI.command.run calls `exit 0`
      info 'Modules have been updated'
    end

    def generate_fixtures
      info 'Generating fixtures file'

      check_puppetfile

      fixtures = {
        'fixtures' => {
          'symlinks' => {
            'role' => '#{source_dir}/dist/role',
            'profile' => '#{source_dir}/dist/profile'
          },
          'repositories' => {}
        }
      }

      puppetfile.modules.each do |mod|
        module_name = mod.title.tr('/', '-')
        remote      = mod.instance_variable_get('@remote')
        ref         = mod.instance_variable_get('@desired_ref')

        fixtures['fixtures']['repositories'][module_name] = {
          'repo' => remote,
          'ref' => ref
        }
      end

      File.open('.fixtures.yml', 'w') { |file| file.write(fixtures.to_yaml) }
      info 'Done'
    end # def generate_fixtures

    def check_puppetfile_versions
      puppetfile.load
      error 'Puppetfile was not found or is empty!' if puppetfile.modules.empty?

      puppetfile.modules.each do |mod|
        if mod.class == ::R10K::Module::Forge
          module_name = mod.title.tr('/', '-')
          forge_version = ::PuppetForge::Module.find(module_name)
                                               .current_release.version
          installed_version = mod.expected_version
          if installed_version != forge_version
            puts "#{module_name} is OUTDATED: " \
              "#{installed_version} vs #{forge_version} (#{::PuppetForge::Module.find(module_name).current_release.metadata[:project_page]})"
              .red
          else
            puts "#{module_name}: #{forge_version}".green
          end
        elsif mod.class == ::R10K::Module::Git
          # Try to extract owner and repo name from remote string
          remote = mod.instance_variable_get('@remote')
          owner  = remote.gsub(%r{(.*)\/(.*)\/(.*)}, '\\2')
          repo   = remote.gsub(%r{(.*)\/(.*)\/}, '\\3')

          # It's better to query the API authenticated because of the rate
          # limit. You can make up to 5,000 requests per hour. For unauthenticated
          # requests, the rate limit is only up to 60 requests per hour.
          # (https://developer.github.com/v3/#rate-limiting)
          tags = if GITHUB_TOKEN
                   open("https://api.github.com/repos/#{owner}/#{repo}/tags?access_token=#{GITHUB_TOKEN}")
                 else
                   open("https://api.github.com/repos/#{owner}/#{repo}/tags")
                 end

          # Get rid of non-semantic versions (for example
          # https://github.com/puppetlabs/puppetlabs-ntp/releases/tag/push)
          all_tags = JSON.parse(tags.read).select do |tag|
            tag['name'] =~ /v?\d+\.\d+\.\d+/
          end

          # Use Gem::Version to sort tags
          latest_tag = all_tags.map do |line|
            ::Gem::Version.new line['name'].gsub(/[v]?(.*)/, '\\1')
          end.max.to_s

          # Print results
          installed_version = mod.version.gsub(/[v]?(.*)/, '\\1')
          if installed_version == 'master'
            puts "#{mod.title}: 'master' branch (#{latest_tag}) - #{remote}".blue
          elsif installed_version != latest_tag
            puts "#{mod.title} is OUTDATED: " \
              "#{installed_version} vs #{latest_tag} (#{remote})"
              .red
          else
            puts "#{mod.title}: #{latest_tag}".green
          end
        end
      end
    end # def check_puppetfile_versions
  end # class Puppet
end # module Vtasks
