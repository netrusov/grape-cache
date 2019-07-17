# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'grape/cache/version'

Gem::Specification.new do |spec|
  spec.name = 'grape-cache'
  spec.version = Grape::Cache::VERSION
  spec.authors = ['Alexander Netrusov']

  spec.summary = 'Yet another caching solution for Grape framework'

  spec.files = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'grape', '~> 1.2.3'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
end
