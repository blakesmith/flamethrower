$:.unshift File.join(File.dirname(__FILE__), "flamethrower")

require 'rubygems'
require 'bundler'

Bundler.setup

require 'eventmachine'
require 'twitter/json_stream'
require 'logger'
require 'json'

require 'irc/codes'
require 'irc/commands'
require 'irc/user'
require 'irc/channel'

require 'campfire/rest_api'
require 'campfire/user'
require 'campfire/connection'
require 'campfire/room'

require 'server'
require 'server/event_server'
require 'message'
require 'dispatcher'
