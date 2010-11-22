require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Irc::Channel do
  before do
    @channel = Flamethrower::Irc::Channel.new("#flamethrower")
  end

  it "returns the current channel name" do
    @channel.name.should == "#flamethrower"
  end

  it "returns the current channel topic" do
    @channel.topic = "The topic"
    @channel.topic.should == "The topic"
  end

  it "returns the current user list" do
    user = Flamethrower::Irc::User.new
    @channel.users << user
    @channel.users.should include(user)
  end

  it "returns the channel mode from an array of modes" do
    @channel.mode.should == "+t"
  end
end
