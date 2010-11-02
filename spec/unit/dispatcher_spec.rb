require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::Dispatcher do
  before do
    @dispatcher = Flamethrower::Dispatcher.new
  end

  describe "#handle_message" do
    it "sends the message to the right command handler method" do
      message = Flamethrower::Message.new("USER stuff")
      @dispatcher.should_receive(:user).with(message)
      @dispatcher.handle_message(message)
    end
  end
end
