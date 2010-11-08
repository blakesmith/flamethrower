require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::Dispatcher do
  before do
    @server = Flamethrower::MockServer.new(Logger.new("/dev/null"))
    @channel = Flamethrower::IrcChannel.new("#flamethrower")
    @server.channels << @channel
    @dispatcher = Flamethrower::Dispatcher.new(@server)
  end

  describe "#handle_message" do
    it "sends the message to the right command handler method" do
      message = Flamethrower::Message.new("USER stuff\r\n")
      @dispatcher.should_receive(:handle_user).with(message)
      @dispatcher.handle_message(message)
    end

    it "doesn't send the message to the handler method if the method doesn't exist" do
      message = Flamethrower::Message.new("BOGUS stuff\r\n")
      @dispatcher.should_not_receive(:BOGUS)
      @dispatcher.handle_message(message)
    end
  end

  describe "#user" do
    it "sets the current session's user to the specified user" do
      message = Flamethrower::Message.new("USER guest tolmoon tolsun :Ronnie Reagan\r\n")
      @dispatcher.handle_message(message)
      @dispatcher.server.current_user.username.should == "guest"
      @dispatcher.server.current_user.hostname.should == "tolmoon"
      @dispatcher.server.current_user.servername.should == "tolsun"
      @dispatcher.server.current_user.realname.should == "Ronnie Reagan"
    end

    it "not set a second user request if a first has already been recieved" do
      message = Flamethrower::Message.new("USER guest tolmoon tolsun :Ronnie Reagan\r\n")
      message2 = Flamethrower::Message.new("USER guest2 tolmoon2 tolsun2 :Ronnie Reagan2\r\n")
      @dispatcher.handle_message(message)
      @dispatcher.handle_message(message2)
      @dispatcher.server.current_user.username.should == "guest"
      @dispatcher.server.current_user.hostname.should == "tolmoon"
      @dispatcher.server.current_user.servername.should == "tolsun"
      @dispatcher.server.current_user.realname.should == "Ronnie Reagan"
    end
  end

  describe "#mode" do
    before do
      @user = Flamethrower::IrcUser.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
      @server.current_user = @user
    end

    context "channel mode" do
      it "responds to mode with a static channel mode" do
        @server.channels << Flamethrower::IrcChannel.new("#flamethrower")
        message = Flamethrower::Message.new("MODE #flamethrower\r\n")
        @dispatcher.server.should_receive(:send_message).with(":host 324 nick #flamethrower +t")
        @dispatcher.handle_message(message)
      end

      it "responds with the user mode if the mode isn't for a channel" do
        message = Flamethrower::Message.new("MODE #{@user.nickname} +i\r\n")
        @dispatcher.server.should_receive(:send_message).with(":#{@user.hostname} 221 #{@user.nickname} +i")
        @dispatcher.handle_message(message)
      end

      it "responds with unknown command if the mode is neither a server nor the current user" do
        message = Flamethrower::Message.new("MODE foo\r\n")
        @dispatcher.server.should_receive(:send_message).with(":#{@user.hostname} 421 #{@user.nickname}")
        @dispatcher.handle_message(message)
      end
    end
  end

  describe "#nick" do
    it "sets the current session's user nickname to the specified nick" do
      message = Flamethrower::Message.new("NICK WiZ\r\n")
      @dispatcher.handle_message(message)
      @dispatcher.server.current_user.nickname.should == "WiZ"
    end
  end

  describe "#join" do
    it "responds with a topic and userlist if sent a join" do
      message = Flamethrower::Message.new("JOIN #flamethrower\r\n")
      @server.should_receive(:send_topic).with(@channel)
      @server.should_receive(:send_userlist)
      @dispatcher.handle_message(message)
    end

    it "adds the current user to the channel" do
      user = Flamethrower::IrcUser.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
      @server.current_user = user
      message = Flamethrower::Message.new("JOIN #flamethrower\r\n")
      @dispatcher.handle_message(message)
      @channel.users.should include(user)
    end

    it "responds with ERR_BADCHANNELKEY a channel that doesn't exist" do
      user = Flamethrower::IrcUser.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
      @server.current_user = user
      message = Flamethrower::Message.new("JOIN #foobar\r\n")
      @server.should_receive(:send_message).with(":#{user.hostname} 475")
      @server.should_not_receive(:send_topic)
      @server.should_not_receive(:send_userlist)
      @dispatcher.handle_message(message)
    end
  end

  context "after a nick and user has been set" do
    before do
      @user_message = Flamethrower::Message.new("USER guest tolmoon tolsun :Ronnie Reagan\r\n")
      @nick_message = Flamethrower::Message.new("NICK WiZ\r\n")
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
