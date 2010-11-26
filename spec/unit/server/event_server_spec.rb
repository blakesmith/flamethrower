require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::EventServer do
  before do
    @event_server = Flamethrower::EventServer.new("0.0.0.0", 6667, "mydomain", "mytoken")
  end

  it "initializes the host" do
    @event_server.host.should == "0.0.0.0"
  end

  it "initializes the port" do
    @event_server.port.should == 6667
  end

end
