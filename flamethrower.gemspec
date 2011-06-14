# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flamethrower}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Blake Smith"]
  s.date = %q{2011-06-14}
  s.description = %q{Flamethrower gives you the power to use your awesome irc client to talk in your campfire rooms.}
  s.email = %q{blakesmith0@gmail.com}
  s.executables = ["flamethrowerd", "flamethrower"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "MIT-LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/flamethrower",
    "bin/flamethrowerd",
    "flamethrower.gemspec",
    "flamethrower.yml.example",
    "lib/flamethrower.rb",
    "lib/flamethrower/ascii_imager.rb",
    "lib/flamethrower/campfire/connection.rb",
    "lib/flamethrower/campfire/message.rb",
    "lib/flamethrower/campfire/rest_api.rb",
    "lib/flamethrower/campfire/room.rb",
    "lib/flamethrower/campfire/user.rb",
    "lib/flamethrower/connection.rb",
    "lib/flamethrower/dispatcher.rb",
    "lib/flamethrower/irc/channel.rb",
    "lib/flamethrower/irc/codes.rb",
    "lib/flamethrower/irc/commands.rb",
    "lib/flamethrower/irc/message.rb",
    "lib/flamethrower/irc/user.rb",
    "lib/flamethrower/server/event_server.rb",
    "lib/flamethrower/server/mock_connection.rb",
    "spec/fixtures/enter_message.json",
    "spec/fixtures/kick_message.json",
    "spec/fixtures/leave_message.json",
    "spec/fixtures/message.json",
    "spec/fixtures/paste_message.json",
    "spec/fixtures/paste_message_with_pound.json",
    "spec/fixtures/recent_messages.json",
    "spec/fixtures/room.json",
    "spec/fixtures/room_update.json",
    "spec/fixtures/rooms.json",
    "spec/fixtures/speak_message.json",
    "spec/fixtures/streaming_image_message.json",
    "spec/fixtures/streaming_message.json",
    "spec/fixtures/timestamp_message.json",
    "spec/fixtures/tweet_message.json",
    "spec/fixtures/upload_message.json",
    "spec/fixtures/upload_url_sample",
    "spec/fixtures/user.json",
    "spec/spec_helper.rb",
    "spec/unit/campfire/connection_spec.rb",
    "spec/unit/campfire/message_spec.rb",
    "spec/unit/campfire/room_spec.rb",
    "spec/unit/campfire/user_spec.rb",
    "spec/unit/connection_spec.rb",
    "spec/unit/dispatcher_spec.rb",
    "spec/unit/irc/channel_spec.rb",
    "spec/unit/irc/message_spec.rb",
    "spec/unit/irc/user_spec.rb",
    "spec/unit/server/event_server_spec.rb"
  ]
  s.homepage = %q{http://github.com/blakesmith/flamethrower}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.3}
  s.summary = %q{Campfire IRC gateway}
  s.test_files = [
    "spec/spec_helper.rb",
    "spec/unit/campfire/connection_spec.rb",
    "spec/unit/campfire/message_spec.rb",
    "spec/unit/campfire/room_spec.rb",
    "spec/unit/campfire/user_spec.rb",
    "spec/unit/connection_spec.rb",
    "spec/unit/dispatcher_spec.rb",
    "spec/unit/irc/channel_spec.rb",
    "spec/unit/irc/message_spec.rb",
    "spec/unit/irc/user_spec.rb",
    "spec/unit/server/event_server_spec.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_runtime_dependency(%q<twitter-stream>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<em-http-request>, [">= 0"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0.12.10"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<em-http-request>, [">= 0"])
      s.add_runtime_dependency(%q<twitter-stream>, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<twitter-stream>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<em-http-request>, [">= 0"])
      s.add_dependency(%q<eventmachine>, [">= 0.12.10"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<em-http-request>, [">= 0"])
      s.add_dependency(%q<twitter-stream>, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<twitter-stream>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<em-http-request>, [">= 0"])
    s.add_dependency(%q<eventmachine>, [">= 0.12.10"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<em-http-request>, [">= 0"])
    s.add_dependency(%q<twitter-stream>, [">= 0"])
  end
end

