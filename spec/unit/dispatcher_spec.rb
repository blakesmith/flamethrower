require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::Dispatcher do
  before do
    server = Flamethrower::MockServer.new
    @dispatcher = Flamethrower::Dispatcher.new(server)
  end

  describe "#handle_message" do
    it "sends the message to the right command handler method" do
      message = Flamethrower::Message.new("USER stuff\r\n")
      @dispatcher.should_receive(:user).with(message)
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
  end
end
