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
Vtasks::Puppet.new(exclude_paths: [
                    'bundle/**/*',
                    'modules/**/*',
                    'pkg/**/*',
                    'spec/**/*',
                    'tmp/**/*',
                    'vendor/**/*'
                  ])
```

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
  ci_status: true
)
```

Parameters:
- `write_changelog`: [Boolean] whether to write the changelog (defaults to `false`)
- `ci_status`: [Boolean] whether CI status is required (defaults to `false`)

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
Bug reports and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
1. Open an issue to discuss proposed changes
2. Fork the repository
3. Create your feature branch: `git checkout -b my-new-feature`
4. Commit your changes: `git commit -am 'Add some feature'`
5. Push to the branch: `git push origin my-new-feature`
6. Submit a pull request :D

## License
Licensed under the Apache License, Version 2.0.
