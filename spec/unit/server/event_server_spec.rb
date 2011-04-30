require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::EventServer do
  before do
    options = {
      'host' => '0.0.0.0',
      'port' => 6667,
      'domain' => 'mydomain',
      'token' => 'token',
      'ascii_conversion' => {
        'service' => 'http://bloop.com',
        'scale_to_width' => 80
      }
    }

    @event_server = Flamethrower::EventServer.new(options)
  end

  it "initializes the host" do
    @event_server.host.should == "0.0.0.0"
  end

  it "initializes the port" do
    @event_server.port.should == 6667
  end

  it "initializes the ascii_conversion service" do
    @event_server.ascii_conversion['service'].should == "http://bloop.com"
  end

  it "initializes the ascii_conversion scale_to_width" do
    @event_server.ascii_conversion['scale_to_width'].should == 80
  end

end
