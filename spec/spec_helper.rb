$:.unshift File.join(File.dirname(__FILE__), "../lib")

require 'flamethrower'
require 'server/mock_server'
require 'json'
require 'fakeweb'

def json_fixture(name)
  file = File.join(File.dirname(__FILE__), "fixtures/#{name}.json")
  File.read(file)
end
