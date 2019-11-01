# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'grape/cache/version'

Gem::Specification.new do |spec|
  spec.name = 'grape-cache'
  spec.version = Grape::Cache::VERSION
  spec.authors = ['Alexander Netrusov']
  spec.license = 'MIT'

  spec.summary = 'Yet another caching solution for Grape framework'
  spec.homepage = 'https://github.com/netrusov/grape-cache'

  spec.files = Dir['**/*'].keep_if { |file| File.file?(file) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'grape', '~> 1.2.3'
  spec.add_runtime_dependency 'rack'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
end
