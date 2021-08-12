# frozen_string_literal: true

require 'grape-cache'

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
