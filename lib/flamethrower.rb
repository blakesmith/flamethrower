$:.unshift File.join(File.dirname(__FILE__), "flamethrower")

require 'rubygems'
require 'eventmachine'

require 'irc_commands'
require 'tinder_commands'
require 'server'
