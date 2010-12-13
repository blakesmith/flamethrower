require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Irc::User do
  before do
    @user = Flamethrower::Irc::User.new
    @initial_user = Flamethrower::Irc::User.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
  end

  context "storing initial arguments" do
    it "should have user" do
      @initial_user.username.should == "user"
    end

    it "should have nick" do
      @initial_user.nickname.should == "nick"
    end

    it "should have host" do
      @initial_user.hostname.should == "host"
    end

    it "should have realname" do
      @initial_user.realname.should == "realname"
    end

    it "should have servername" do
      @initial_user.servername.should == "servername"
    end
  end

  describe "#nick_set?" do
    it "returns true if nickname is set" do
      user = Flamethrower::Irc::User.new :nickname => "nick"
      user.nick_set?.should be_true
    end

    it "returns false if nickname is not set" do
      Flamethrower::Irc::User.new.nick_set?.should be_false
    end
  end

  describe "#user_set?" do
    it "returns true if username, hostname, realname, servername are set" do
      user = Flamethrower::Irc::User.new :username => "user", :hostname => "host", :realname => "realname", :servername => "servername"
      user.user_set?.should be_true
    end

    it "returns true if username, hostname, realname, servername are set" do
      Flamethrower::Irc::User.new.user_set?.should be_false
    end
  end

  describe "#to_s" do
    it "should display the correct irc user string" do
      @initial_user.to_s.should == "nick!user@host"
    end
  end

  it "displays user mode given an array of modes" do
    @user.mode.should == "+i"
  end

end
