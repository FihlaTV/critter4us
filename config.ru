#!/usr/bin/env rackup

# rackup is a useful tool for running Rack applications, which uses the
# Rack::Builder DSL to configure middleware and build up applications easily.
#
# rackup automatically figures out the environment it is run in, and runs your
# application as FastCGI, CGI, or standalone with Mongrel or WEBrick -- all from
# the same configuration.

require 'rubygems'
require "bundler"
Bundler.require

require './app'

require 'sinatra/base'
require 'hoptoad_notifier'

HoptoadNotifier.configure do |config|
  config.api_key = '1068f0103e5db4628c91c12495cc3ec5'
end
use HoptoadNotifier::Rack

run Controller
