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

  spec.files = Dir['LICENSE', 'lib/**/*']
  spec.extra_rdoc_files = ['README.md']

  spec.require_path = 'lib'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/netrusov/grape-cache/issues',
    'source_code_uri' => 'https://github.com/netrusov/grape-cache'
  }

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'grape', '>= 1.2', '< 2'
  spec.add_runtime_dependency 'rack'
end
