require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Irc::Channel do
  before do
    @room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", {'name' => "flamethrower"})
    @channel = Flamethrower::Irc::Channel.new("#flamethrower", @room)
    @campfire_user = Flamethrower::Campfire::User.new('name' => "bob", 'id' => 734581)
    @irc_user = @campfire_user.to_irc
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

  describe "#to_campfire" do
    it "returns the stored copy of the campfire room" do
      @channel.to_campfire.should == @room
    end
  end

  describe "#irc_messages" do
    it "returns the irc messages to be sent to the client" do
      message = Flamethrower::Campfire::Message.new('body' => 'Hello there', 'user' => @campfire_user, 'room' => @room)
      @room.inbound_messages << message
      @channel.retrieve_irc_messages.map(&:to_s).should == [":#{@irc_user.to_s} PRIVMSG #{@channel.name} :Hello there"]
    end
  end
end
