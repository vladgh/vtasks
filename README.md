# Vtasks
[![Build Status](https://travis-ci.org/vladgh/vtasks.svg?branch=master)](https://travis-ci.org/vladgh/vtasks)

Vlad's collection of Rake tasks

## Usage
See below for gem dependencies and add the required gems to the Gemfile:
```ruby
source ENV['GEM_SOURCE'] || 'https://rubygems.org'
gem 'vtasks', :git => 'https://github.com/vladgh/vtasks', require: false
gem 'example', require: false
```

And then execute:
```
$ bundle
```

Add the required tasks to the Rakefile:
```ruby
require 'vtasks/example'
Vtasks::Example.new
```

### Tasks

#### Docker

Required gems:
```
gem 'docker-api', require: false
gem 'rspec', require: false
gem 'serverspec', require: false
```

Usage:
```
require 'vtasks/docker'
Vtasks::Docker.new
```

Parameters:
- `:repo`: [String] the docker hub namespace
- `:has_build_args`: [Boolean] whether build arguments should be used

Tests (create a `spec/spec_helper.rb` file containing):
```
require 'vtasks/utils/docker_shared_context'

# Configura RSpec
::RSpec.configure do |config|
  config.formatter = :documentation
  config.color = true
  config.tty = true
end

# Longer build time out
::Docker.options[:read_timeout] = 7200
```

And then include the required shared context in your own tests:
```
include Vtasks::Utils::DockerSharedContext::Container
```

Available shared contexts:
- `Image`: builds an image
- `CleanUp`: kills all containers and deletes them
- `Container`: starts a container
- `RunningEntrypointContainer`: starts a container overriding the entrypoint with a continuous loop
- `RunningCommandContainer`: starts a container overriding the command with a continuous loop

#### Lint

Required gems:
```
gem 'reek', require: false
gem 'rubocop', require: false
gem 'rubycritic', require: false
```

Usage:
```
require 'vtasks/lint'
Vtasks::Lint.new
```
```
require 'vtasks/lint'
Vtasks::Lint.new(file_list:
                  FileList[
                  'lib/**/*.rb',
                  'spec/**/*.rb',
                  'Rakefile'
                ].exclude('spec/fixtures/**/*'))
```

Rubocop can be configured by using a `.rubocop.yml` file at the root of the project (https://github.com/bbatsov/rubocop). Ex.:
```
AllCops:
  Exclude:
    # Ignore HTML related things
    - '**/*.erb'
    # Ignore vendored gems
    - 'vendor/**/*'
    # Ignore code from test fixtures
    - 'spec/fixtures/**/*'
    # Ignore temporary code
    - 'tmp/**/*'
Metrics/LineLength:
  Enabled: false
```

#### Puppet

Required gems:
```
gem 'metadata-json-lint', require: false
gem 'puppet-lint', require: false
gem 'puppet-syntax', require: false
gem 'puppetlabs_spec_helper', require: false
gem 'rspec-puppet', require: false
gem 'rspec-puppet-facts', require: false
gem 'puppet_forge', require: false
gem 'puppet-strings', require: false
gem 'r10k', require: false
gem 'beaker', require: false
gem 'beaker-puppet_install_helper', require: false
gem 'beaker-rspec', require: false
```

Usage:
```
require 'vtasks/puppet'
Vtasks::Puppet.new
```
```
require 'vtasks/puppet'
Vtasks::Puppet.new
```

**_Note_: The `puppetlabs_spec_helper` gem clears the default `lint` task, so this needs to be called before all the lint tasks.**

#### Release

Required gems:
```
gem 'github_changelog_generator', require: false
```

Usage:
```
require 'vtasks/release'
Vtasks::Release.new
```
```
require 'vtasks/release'
Vtasks::Release.new(
  write_changelog: true,
  require_pull_request: true
  wait_for_ci_success: true,
  bug_labels: 'Type: Bug',
  enhancement_labels: 'Type: Enhancement'
)
```

Parameters:
- `write_changelog`: [Boolean] whether to write the changelog (defaults to `false`)
- `require_pull_request`: [Boolean] in case the branch is protected and a pull request is required, the task will create a separate branch on which it will commit the changelog, and merge that into master (defaults to `false`). .
- `wait_for_ci_success`: [Boolean] whether a "SUCCESS" CI status is required (defaults to `false`)
- `bug_labels`: [STRING] Issues with the specified labels will be added to "Fixed bugs" section (defaults to `bug`)
- `enhancement_labels`: [STRING] Issues with the specified labels will be added to "Implemented enhancements" section (defaults to `enhancement`)

Note:
First time you have to create an annotated tag and commit the initial CHANGELOG, before creating issues or pull requests (if there these are not present it will fail)
```
git tag --sign v0.0.0 --message 'Release v0.0.0' && git push --follow-tags
bundle exec rake release:changes
```

#### TravisCI

Required gems:
```
gem 'dotenv', require: false
gem 'travis', require: false
```

Usage:
```
require 'vtasks/travisci'
Vtasks::TravisCI.new
```

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contribute
See [CONTRIBUTING.md](CONTRIBUTING.md) file.

## License
Licensed under the Apache License, Version 2.0.
See [LICENSE](LICENSE) file.
