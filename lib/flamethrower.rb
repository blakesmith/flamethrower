$:.unshift File.join(File.dirname(__FILE__), "flamethrower")

require 'rubygems'
require 'eventmachine'
require 'twitter/json_stream'
require 'logger'

require 'irc_codes'
require 'irc_commands'
require 'tinder_commands'
require 'campfire_connection'
require 'server'
require 'server/event_server'
require 'irc_user'
require 'irc_channel'
require 'message'
require 'dispatcher'
