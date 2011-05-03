require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::Connection do
  before do
    @connection = Flamethrower::MockConnection.new
    @connection.stub!(:send_data)
    @user = Flamethrower::Irc::User.new :username => 'user', :nickname => 'nick', :hostname => 'host', :realname => 'realname'
    @connection.current_user = @user
  end

  describe "#send_message" do
    it "sends the message to the client" do
      message = "message"
      @connection.should_receive(:send_message).with("message")
      @connection.send_message(message)
    end

    it "should send the data across the wire" do
      message = "message"
      @connection.should_receive(:send_data).with("message\r\n")
      @connection.send_message(message)
    end
  end

  describe "#send_messages" do
    it "sends a list of messages to the client" do
      @connection.should_receive(:send_message).exactly(2).times
      @connection.send_messages("one", "two")
    end

    it "yields to the block to allow more messages" do
      @connection.should_receive(:send_message).exactly(3).times
      @connection.send_messages("one", "two") do |messages|
        messages << "three"
      end
    end
  end

  describe "#receive_data" do
    it "calls the dispatcher with a new Message" do
      incoming = "COMMAND params"
      msg = Flamethrower::Irc::Message.new(incoming)
      Flamethrower::Irc::Message.should_receive(:new).with(incoming).and_return(msg)
      @connection.dispatcher.should_receive(:handle_message).with(msg)
      @connection.receive_data(incoming)
    end
  end

  context "#after_connect" do
    before do
      stub_request(:get, "https://mydomain.campfirenow.com/rooms.json").
        with(:headers => {'Authorization'=>['mytoken', 'x']}).
        to_return(:status => 200, :body => json_fixture("rooms"))
    end

    it "sends motd" do
      @connection.stub(:populate_irc_channels)
      @connection.stub(:populate_my_user)
      @connection.should_receive(:send_motd)
      @connection.after_connect
    end

    it "populates the channel list" do
      @connection.stub(:populate_my_user)
      @connection.should_receive(:populate_irc_channels)
      @connection.after_connect
    end

    it "populates the currently logged in user" do
      @connection.stub(:populate_irc_channels)
      @connection.should_receive(:populate_my_user)
      @connection.after_connect
    end
  end

  describe "irc_channels" do
    it "stores the list of irc_channels on the connection" do
      channel = Flamethrower::Irc::Channel.new("#flamethrower")
      @connection.irc_channels << channel
      @connection.irc_channels.should include(channel)
    end
  end

  describe "IRCcommands" do
    it "should have the correct MOTD format" do
      @connection.send_motd.should == [
        ":host 375 nick :MOTD",
        ":host 372 nick :Welcome to Flamethrower",
        ":host 372 nick :Fetching channel list from campfire..."
      ]
    end

    it "should send the channel mode" do
      channel = Flamethrower::Irc::Channel.new("#flamethrower")
      @connection.send_channel_mode(channel).should == ":host 324 nick #flamethrower +t"
    end

    it "should send the current user mode" do
      @connection.send_user_mode.should == ":host 221 nick +i"
    end

    it "should have the correct TOPIC format" do
      room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", "id" => 347348, "name" => "room 1")
      channel = Flamethrower::Irc::Channel.new("#flamethrower", room)
      channel.topic = "A topic"
      @connection.send_topic(channel).should == ":host 332 nick #flamethrower :A topic"
    end

    it "should have the correct USERLIST format" do
      room = Flamethrower::Campfire::Room.new('mydomain', 'mytoken')
      channel = Flamethrower::Irc::Channel.new("#flamethrower", room)
      channel.users << Flamethrower::Irc::User.new(:nickname => 'bob', :username => 'bob')
      @connection.send_userlist(channel).should == [
        ":host 353 nick = #flamethrower :@nick bob",
        ":host 366 nick #flamethrower :/End of /NAMES list"
      ]
    end

    describe "#send_who" do
      it "sends the campfire users in the userlist" do
        room = Flamethrower::Campfire::Room.new('mydomain', 'mytoken')
        channel = Flamethrower::Irc::Channel.new("#flamethrower", room)
        user1 = Flamethrower::Campfire::User.new('id' => 1234, 'name' => 'Bob Jones')
        user2 = Flamethrower::Campfire::User.new('id' => 4321, 'name' => 'Bill Myer')
        room.users = [user1, user2]
        @connection.send_who(channel).should == [
          ":host 352 nick #flamethrower Bob_Jones campfirenow.com localhost Bob_Jones H :0 Bob_Jones",
          ":host 352 nick #flamethrower Bill_Myer campfirenow.com localhost Bill_Myer H :0 Bill_Myer",
          ":host 315 nick #flamethrower :/End of /WHO list"
        ]
      end
    end

    describe "#send_channel_list" do
      it "sends the right motd message with the channel list" do
        room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", "id" => 347348, "name" => "room 1")
        room2 = Flamethrower::Campfire::Room.new("mydomain", "mytoken", "id" => 347349, "name" => "room 2")
        channel = Flamethrower::Irc::Channel.new("#flamethrower", room)
        channel.topic = "Flamethrower topic"
        channel2 = Flamethrower::Irc::Channel.new("#room_1", room2)
        channel2.topic = "Room 1 topic"
        @connection.irc_channels = [channel, channel2]
        @connection.send_channel_list.should == [
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
        @connection.irc_channels = [channel, channel2]
        @connection.send_channel_list.should == [
          ":host 372 nick :Active channels:",
          ":host 372 nick :#flamethrower - No topic",
          ":host 372 nick :#room_1 - No topic",
          ":host 376 nick :End of channel list /MOTD"
        ]
      end
    end

    describe "#populate_irc_channels" do
      it "populates the server irc_channels from the associated campfire channels" do
        stub_request(:get, "https://mydomain.campfirenow.com/rooms.json").
          with(:headers => {'Authorization'=>['mytoken', 'x']}).
          to_return(:status => 200, :body => json_fixture("rooms"))
        
        EM.run_block { @connection.populate_irc_channels }
        @connection.irc_channels.count.should == 1
        @connection.irc_channels.first.name.should == "#room_1"
      end
    end
  end

end
