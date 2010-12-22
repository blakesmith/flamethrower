$:.unshift File.join(File.dirname(__FILE__), "flamethrower")

require 'rubygems'

require 'net/https'
require 'eventmachine'
require 'twitter/json_stream'
require 'logger'
require 'json'

require 'irc/codes'
require 'irc/commands'
require 'irc/user'
require 'irc/channel'
require 'irc/message'

require 'campfire/rest_api'
require 'campfire/user'
require 'campfire/message'
require 'campfire/connection'
require 'campfire/room'

require 'server'
require 'server/event_server'
require 'dispatcher'
