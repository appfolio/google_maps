# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "google_maps"
  gem.homepage = "http://github.com/appfolio/geocode"
  gem.license = "MIT"
  gem.summary = %Q{Gem to interact with Google Maps v3 API}
  gem.description = %Q{General Purpose Library to interact with Google Maps v3 api. Geocoder. }
  gem.email = "tusharranka@gmail.com"
  gem.authors = ["Tushar Ranka"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test
