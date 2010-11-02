$:.unshift File.join(File.dirname(__FILE__), "flamethrower")

require 'rubygems'
require 'eventmachine'

require 'irc_commands'
require 'tinder_commands'
require 'server'
require 'server/event_server'
require 'irc_user'
require 'message'
