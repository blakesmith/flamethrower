require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::IrcChannel do
  before do
    @channel = Flamethrower::IrcChannel.new("#flamethrower")
  end

  it "returns the current channel name" do
    @channel.name.should == "#flamethrower"
  end

  it "returns the current channel topic" do
    @channel.topic = "The topic"
    @channel.topic.should == "The topic"
  end

  it "returns the current user list" do
    user = Flamethrower::IrcUser.new
    @channel.users << user
    @channel.users.should include(user)
  end
end
