require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::IrcServer do
  before do
    klass = Object.new
    klass.extend Flamethrower::IrcServer
  end
end
