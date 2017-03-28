# Vtasks
[![Build Status](https://travis-ci.org/vladgh/vtasks.svg?branch=master)](https://travis-ci.org/vladgh/vtasks)

Vlad's collection of Rake tasks

## Usage
Consult each class for gem dependencies and add the required gems to the Gemfile:
```ruby
source ENV['GEM_SOURCE'] || 'https://rubygems.org'
gem 'vtasks', :git => 'https://github.com/vladgh/vtasks'
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
