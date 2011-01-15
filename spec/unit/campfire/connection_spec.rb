require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::Connection do
  before do
    @server = Flamethrower::MockServer.new
    @connection = @server.campfire_connection
  end

  describe "#rooms" do
    it "retrieves a list of rooms from JSON" do
      json = json_fixture("rooms")
      stub_request(:get, "https://mytoken:x@mydomain.campfirenow.com/rooms.json").to_return(:body => json, :status => 200)
      debugger
      room = @connection.rooms.first
      room.number.should == 347348
      room.name.should == "Room 1"
      room.topic.should == "some topic"
    end

    it "makes the http request with a token in basic auth" do
      stub_request(:get, "https://mytoken:x@mydomain.campfirenow.com/rooms.json").to_return(:body => json_fixture("rooms"), :status => 200)
      @connection.rooms
      assert_requested(:get, "https://mytoken:x@mydomain.campfirenow.com/rooms.json") {|req| req.uri.userinfo.should == "mytoken:x"}
    end

    it "returns empty set if not a successful response" do
      stub_request(:get, "https://mytoken:x@mydomain.campfirenow.com/rooms.json").to_return(:status => 400)
      @connection.rooms.should == []
    end

    it "sends a motd error message if unable to fetch room list" do
      @connection.should_receive(:campfire_get).and_raise(SocketError) 
      @server.should_receive(:send_message).with(@server.reply(Flamethrower::Irc::Codes::RPL_MOTD, ":ERROR: Unable to fetch room list! Check your connection?"))
      @connection.rooms.should == []
    end
  end

end
