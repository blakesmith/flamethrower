require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::IrcUser do
  before do
    @user = Flamethrower::IrcUser.new
  end

  context "storing initial arguments" do
    before do
      @initial_user = Flamethrower::IrcUser.new :username => "user", :nickname => "nick", :hostname => "host", :realname => "realname", :servername => "servername"
    end

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

end
