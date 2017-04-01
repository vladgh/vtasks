# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vtasks/version'

Gem::Specification.new do |spec|
  spec.name          = 'vtasks'
  spec.version       = Vtasks::VERSION
  spec.authors       = ['Vlad Ghinea']
  spec.email         = ['vlad@ghn.me']

  spec.summary       = %q{Vlad's collection of Rake tasks}
  spec.description   = <<-DESCRIPTION
    Provides a general purpose toolset for Rake tasks.
  DESCRIPTION
  spec.homepage      = 'https://github.com/vladgh/vtasks'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = `git ls-files -z -- bin/*`.split("\x0").map do |f|
    File.basename(f)
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'rspec'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'github_changelog_generator'
  spec.add_development_dependency 'faraday', '~> 0.11'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubycritic'
  spec.add_development_dependency 'yard'
end
