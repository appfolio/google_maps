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
  gem.name = "geocode"
  gem.homepage = "http://github.com/appfolio/geocode"
  gem.license = "MIT"
  gem.summary = %Q{Geocode addresses using google geocode v3 API}
  gem.description = %Q{Geocode addresses using google geocode v3 API}
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
