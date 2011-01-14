require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::Message do
  before do
    @room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", {'name' => "flamethrower"})
    @channel = Flamethrower::Irc::Channel.new("#flamethrower", @room)
    @campfire_user = Flamethrower::Campfire::User.new('name' => "bob", 'id' => 734581)
    @room.users << @campfire_user
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

    it "returns if the message type is unhandled" do
      json = JSON.parse(json_fixture('enter_message'))
      json['type'] = "BogusMessage"
      message = Flamethrower::Campfire::Message.new(json)
      message.user = @campfire_user
      message.room = @room
      Flamethrower::Irc::Message.should_not_receive(:new)
      message.to_irc.should be_nil
    end

    it "converts a EnterMessage to a join irc message" do
      json = JSON.parse(json_fixture('enter_message'))
      message = Flamethrower::Campfire::Message.new(json)
      message.user = @campfire_user
      message.room = @room
      message.to_irc.to_s.should == ":#{@irc_user.to_s} JOIN #{@channel.name}"
    end

    it "converts a KickMessage to a part irc message" do
      json = JSON.parse(json_fixture('kick_message'))
      message = Flamethrower::Campfire::Message.new(json)
      message.user = @campfire_user
      message.room = @room
      message.to_irc.to_s.should == ":#{@irc_user.to_s} PART #{@channel.name}"
    end

    it "converts a LeaveMessage to a part irc message" do
      json = JSON.parse(json_fixture('leave_message'))
      message = Flamethrower::Campfire::Message.new(json)
      message.user = @campfire_user
      message.room = @room
      message.to_irc.to_s.should == ":#{@irc_user.to_s} PART #{@channel.name}"
    end


    it "makes a PasteMessage a PRIVMSG" do
      json = JSON.parse(json_fixture('paste_message'))
      message = Flamethrower::Campfire::Message.new(json)
      message.user = @campfire_user
      message.room = @room
      expected = ":#{@irc_user.to_s} PRIVMSG #{@channel.name} :Line one\r\n"
      expected << ":#{@irc_user.to_s} PRIVMSG #{@channel.name} :\tpoint one\r\n"
      expected << ":#{@irc_user.to_s} PRIVMSG #{@channel.name} :\tpoint two\r\n"
      expected << ":#{@irc_user.to_s} PRIVMSG #{@channel.name} :point three"
      message.to_irc.to_s.should == expected
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

    it "sets the retry_at to 15 seconds from now" do
      Time.stub(:now).and_return(Time.parse("9:00AM"))
      @message.mark_failed!
      @message.retry_at.should == Time.parse("9:00:15AM")
    end
  end
end
