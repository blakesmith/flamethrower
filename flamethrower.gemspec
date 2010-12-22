# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flamethrower}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Blake Smith"]
  s.date = %q{2010-12-22}
  s.default_executable = %q{flamethrower}
  s.description = %q{Flamethrower gives you the power to use your awesome irc client to talk in your campfire rooms.}
  s.email = %q{blakesmith0@gmail.com}
  s.executables = ["flamethrower"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     ".rspec",
     "Gemfile",
     "Gemfile.lock",
     "MIT-LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/flamethrower",
     "flamethrower.gemspec",
     "lib/flamethrower.rb",
     "lib/flamethrower/campfire/connection.rb",
     "lib/flamethrower/campfire/message.rb",
     "lib/flamethrower/campfire/rest_api.rb",
     "lib/flamethrower/campfire/room.rb",
     "lib/flamethrower/campfire/user.rb",
     "lib/flamethrower/dispatcher.rb",
     "lib/flamethrower/irc/channel.rb",
     "lib/flamethrower/irc/codes.rb",
     "lib/flamethrower/irc/commands.rb",
     "lib/flamethrower/irc/message.rb",
     "lib/flamethrower/irc/user.rb",
     "lib/flamethrower/server.rb",
     "lib/flamethrower/server/event_server.rb",
     "lib/flamethrower/server/mock_server.rb",
     "spec/fixtures/enter_message.json",
     "spec/fixtures/kick_message.json",
     "spec/fixtures/leave_message.json",
     "spec/fixtures/message.json",
     "spec/fixtures/paste_message.json",
     "spec/fixtures/room.json",
     "spec/fixtures/room_update.json",
     "spec/fixtures/rooms.json",
     "spec/fixtures/speak_message.json",
     "spec/fixtures/streaming_message.json",
     "spec/spec_helper.rb",
     "spec/unit/campfire/connection_spec.rb",
     "spec/unit/campfire/message_spec.rb",
     "spec/unit/campfire/room_spec.rb",
     "spec/unit/campfire/user_spec.rb",
     "spec/unit/dispatcher_spec.rb",
     "spec/unit/irc/channel_spec.rb",
     "spec/unit/irc/message_spec.rb",
     "spec/unit/irc/user_spec.rb",
     "spec/unit/server/event_server_spec.rb",
     "spec/unit/server_spec.rb"
  ]
  s.homepage = %q{http://github.com/blakesmith/flamethrower}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Campfire IRC gateway}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/unit/campfire/connection_spec.rb",
     "spec/unit/campfire/message_spec.rb",
     "spec/unit/campfire/room_spec.rb",
     "spec/unit/campfire/user_spec.rb",
     "spec/unit/dispatcher_spec.rb",
     "spec/unit/irc/channel_spec.rb",
     "spec/unit/irc/message_spec.rb",
     "spec/unit/irc/user_spec.rb",
     "spec/unit/server/event_server_spec.rb",
     "spec/unit/server_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0.12.10"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<twitter-stream>, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0.12.10"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<twitter-stream>, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0.12.10"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<twitter-stream>, [">= 0"])
  end
end

