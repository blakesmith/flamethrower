require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::CampfireConnection do
  before do
    @connection = Flamethrower::CampfireConnection.new("mydomain", "mytoken")
    FakeWeb.allow_net_connect = false
  end

  describe "#rooms" do
    it "retrieves a list of rooms from JSON" do
      FakeWeb.register_uri(:get, "https://mydomain.campfirenow.com/rooms.json", :body => json_fixture("rooms"), :status => ["200", "OK"])
      room = @connection.rooms.first
      room.number.should == 347348
      room.name.should == "Room 1"
    end

    it "returns empty set if not a successful response" do
      FakeWeb.register_uri(:get, "https://mydomain.campfirenow.com/rooms.json", :status => ["400", "Bad Request"])
      @connection.rooms.should == []
    end
  end
end
