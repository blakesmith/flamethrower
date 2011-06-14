require 'rubygems'
require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" 
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "flamethrower"
    gemspec.summary = "Campfire IRC gateway"
    gemspec.description = "Flamethrower gives you the power to use your awesome irc client to talk in your campfire rooms."
    gemspec.email = "blakesmith0@gmail.com"
    gemspec.homepage = "http://github.com/blakesmith/flamethrower"
    gemspec.authors = ["Blake Smith"]
    gemspec.add_dependency('eventmachine', '>=0.12.10')
    gemspec.add_dependency('json')
    gemspec.add_dependency('em-http-request')
    gemspec.add_dependency('twitter-stream')
    gemspec.add_dependency('daemons')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

