require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::Room do
  before do
    @connection = Flamethrower::MockServer.new
    @room = Flamethrower::Campfire::Room.new("mydomain", "mytoken", "id" => 347348, "topic" => "some topic", "name" => "some name")
    @room.connection = @connection
    @user = Flamethrower::Campfire::User.new('name' => "bob", 'id' => 489198)
    @user2 = Flamethrower::Campfire::User.new('name' => "bill", 'id' => 123456)
  end

  describe "params" do
    it "has number" do
      @room.number.should == 347348
    end
    
    it "has name" do
      @room.name.should == "some name"
    end
  end

  describe "#topic" do
    it "has topic" do
      @room.topic.should == "some topic"
    end

    it "displays 'No topic' if the topic is nil" do
      @room.topic = nil
      @room.topic.should == "No topic"
    end
  end

  describe "#on_reconnect" do
    it "writes to the log that it reconnected" do
      message = "Reconnected to some name stream"
      ::FLAMETHROWER_LOGGER.should_receive(:debug).with(message)

      @room.on_reconnect
    end
  end

  describe "#on_max_reconnects" do
    before do
      @room.instance_variable_set("@stream", mock(:stream))
    end

    it "writes to the log that it has failed to reconnect" do
      @room.stub(:setup_reconnect)
      message = "Failed to reconnect to some name, restarting room in 20 seconds"
      ::FLAMETHROWER_LOGGER.should_receive(:debug).with(message)

      @room.on_max_reconnects
    end
  end

  describe "#on_error" do
    it "writes to the log that there was an error" do
      message = "There was an error connecting to some name stream"
      ::FLAMETHROWER_LOGGER.should_receive(:debug).with(message)

      @room.on_error
    end
  end

  describe "#send_topic!" do
    it "sets the topic when the campfire API returns 200" do
      stub_request(:put, "https://mydomain.campfirenow.com/room/347348.json").
        with(:headers => {'Authorization'=>['mytoken', 'x'], 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => json_fixture("room_update"))
      EM.run_block { @room.send_topic("some updated topic") }
      @room.topic.should == "some updated topic"
    end

    it "keeps the previous topic when the campfire API returns non 200" do
      stub_request(:put, "https://mydomain.campfirenow.com/room/347348.json").
        with(:headers => {'Authorization'=>['mytoken', 'x'], 'Content-Type'=>'application/json'}).
        to_return(:status => 400, :body => json_fixture("room_update"))
      @room.instance_variable_set("@topic", "some old topic")
      EM.run_block { @room.send_topic("some updated topic") }
      @room.topic.should == "some old topic"
    end
  end

  describe "#stop" do
    it "should stop the stream" do
      EventMachine.stub(:cancel_timer)
      @room.instance_variable_set("@stream", mock(:stream, :stop => nil))
      @room.stream.should_receive(:stop)
      @room.stop
    end

    it "should cancel the timers" do
      timer = mock(:timer)
      @room.instance_variable_set("@polling_timer", timer)
      @room.instance_variable_set("@periodic_timer", timer)
      EventMachine.should_receive(:cancel_timer).with(timer).twice
      @room.stop
    end

    it "should flip all the appropriate stop booleans" do
      EventMachine.stub(:cancel_timer)
      @room.stop
      @room.should_not be_alive
      @room.instance_variable_get("@room_info_set").should be_false
    end
  end

  describe "#fetch_room_info" do
    before do
      stub_request(:get, "https://mydomain.campfirenow.com/room/347348.json").
        with(:headers => {'Authorization'=>['mytoken', 'x']}).
        to_return(:status => 200, :body => json_fixture("room"))
    end

    it "retrieves a list of users and stores them as user objects" do
      EM.run_block { @room.fetch_room_info }
      @room.users.all? {|u| u.is_a?(Flamethrower::Campfire::User)}.should be_true
    end

    it "doesn't send the room join info if the room has already been joined" do
      @room.instance_variable_set("@room_info_sent", true)
      @room.should_not_receive(:send_info)
      EM.run_block { @room.fetch_room_info }
    end

    it "makes the http request with a token in basic auth" do
      EM.run_block { @room.fetch_room_info }
      assert_requested(:get, "https://mydomain.campfirenow.com/room/347348.json") {|req| req.headers['Authorization'].should == ["mytoken", "x"]}
    end
  end

  describe "#resolve renames" do
    it "calls 'send_rename' for each user who's name has changed" do
      blake = Flamethrower::Campfire::User.new('id' => 1, 'name' => 'blake')
      bob = Flamethrower::Campfire::User.new('id' => 2, 'name' => 'bob')
      bill = Flamethrower::Campfire::User.new('id' => 3, 'name' => 'bill')
      old_users = [blake, bob, bill]

      blake2 = blake.dup
      bob2 = bob.dup

      blake2.name = "Blake Smith"
      bob2.name = "Bob Hope"
      new_users = [blake2, bob2, bill]

      @room.connection.should_receive(:send_rename).with("blake", "Blake_Smith")
      @room.connection.should_receive(:send_rename).with("bob", "Bob_Hope")
      @room.resolve_renames(old_users, new_users)
    end

    it "doesn't rename if old_users has a user that new_users doesn't" do
      blake = Flamethrower::Campfire::User.new('id' => 1, 'name' => 'blake')
      bob = Flamethrower::Campfire::User.new('id' => 2, 'name' => 'bob')
      bill = Flamethrower::Campfire::User.new('id' => 3, 'name' => 'bill')
      old_users = [blake, bob, bill]
      new_users = [blake, bob]

      @room.connection.should_not_receive(:send_rename)
      @room.resolve_renames(old_users, new_users)
    end
  end

  describe "#fetch_images" do
    it "makes a call to the image ascii service to convert the image" do
      stub_request(:get, "http://skeeter.blakesmith.me/?image_url=http://example.com/kitties.jpg&width=80").
        to_return(:status => 200, :body => "LOLCAT ASCII ART HERE!")
      @message = Flamethrower::Campfire::Message.new(JSON.parse(json_fixture("streaming_image_message")))
      @room.instance_variable_get("@images_to_fetch") << @message
      EM.run_block { @room.fetch_images }
      expected_body = "http://example.com/kitties.jpg\n"
      expected_body << "LOLCAT ASCII ART HERE!"
      @message.body.should == expected_body
    end

    context "when the image get call fails" do
      it "marks the message as failed and puts it into the failed messages" do
        stub_request(:get, "http://skeeter.blakesmith.me/?image_url=http://example.com/kitties.jpg&width=80").
          to_return(:status => 400, :body => "An error has occured")
        @message = Flamethrower::Campfire::Message.new(JSON.parse(json_fixture("streaming_image_message")))
        @message.user = mock('user')
        @room.instance_variable_get("@images_to_fetch") << @message
        EM.run_block { @room.fetch_images }
        @room.instance_variable_get("@failed_messages").size.should == 1
      end
    end
  end

  describe "#fetch_users" do
    it "makes a call to the campfire api to fetch user information" do
      stub_request(:get, "https://mydomain.campfirenow.com/users/734581.json").
        with(:headers => {'Authorization'=>['mytoken', 'x']}).
        to_return(:status => 200, :body => json_fixture("user"))
      @room.instance_variable_get("@users_to_fetch") << Flamethrower::Campfire::Message.new(JSON.parse(json_fixture("enter_message")))
      EM.run_block { @room.fetch_users }
      @room.users.map(&:name).should == ["blake"]
    end

    it "fetches using the 'user_id' field if a streaming message" do
      stub_request(:get, "https://mytoken:x@mydomain.campfirenow.com/users/734581.json").to_return(:body => json_fixture("user"), :status => 200)
      @room.instance_variable_get("@users_to_fetch") << Flamethrower::Campfire::Message.new(JSON.parse(json_fixture("enter_message")))
      @room.should_receive(:campfire_get).with("/users/734581.json").and_return(mock(:post, :callback => nil))
      EM.run_block { @room.fetch_users }
    end

    context "successfully get user info" do
      it "enqueues an EnterMessage into @inbound_messages for displaying in irc" do
        stub_request(:get, "https://mydomain.campfirenow.com/users/734581.json").
          with(:headers => {'Authorization'=>['mytoken', 'x']}).
          to_return(:status => 200, :body => json_fixture("user"))
        json = JSON.parse(json_fixture('enter_message'))
        json['direction'] = 'inbound'
        @room.instance_variable_get("@users_to_fetch") << Flamethrower::Campfire::Message.new(json)
        EM.run_block { @room.fetch_users }
        message = @room.inbound_messages.pop.user.number.should == 734581
      end
    end

    context "fails to get user info" do
      it "doesn't enqueue an EnterMessage" do
        stub_request(:get, "https://mydomain.campfirenow.com/users/734581.json").
          with(:headers => {'Authorization'=>['mytoken', 'x']}).
          to_return(:status => 400, :body => json_fixture("user"))
        @room.instance_variable_get("@users_to_fetch") << Flamethrower::Campfire::Message.new(JSON.parse(json_fixture("enter_message")))
        EM.run_block { @room.fetch_users }
        message = @room.inbound_messages.size.should == 0
      end

      it "marks the message as failed and puts it into failed messages" do
        stub_request(:get, "https://mydomain.campfirenow.com/users/734581.json").
          with(:headers => {'Authorization'=>['mytoken', 'x']}).
          to_return(:status => 400, :body => json_fixture("user"))
        @room.instance_variable_get("@users_to_fetch") << Flamethrower::Campfire::Message.new(JSON.parse(json_fixture("enter_message")))
        EM.run_block { @room.fetch_users }
        message = @room.instance_variable_get("@failed_messages").size.should == 1
      end
    end
  end

  describe "#join" do
    it "returns true when posting to the room join call succeeds" do
      stub_request(:post, "https://mydomain.campfirenow.com/room/347348/join.json").
        with(:headers => {'Authorization'=>['mytoken', 'x'], 'Content-Type'=>'application/json'}).
        to_return(:status => 200)
      EM.run_block { @room.join }
      @room.joined.should be_true
    end

    it "returns false when posting to the room join call fails" do
      stub_request(:post, "https://mydomain.campfirenow.com/room/347348/join.json").
        with(:headers => {'Authorization'=>['mytoken', 'x'], 'Content-Type'=>'application/json'}).
        to_return(:status => 400)
      EM.run_block { @room.join }
      @room.joined.should be_false
    end
  end

  describe "#connect" do
    it "initializes the twitter jsonstream with the right options" do
      stream = mock(:stream, :on_reconnect => nil, :on_error => nil, :on_max_reconnects => nil)
      Twitter::JSONStream.should_receive(:connect).with(:path => "/room/347348/live.json", :host => "streaming.campfirenow.com", :auth => "mytoken:x").and_return(stream)
      @room.connect
    end

    it "sets up the stream callbacks" do
      stream = mock(:stream, :on_reconnect => nil, :on_error => nil, :on_max_reconnects => nil)
      Twitter::JSONStream.should_receive(:connect).with(:path => "/room/347348/live.json", :host => "streaming.campfirenow.com", :auth => "mytoken:x").and_return(stream)

      @room.should_receive(:setup_stream_callbacks)
      @room.connect
    end
  end

  describe "#fetch_messages" do
    before do
      stream = mock(:stream, :on_reconnect => nil, :on_error => nil, :on_max_reconnects => nil)
      Twitter::JSONStream.stub(:connect).and_return(stream)
      @item = json_fixture("streaming_message")
      @room.users << @user
      @room.connect
      @room.stream.stub(:each_item).and_yield(@item)
    end

    it "iterates over each stream item and sends to the message queue" do
      @room.fetch_messages
      @room.inbound_messages.size.should == 1
    end

    it "maps the message body to a message object with the right body" do
      @room.fetch_messages
      @room.inbound_messages.pop.body.should == "yep"
    end

    it "maps the message sender to the right user" do
      @room.users << @user2
      @room.fetch_messages
      @room.inbound_messages.pop.user.should == @user
    end

    it "maps the message room to the right room" do
      @room.fetch_messages
      @room.inbound_messages.pop.room.should == @room
    end

    it "marks the message as inbound" do
      @room.fetch_messages
      @room.inbound_messages.pop.should be_inbound
    end

    it "discards timestamp messages altogether" do
      item = json_fixture("timestamp_message")
      @room.stream.stub(:each_item).and_yield(item)
      @room.fetch_messages
      @room.instance_variable_get("@inbound_messages").size.should == 0
      @room.instance_variable_get("@users_to_fetch").size.should == 0
    end

    it "puts messages that don't have an existing user into the users_to_fetch queue" do
      enter_message = JSON.parse(json_fixture("streaming_message"))
      enter_message['user_id'] = 98765
      @room.stream.stub(:each_item).and_yield(enter_message.to_json)
      @room.fetch_messages
      @room.instance_variable_get("@users_to_fetch").size.should == 1
      @room.instance_variable_get("@inbound_messages").size.should == 0
    end

    it "puts messages that have an image url in the into the images_to_fetch queue" do
      image_message = json_fixture("streaming_image_message")
      @room.stream.stub(:each_item).and_yield(image_message)
      @room.fetch_messages
      @room.instance_variable_get("@inbound_messages").size.should == 0
      @room.instance_variable_get("@images_to_fetch").size.should == 1
    end

    it "doesn't make the call to the image ascii service if the option is disabled" do
      @room.connection.server.ascii_conversion['enabled'] = false
      image_message = json_fixture("streaming_image_message")
      @room.stream.stub(:each_item).and_yield(image_message)
      @room.fetch_messages
      @room.instance_variable_get("@users_to_fetch").size.should == 0
      @room.instance_variable_get("@images_to_fetch").size.should == 0
      @room.instance_variable_get("@inbound_messages").size.should == 1
    end
  end

  describe "#say" do
    it "queues a campfire message given a message body" do
      @room.say('Hello there')
      popped_message = @room.outbound_messages.pop
      popped_message.body.should == 'Hello there'
    end

    it "takes an optional message type" do
      @room.say('Hello there', 'TextMessage')
      popped_message = @room.outbound_messages.pop
      popped_message.message_type.should == 'TextMessage'
    end

    it "marks the message as an outbound message" do
      @room.say('Hello there', 'TextMessage')
      popped_message = @room.outbound_messages.pop
      popped_message.should be_outbound
    end
  end

  describe "#translate_nicknames" do
    it "changes an IRC highlighted name to the campfire name" do
      user = Flamethrower::Campfire::User.new('name' => "bob_hope", 'id' => 489198)
      user2 = Flamethrower::Campfire::User.new('name' => "bill_jones", 'id' => 123456)
      @room.users = [user, user2]
      message_body = "#{user2.to_irc.nickname}: Hello there!"
      @room.send(:translate_nicknames, message_body).should == "#{user2.name}: Hello there!"
    end

    it "doesn't change the message body if no user's name is present in the body" do
      user = Flamethrower::Campfire::User.new('name' => "bob_hope", 'id' => 489198)
      user2 = Flamethrower::Campfire::User.new('name' => "bill_jones", 'id' => 123456)
      @room.users = [user, user2]
      message_body = "Hello there!"
      @room.send(:translate_nicknames, message_body).should == "Hello there!"
    end
  end

  describe "#requeue_failed_messages" do
    it "queues an outbound message whos retry_at is greater than now" do
      Time.stub(:now).and_return(Time.parse("9:00AM"))
      message = Flamethrower::Campfire::Message.new('type' => 'TextMessage', 'body' => 'Hello there', 'user' => @user, 'room' => @room, 'direction' => 'outbound')
      message.retry_at = Time.parse("9:00:01AM")
      message.status = "failed"
      @room.failed_messages << message
      @room.requeue_failed_messages
      @room.outbound_messages.size.should == 1
      @room.failed_messages.size.should == 0
    end

    it "queues an inbound message whos retry_at is greater than now" do
      Time.stub(:now).and_return(Time.parse("9:00AM"))
      message = Flamethrower::Campfire::Message.new('type' => 'TextMessage', 'body' => 'Hello there', 'user' => @user, 'room' => @room, 'direction' => 'inbound')
      message.retry_at = Time.parse("9:00:01AM")
      message.status = "failed"
      @room.failed_messages << message
      @room.requeue_failed_messages
      @room.inbound_messages.size.should == 1
      @room.failed_messages.size.should == 0
    end

    it "doesn't queue a message whos retry_at is less than now" do
      Time.stub(:now).and_return(Time.parse("9:00AM"))
      message = Flamethrower::Campfire::Message.new('type' => 'TextMessage', 'body' => 'Hello there', 'user' => @user, 'room' => @room, 'direction' => 'outbound')
      message.retry_at = Time.parse("8:59AM")
      message.status = "failed"
      @room.failed_messages << message
      @room.requeue_failed_messages
      @room.outbound_messages.size.should == 0
      @room.failed_messages.size.should == 1
    end

    it "marks the message as pending when it requeues" do
      Time.stub(:now).and_return(Time.parse("9:00AM"))
      message = Flamethrower::Campfire::Message.new('type' => 'TextMessage', 'body' => 'Hello there', 'user' => @user, 'room' => @room, 'direction' => 'inbound')
      message.mark_failed!
      @room.failed_messages << message
      @room.requeue_failed_messages
      message.should be_pending
    end
  end

  describe "#post_messages" do
    it "pops the message off the queue and posts it to the campfire api" do
     stub_request(:post, "https://mydomain.campfirenow.com/room/347348/speak.json").
       with(:headers => {'Authorization'=>['mytoken', 'x'], 'Content-Type'=>'application/json'}).
       to_return(:status => 200, :body => json_fixture("speak_message"))
      message = Flamethrower::Campfire::Message.new('type' => 'TextMessage', 'body' => 'Hello there', 'user' => @user, 'room' => @room)
      @room.outbound_messages << message
      EM.run_block { @room.post_messages }
      @room.outbound_messages.size.should == 0
    end

    it "adds the message to the failed_messages array if it fails to post to the campfire API" do
      stub_request(:post, "https://mydomain.campfirenow.com/room/347348/speak.json").
        with(:headers => {'Authorization'=>['mytoken', 'x'], 'Content-Type'=>'application/json'}).
        to_return(:status => 400, :body => json_fixture("speak_message"))
      
      message = Flamethrower::Campfire::Message.new('type' => 'TextMessage', 'body' => 'Hello there', 'user' => @user, 'room' => @room)
      @room.outbound_messages << message
      EM.run_block { @room.post_messages }
      @room.outbound_messages.size.should == 0
      @room.failed_messages.size.should == 1
    end

    it "marks the message as failed when not able to deliver" do
     stub_request(:post, "https://mydomain.campfirenow.com/room/347348/speak.json").
       with(:headers => {'Authorization'=>['mytoken', 'x'], 'Content-Type'=>'application/json'}).
       to_return(:status => 400, :body => json_fixture("speak_message"))
      
      message = Flamethrower::Campfire::Message.new('type' => 'TextMessage', 'body' => 'Hello there', 'user' => @user, 'room' => @room)
      @room.outbound_messages << message
      EM.run_block { @room.post_messages }
      message.status.should == "failed"
    end

    it "marks the message as delivered if successfully posted to campfire" do
     stub_request(:post, "https://mydomain.campfirenow.com/room/347348/speak.json").
       with(:headers => {'Authorization'=>['mytoken', 'x'], 'Content-Type'=>'application/json'}).
       to_return(:status => 201, :body => json_fixture("speak_message"))
      
      message = Flamethrower::Campfire::Message.new('type' => 'TextMessage', 'body' => 'Hello there', 'user' => @user, 'room' => @room)
      @room.outbound_messages << message
      EM.run_block { @room.post_messages }
      message.status.should == "delivered"
    end

    it "sends the right json" do
      stub_request(:post, "https://mytoken:x@mydomain.campfirenow.com/room/347348/speak.json").to_return(:body => json_fixture("speak_message"), :status => 201)
      message = Flamethrower::Campfire::Message.new('type' => 'TextMessage', 'body' => 'Hello there', 'user' => @user, 'room' => @room)
      @room.outbound_messages << message
      expected_json = {"message"=>{"body"=>"Hello there", "type"=>"TextMessage"}}.to_json
      @room.should_receive(:campfire_post).with("/room/#{@room.number}/speak.json", expected_json).and_return(mock(:post, :callback => nil))
      EM.run_block { @room.post_messages }
    end
  end

  describe "#to_irc" do
    it "returns an irc channel object" do
      @room.to_irc.is_a?(Flamethrower::Irc::Channel).should be_true
    end

    it "references the same room when doing conversions" do
      @room.to_irc.to_campfire.should == @room
    end

    it "sends the current campfire topic" do
      @room.to_irc.topic.should == @room.topic
    end

    it "replaces newlines with spaces" do
      @room.topic = "Some topic\nyeah"
      @room.to_irc.topic.should == "Some topic yeah"
    end

    context "channel name" do
      it "maps the campfire room name to the channel name" do
        @room.name = "somename"
        @room.to_irc.name.should == "#somename"
      end

      it "downcases channel names" do
        @room.name = "Somename"
        @room.to_irc.name.should == "#somename"
      end

      it "separates replaces name spaces with underscores" do
        @room.name = "Some Name 1"
        @room.to_irc.name.should == "#some_name_1"
      end

      it "replaces slashes with underscores" do
        @room.name = "API/Mobile"
        @room.to_irc.name.should == "#api_mobile"
      end

      it "replaces ampersands with underscores" do
        @room.name = "Stuff & Something"
        @room.to_irc.name.should == "#stuff_something"
      end

    end

    context "populating users" do
      it "fills the irc channel's user array with mapped campfire users" do
        @room.users = [Flamethrower::Campfire::User.new('name' => "bob")]
        @room.to_irc.users.first.is_a?(Flamethrower::Irc::User).should be_true
      end
    end

  end
end
