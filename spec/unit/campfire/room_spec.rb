require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::Room do
  before do
    @room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", "id" => 347348, "topic" => "some topic", "name" => "some name")
  end

  describe "params" do
    it "has number" do
      @room.number.should == 347348
    end
    
    it "has topic" do
      @room.topic.should == "some topic"
    end

    it "has name" do
      @room.name.should == "some name"
    end
  end

  describe "#fetch_room_info" do
    before do
      FakeWeb.register_uri(:get, "https://mytoken:x@mydomain.campfirenow.com/room/347348.json", :body => json_fixture("room"), :status => ["200", "OK"])
    end

    it "retrieves a list of users and stores them as user objects" do
      @room.fetch_room_info
      @room.users.all? {|u| u.is_a?(Flamethrower::Campfire::User)}.should be_true
    end

    it "makes the http request with a token in basic auth" do
      @room.fetch_room_info
      FakeWeb.last_request['authorization'].should == "Basic #{Base64::encode64("#{@room.token}:x").chomp}"
    end

  end

  describe "#connect" do
    it "initializes the twitter jsonstream with the right options" do
      Twitter::JSONStream.should_receive(:connect).with(:path => "/room/347348/live.json", :host => "streaming.campfirenow.com", :auth => "mytoken:x")
      @room.connect
    end
  end

  describe "#fetch_messages" do
    before do
      Twitter::JSONStream.stub(:connect).and_return("stream")
      item = json_fixture("message")
      @room.connect
      @room.stream.stub(:each_item).and_yield(item)
    end

    it "iterates over each stream item and sends to the message queue" do
      @room.fetch_messages
      @room.inbound_messages.size.should == 1
    end

    it "maps the message body to a message object with the right body" do
      @room.fetch_messages
      @room.inbound_messages.pop.body.should == "Wait for the message."
    end

    it "maps the message sender to the right user" do
      user = Flamethrower::Campfire::User.new('name' => "bob", 'id' => 734581)
      @room.users << user
      @room.fetch_messages
      @room.inbound_messages.pop.user.should == user
    end

    it "maps the message room to the right room" do
      @room.fetch_messages
      @room.inbound_messages.pop.room.should == @room
    end
  end

  describe "#retrieve_messages" do
    it "returns all the messages in the message buffer" do
      @room.inbound_messages << "one"
      @room.inbound_messages << "two"
      @room.retrieve_messages.should == ["one", "two"]
    end

    it "pops the messages from the messages array" do
      @room.inbound_messages << "one"
      @room.retrieve_messages.should == ["one"]
      @room.inbound_messages.size.should == 0
    end
  end

  describe "#to_irc" do
    it "returns an irc channel object" do
      @room.to_irc.is_a?(Flamethrower::Irc::Channel).should be_true
    end

    context "channel name" do
      it "maps the campfire room name to the channel name" do
        @room.name = "somename"
        @room.to_irc.name.should == "#somename"
      end

      it "downcases channel names" do
        @room.name = "Somename"
        @room.to_irc.name.should == "#somename"
      end

      it "separates replaces name spaces with underscores" do
        @room.name = "Some Name 1"
        @room.to_irc.name.should == "#some_name_1"
      end
    end

    context "populating users" do
      it "fills the irc channel's user array with mapped campfire users" do
        @room.users = [Flamethrower::Campfire::User.new('name' => "bob")]
        @room.to_irc.users.first.is_a?(Flamethrower::Irc::User).should be_true
      end

    end
  end
end
