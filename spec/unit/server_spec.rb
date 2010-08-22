require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::Server do
  before do
    @server = Object.new
    @server.extend Flamethrower::Server
    @server.stub!(:send_data)
    @server.stub!(:puts)
    @server.current_user = "blake"
  end

  context "when a user connects" do

    it "sends an auto-join" do
      @server.should_receive(:send_data).with("JOIN #flamethrower")
      @server.post_init
    end

    it "sends the current topic" do
      @server.should_receive(:send_data).with("RPL_TOPIC :Welcome to Flamethrower")
      @server.post_init
    end

    it "sends a list of users" do
      @server.campfire_users = ["joe", "bob"]
      @server.should_receive(:send_data).with("RPL_NAMEREPLY :#flamethrower @blake joe bob")
      @server.post_init
    end
  end

end
