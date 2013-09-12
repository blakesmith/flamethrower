require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::Message do
  before do
    @room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", {'name' => "flamethrower", 'id' => 73541})
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

    it "makes an UploadMessage into a URL" do
      json = JSON.parse(json_fixture('upload_message'))
      message = Flamethrower::Campfire::Message.new(json)
      message.user = @campfire_user
      message.room = @room
      expected = ":#{@irc_user.to_s} PRIVMSG #{@channel.name} :https://mydomain.campfirenow.com/room/73541/uploads/298466819/Steak.jpeg"
      message.to_irc.to_s.should == expected
    end
  end

  describe "#image_urls" do
    it "returns a standalone image url" do
      @message.body = "http://example.com/kitties.jpg"
      @message.image_urls.should == ["http://example.com/kitties.jpg"]
    end

    it "supports jpeg" do
      @message.body = "http://example.com/kitties.jpeg"
      @message.image_urls.should == ["http://example.com/kitties.jpeg"]
    end

    it "supports gif" do
      @message.body = "http://example.com/kitties.gif"
      @message.image_urls.should == ["http://example.com/kitties.gif"]
    end

    it "supports png" do
      @message.body = "http://example.com/kitties.png"
      @message.image_urls.should == ["http://example.com/kitties.png"]
    end

    it "supports multiple images" do
      @message.body = "http://example.com/kitties.png http://blah.com/duppy-pogs.png"
      @message.image_urls.should == ["http://example.com/kitties.png", "http://blah.com/duppy-pogs.png"]
    end

    it "supports interleaved urls with messages" do
      @message.body = "check this out: http://example.com/kitties.png"
      @message.image_urls.should == ["http://example.com/kitties.png"]
    end

    it "supports upcased image extensions" do
      @message.body = "check this out: http://example.com/kitties.PNG"
      @message.image_urls.should == ["http://example.com/kitties.PNG"]
    end

    it "supports https image links" do
      @message.body = "check this out: https://example.com/kitties.png"
      @message.image_urls.should == ["https://example.com/kitties.png"]
    end
  end

  describe "#has_images?" do
    it "returns true if there are images present in the body" do
      @message.body = "look ma! kitties! http://example.com/kitties.jpg"
      @message.should have_images
    end

    it "returns false if there are no images present in the body" do
      @message.body = "i love lamp, i really do"
      @message.should_not have_images
    end
  end

  describe "#needs_conversion?" do
    it "returns true if the image hasn't been converted yet" do
      @message.body = "look ma! kitties! http://example.com/kitties.jpg"
      @message.should be_needs_image_conversion
    end

    it "returns false if the image has already been converted" do
      @message.set_ascii_image("LOLCATS ASCII HERE!")
      @message.should_not be_needs_image_conversion
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
