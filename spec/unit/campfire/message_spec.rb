require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::Message do
  before do
    @room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", {'name' => "flamethrower"})
    @channel = Flamethrower::Irc::Channel.new("#flamethrower", @room)
    @campfire_user = Flamethrower::Campfire::User.new('name' => "bob", 'id' => 734581)
    @irc_user = @campfire_user.to_irc
    @message = Flamethrower::Campfire::Message.new('user' => @campfire_user, 'room' => @room, 'body' => 'thebody', 'type' => "TextMessage")
  end

  it "should have the message body" do
    @message.body.should == "thebody"
  end

  it "should have the message type" do
    @message.message_type.should == "TextMessage"
  end

  it "initializes the status to 'pending'" do
    @message.status.should == "pending"
  end

  describe "#to_irc" do
    it "converts the message to an irc message" do
      @message.to_irc.to_s.should == ":#{@irc_user.to_s} PRIVMSG #{@channel.name} :thebody"
    end
  end

  describe "#mark_delivered!" do
    it "sets the status to delivered" do
      @message.status.should_not == "delivered"
      @message.mark_delivered!
      @message.status.should == "delivered"
    end
  end

  describe "#mark_failed!" do
    it "sets the status to failed" do
      @message.status.should_not == "delivered"
      @message.mark_failed!
      @message.status.should == "failed"
    end
  end
end
