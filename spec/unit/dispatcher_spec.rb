require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::Dispatcher do
  before do
    @server = Flamethrower::MockServer.new(:log => Logger.new("/dev/null"))
    @room = Flamethrower::Campfire::Room.new('mydomain', 'mytoken', {'name' => 'a room', 'id' => 347348})
    @channel = Flamethrower::Irc::Channel.new("#flamethrower", @room)
    @server.irc_channels << @channel
    @dispatcher = Flamethrower::Dispatcher.new(@server)
  end

  describe "#handle_message" do
    it "sends the message to the right command handler method" do
      message = Flamethrower::Irc::Message.new("USER stuff\r\n")
      @dispatcher.should_receive(:handle_user).with(message)
      @dispatcher.handle_message(message)
    end

    it "doesn't send the message to the handler method if the method doesn't exist" do
      message = Flamethrower::Irc::Message.new("BOGUS stuff\r\n")
      @dispatcher.should_not_receive(:BOGUS)
      @dispatcher.handle_message(message)
    end
  end

  describe "#user" do
    it "sets the current session's user to the specified user" do
      message = Flamethrower::Irc::Message.new("USER guest tolmoon tolsun :Ronnie Reagan\r\n")
      @dispatcher.handle_message(message)
      @dispatcher.server.current_user.username.should == "guest"
      @dispatcher.server.current_user.hostname.should == "tolmoon"
      @dispatcher.server.current_user.servername.should == "tolsun"
      @dispatcher.server.current_user.realname.should == "Ronnie Reagan"
    end

    it "not set a second user request if a first has already been recieved" do
      message = Flamethrower::Irc::Message.new("USER guest tolmoon tolsun :Ronnie Reagan\r\n")
      message2 = Flamethrower::Irc::Message.new("USER guest2 tolmoon2 tolsun2 :Ronnie Reagan2\r\n")
      @dispatcher.handle_message(message)
      @dispatcher.handle_message(message2)
      @dispatcher.server.current_user.username.should == "guest"
      @dispatcher.server.current_user.hostname.should == "tolmoon"
      @dispatcher.server.current_user.servername.should == "tolsun"
      @dispatcher.server.current_user.realname.should == "Ronnie Reagan"
    end
  end

  describe "#topic" do
    before do
      @user = Flamethrower::Irc::User.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
      @server.current_user = @user
    end

    context "retrieving the channel topic" do
      it "should display the channel topic" do
        message = Flamethrower::Irc::Message.new("TOPIC #flamethrower")
        @dispatcher.server.should_receive(:send_topic).with(@channel)
        @dispatcher.handle_message(message)
      end

      it "responds with an error if the channel can't be found" do
        message = Flamethrower::Irc::Message.new("TOPIC #bogus")
        @dispatcher.server.should_not_receive(:send_topic)
        @dispatcher.server.should_receive(:send_message).with(":#{@user.hostname} 475")
        @dispatcher.handle_message(message)
      end
    end

    context "setting the channel topic" do
      it "sets the channel topic to the specified topic" do
       stub_request(:put, "https://mydomain.campfirenow.com/room/347348.json").
         with(:headers => {'Authorization'=>['mytoken', 'x'], 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => json_fixture("room_update"))
        message = Flamethrower::Irc::Message.new("TOPIC #flamethrower :some awesome topic")
        @dispatcher.server.should_receive(:send_topic).with(@channel)
        EM.run_block { @dispatcher.handle_message(message) }
        @channel.topic.should == "some awesome topic"
      end
    end
  end

  describe "#who" do
    it "responds with a who list" do
      message = Flamethrower::Irc::Message.new("WHO #flamethrower\r\n")
      @dispatcher.server.should_receive(:send_who).with(@channel)
      @dispatcher.handle_message(message)
    end
  end

  describe "#mode" do
    before do
      @user = Flamethrower::Irc::User.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
      @server.current_user = @user
    end

    context "channel mode" do
      it "responds to mode with a static channel mode" do
        message = Flamethrower::Irc::Message.new("MODE #flamethrower\r\n")
        @dispatcher.server.should_receive(:send_channel_mode).with(@channel)
        @dispatcher.handle_message(message)
      end

      it "responds with the user mode if the mode isn't for a channel" do
        message = Flamethrower::Irc::Message.new("MODE #{@user.nickname} +i\r\n")
        @dispatcher.server.should_receive(:send_user_mode)
        @dispatcher.handle_message(message)
      end

      it "responds with unknown command if the mode is neither a server nor the current user" do
        message = Flamethrower::Irc::Message.new("MODE foo\r\n")
        @dispatcher.server.should_receive(:send_message).with(":#{@user.hostname} 421")
        @dispatcher.handle_message(message)
      end
    end
  end

  describe "#nick" do
    it "sets the current session's user nickname to the specified nick" do
      message = Flamethrower::Irc::Message.new("NICK WiZ\r\n")
      @dispatcher.handle_message(message)
      @dispatcher.server.current_user.nickname.should == "WiZ"
    end
  end

  describe "#privmsg" do
    context "sent by me" do
      it "generates and queues an outbound campfire message to the right room" do
        message = Flamethrower::Irc::Message.new("PRIVMSG #test :Hello.\r\n")
        room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", {'name' => "test"})
        irc_channel = room.to_irc
        @dispatcher.server.irc_channels << irc_channel
        @dispatcher.handle_message(message)
        room.outbound_messages.size.should == 1
      end

      it "sends the right message parameters to the new outbound message" do
        message = Flamethrower::Irc::Message.new("PRIVMSG #test :Hello.\r\n")
        room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", {'name' => "test"})
        irc_channel = room.to_irc
        @dispatcher.server.irc_channels << irc_channel
        @dispatcher.handle_message(message)
        campfire_message = room.outbound_messages.pop
        campfire_message.body.should == "Hello."
        campfire_message.user.should be_nil
        campfire_message.message_type.should == "TextMessage"
      end
    end
  end

  describe "#ping" do
    it "responds with pong of the same ping parameters" do
      message = Flamethrower::Irc::Message.new("PING :something\r\n")
      @server.should_receive(:send_message).with("PONG :something")
      @dispatcher.handle_message(message)
    end
  end

  describe "#part" do
    it "stops the thread of the room being parted from" do
      EventMachine.stub(:cancel_timer)
      @room.instance_variable_set("@room_alive", true)
      @room.should be_alive
      message = Flamethrower::Irc::Message.new("PART #flamethrower")
      @dispatcher.handle_message(message)
      @room.should_not be_alive
    end

    it "sends a part message with your current user's name" do
      EventMachine.stub(:cancel_timer)
      user = Flamethrower::Irc::User.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
      @server.current_user = user
      message = Flamethrower::Irc::Message.new("PART #flamethrower")
      @server.should_receive(:send_message).with(":#{user.to_s} PART #flamethrower")
      @dispatcher.handle_message(message)
    end

    it "responds with ERR_BADCHANNELKEY a channel that doesn't exist" do
      user = Flamethrower::Irc::User.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
      @server.current_user = user
      message = Flamethrower::Irc::Message.new("PART #foobar")
      @server.should_receive(:send_message).with(":#{user.hostname} 475")
      @dispatcher.handle_message(message)
    end
  end

  describe "#quit" do
    it "kills all the room threads on quit" do
      timer = mock(:timer)
      EventMachine.should_receive(:cancel_timer).with(timer)
      @room.instance_variable_set("@room_alive", true)
      @room.instance_variable_set("@timer", timer)
      @room.should be_alive
      message = Flamethrower::Irc::Message.new("QUIT :leaving")
      @dispatcher.handle_message(message)
      @room.should_not be_alive
    end
  end

  describe "#join" do
    before do
      @room.stub(:start)
      @room.stub(:fetch_room_info)
      @room.stub(:join)
    end

    it "responds with a topic and userlist if sent a join" do
      message = Flamethrower::Irc::Message.new("JOIN #flamethrower\r\n")
      @server.should_receive(:send_topic).with(@channel)
      @server.should_receive(:send_userlist)
      @dispatcher.handle_message(message)
    end

    it "adds the current user to the channel" do
      user = Flamethrower::Irc::User.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
      @server.current_user = user
      message = Flamethrower::Irc::Message.new("JOIN #flamethrower\r\n")
      @dispatcher.handle_message(message)
      @channel.users.should include(user)
    end

    it "fetches the room information on join" do
      message = Flamethrower::Irc::Message.new("JOIN #flamethrower\r\n")
      @room.should_receive(:fetch_room_info)
      @dispatcher.handle_message(message)
    end

    it "responds with ERR_BADCHANNELKEY a channel that doesn't exist" do
      user = Flamethrower::Irc::User.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
      @server.current_user = user
      message = Flamethrower::Irc::Message.new("JOIN #foobar\r\n")
      @server.should_receive(:send_message).with(":#{user.hostname} 475")
      @server.should_not_receive(:send_topic)
      @server.should_not_receive(:send_userlist)
      @dispatcher.handle_message(message)
    end

    it "sends a join command to the API" do
      message = Flamethrower::Irc::Message.new("JOIN #flamethrower\r\n")
      @room.should_receive(:join)
      @dispatcher.handle_message(message)
    end
  end

  context "after a nick and user has been set" do
    before do
      @user_message = Flamethrower::Irc::Message.new("USER guest tolmoon tolsun :Ronnie Reagan\r\n")
      @nick_message = Flamethrower::Irc::Message.new("NICK WiZ\r\n")
    end

    describe "nick sent first" do
      it "sends the motd, join" do
        @dispatcher.server.should_receive(:after_connect)
        @dispatcher.handle_message(@nick_message)
        @dispatcher.handle_message(@user_message)
      end

      it "doesn't send after_connect if only the nick has been sent" do
        @dispatcher.server.should_not_receive(:after_connect)
        @dispatcher.handle_message(@nick_message)
      end

    end

    describe "user sent first" do
      it "sends the motd" do
        @dispatcher.server.should_receive(:after_connect)
        @dispatcher.handle_message(@user_message)
        @dispatcher.handle_message(@nick_message)
      end

      it "doesn't send after_connect if only the nick has been sent" do
        @dispatcher.server.should_not_receive(:after_connect)
        @dispatcher.handle_message(@user_message)
      end

    end
  end

end
