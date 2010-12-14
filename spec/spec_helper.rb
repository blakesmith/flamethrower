$:.unshift File.join(File.dirname(__FILE__), "../lib")

require 'flamethrower'
require 'server/mock_server'
require 'json'
require 'fakeweb'

::FLAMETHROWER_LOGGER = Logger.new("/dev/null") unless Object.const_defined?("FLAMETHROWER_LOGGER")

def json_fixture(name)
  file = File.join(File.dirname(__FILE__), "fixtures/#{name}.json")
  File.read(file)
end
