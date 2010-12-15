require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::Server do
  before do
    @server = Flamethrower::MockServer.new
    @server.stub!(:send_data)
    @user = Flamethrower::Irc::User.new :username => 'user', :nickname => 'nick', :hostname => 'host', :realname => 'realname'
    @server.current_user = @user
  end

  describe "#send_message" do
    it "sends the message to the client" do
      message = "message"
      @server.should_receive(:send_message).with("message")
      @server.send_message(message)
    end

    it "should send the data across the wire" do
      message = "message"
      @server.should_receive(:send_data).with("message\r\n")
      @server.send_message(message)
    end
  end

  describe "#send_messages" do
    it "sends a list of messages to the client" do
      @server.should_receive(:send_message).exactly(2).times
      @server.send_messages("one", "two")
    end

    it "yields to the block to allow more messages" do
      @server.should_receive(:send_message).exactly(3).times
      @server.send_messages("one", "two") do |messages|
        messages << "three"
      end
    end
  end

  describe "#receive_data" do
    it "calls the dispatcher with a new Message" do
      incoming = "COMMAND params"
      msg = Flamethrower::Message.new(incoming)
      Flamethrower::Message.should_receive(:new).with(incoming).and_return(msg)
      @server.dispatcher.should_receive(:handle_message).with(msg)
      @server.receive_data(incoming)
    end
  end

  context "#after_connect" do
    it "sends motd" do
      @server.should_receive(:send_motd)
      @server.after_connect
    end

    it "populates the channel list" do
      @server.should_receive(:populate_irc_channels)
      @server.after_connect
    end

    it "sends the channel list" do
      @server.should_receive(:send_channel_list)
      @server.after_connect
    end
  end

  describe "irc_channels" do
    it "stores the list of irc_channels on the server" do
      channel = Flamethrower::Irc::Channel.new("#flamethrower")
      @server.irc_channels << channel
      @server.irc_channels.should include(channel)
    end
  end

  describe "IRCcommands" do
    it "should have the correct MOTD format" do
      @server.send_motd.should == [
        ":host 375 nick :MOTD",
        ":host 372 nick :Welcome to Flamethrower",
        ":host 372 nick :Fetching channel list from campfire..."
      ]
    end

    it "should send the channel mode" do
      channel = Flamethrower::Irc::Channel.new("#flamethrower")
      @server.send_channel_mode(channel).should == ":host 324 nick #flamethrower +t"
    end

    it "should send the current user mode" do
      @server.send_user_mode.should == ":host 221 nick +i"
    end

    it "should have the correct TOPIC format" do
      room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", "id" => 347348, "name" => "room 1")
      channel = Flamethrower::Irc::Channel.new("#flamethrower", room)
      channel.topic = "A topic"
      @server.send_topic(channel).should == ":host 332 nick #flamethrower :A topic"
    end

    it "should have the correct USERLIST format" do
      room = Flamethrower::Campfire::Room.new('mydomain', 'mytoken')
      channel = Flamethrower::Irc::Channel.new("#flamethrower", room)
      channel.users << Flamethrower::Irc::User.new(:nickname => 'bob', :username => 'bob')
      @server.send_userlist(channel).should == [
        ":host 353 nick = #flamethrower :@nick bob",
        ":host 366 nick #flamethrower :/End of /NAMES list"
      ]
    end

    it "sends the campfire users in the userlist" do
      room = Flamethrower::Campfire::Room.new('mydomain', 'mytoken')
      channel = Flamethrower::Irc::Channel.new("#flamethrower", room)
      user1 = Flamethrower::Campfire::User.new('id' => 1234, 'name' => 'Bob Jones')
      user2 = Flamethrower::Campfire::User.new('id' => 4321, 'name' => 'Bill Myer')
      room.users = [user1, user2]
      @server.send_userlist(channel).should == [
        ":host 353 nick = #flamethrower :@nick Bob_Jones Bill_Myer",
        ":host 366 nick #flamethrower :/End of /NAMES list"
      ]
    end

    describe "#send_channel_list" do
      it "sends the right motd message with the channel list" do
        room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", "id" => 347348, "name" => "room 1")
        room2 = Flamethrower::Campfire::Room.new("mydomain", "mytoken", "id" => 347349, "name" => "room 2")
        channel = Flamethrower::Irc::Channel.new("#flamethrower", room)
        channel.topic = "Flamethrower topic"
        channel2 = Flamethrower::Irc::Channel.new("#room_1", room2)
        channel2.topic = "Room 1 topic"
        @server.irc_channels = [channel, channel2]
        @server.send_channel_list.should == [
          ":host 372 nick :Active channels:",
          ":host 372 nick :#flamethrower - Flamethrower topic",
          ":host 372 nick :#room_1 - Room 1 topic",
          ":host 376 nick :End of channel list /MOTD"
        ]
      end

      it "shows 'No topic' in the channel list if there's no room topic" do
        room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", "id" => 347348, "name" => "room 1")
        room2 = Flamethrower::Campfire::Room.new("mydomain", "mytoken", "id" => 347349, "name" => "room 2")
        channel = Flamethrower::Irc::Channel.new("#flamethrower", room)
        channel2 = Flamethrower::Irc::Channel.new("#room_1", room2)
        channel.topic = channel2.topic = ""
        @server.irc_channels = [channel, channel2]
        @server.send_channel_list.should == [
          ":host 372 nick :Active channels:",
          ":host 372 nick :#flamethrower - No topic",
          ":host 372 nick :#room_1 - No topic",
          ":host 376 nick :End of channel list /MOTD"
        ]
      end
    end

    describe "#populate_irc_channels" do
      it "populates the server irc_channels from the associated campfire channels" do
        FakeWeb.register_uri(:get, "https://mytoken:x@mydomain.campfirenow.com/rooms.json", :body => json_fixture("rooms"), :status => ["200", "OK"])
        @server.populate_irc_channels
        @server.irc_channels.count.should == 1
        @server.irc_channels.first.name.should == "#room_1"
      end
    end
  end

end
