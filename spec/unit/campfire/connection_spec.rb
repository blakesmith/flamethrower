require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::Connection do
  before do
    @server = Flamethrower::MockServer.new
    @server.log = Logger.new("/dev/null")
    @connection = @server.campfire_connection
    FakeWeb.allow_net_connect = false
  end

  describe "#rooms" do
    it "retrieves a list of rooms from JSON" do
      FakeWeb.register_uri(:get, "https://mytoken:x@mydomain.campfirenow.com/rooms.json", :body => json_fixture("rooms"), :status => ["200", "OK"])
      room = @connection.rooms.first
      room.number.should == 347348
      room.name.should == "Room 1"
      room.topic.should == "some topic"
    end

    it "makes the http request with a token in basic auth" do
      FakeWeb.register_uri(:get, "https://mytoken:x@mydomain.campfirenow.com/rooms.json", :body => json_fixture("rooms"), :status => ["200", "OK"])
      @connection.rooms
      FakeWeb.last_request['authorization'].should == "Basic #{Base64::encode64("#{@connection.token}:x").chomp}"
    end

    it "returns empty set if not a successful response" do
      FakeWeb.register_uri(:get, "https://mytoken:x@mydomain.campfirenow.com/rooms.json", :status => ["400", "Bad Request"])
      @connection.rooms.should == []
    end

    it "sends a motd error message if unable to fetch room list" do
      @connection.should_receive(:campfire_get).and_raise(SocketError) 
      @server.should_receive(:send_message).with(@server.reply(Flamethrower::Irc::Codes::RPL_MOTD, ":ERROR: Unable to fetch room list! Check your connection?"))
      @connection.rooms.should == []
    end
  end

end
