require './spec/spec_helper'

describe SystemInfo do
  before(:each) do 
    @sysinfo = SystemInfo.new({
      "Name"=>"beh  apiuser", 
      "OfficeId"=>"20071029204441159539000000", 
      "Configuration"=>[{
        "IdxDisclaimer"=>""
      }], 
      "Id"=>"20101206154326670813000000", 
      "MlsId"=>"20000809145531659995000000", 
      "Office"=>"", 
      "Mls"=>"Fargo-Moorhead MLS"
    })
  end

  it "should respond to get" do
    SystemInfo.should respond_to(:get)
  end
  
  it "should have a primary_logo instance method" do
    @sysinfo.should respond_to(:primary_logo)
  end

  it "should respond to attributes" do
    ['Name','OfficeId','Id','MlsId','Office','Mls'].each do |k|
      (@sysinfo.send k.to_sym).should be_a(String)
    end
    @sysinfo.Configuration.should be_a(Array)
  end

  it "should have an array of config items" do
    @sysinfo.Configuration.should be_a(Array)
  end

  describe "#primary_logo" do
    before(:each) do
      @sysinfo_with_logos = SystemInfo.new({
        "Name"=>"Brandon  Reg1", 
        "OfficeId"=>"20080904154102121828000000", 
        "Configuration"=>[{
          "MlsLogos"=>[
            {"Uri"=>"http://images.dev.fbsdata.com/eup/20110406184939446866000000.jpg", "Name:"=>"logo and stuff"}, 
            {"Uri"=>"http://images.dev.fbsdata.com/eup/20110406191929838053000000.jpg", "Name:"=>"tried it"}
          ], 
          "IdxDisclaimer"=>"", 
          "IdxLogoSmall"=>"", 
          "IdxLogo"=>"http://images.dev.fbsdata.com/eup/20110406184939446866000000.jpg"
        }], 
        "Id"=>"20080904155327755059000000", 
        "MlsId"=>"20041217205818829687000000", 
        "Office"=>"Brandon Office1", 
        "Mls"=>"Eastern Upper Peninsula"
      })
    end 

    it "should return nil when no logo is present" do
      @sysinfo.primary_logo.should == nil
    end

    it "should return the first logo when several are present" do
      @sysinfo_with_logos.primary_logo.should be_a(Hash)
    end 
  end

  after(:each) do 
    @sysinfo = nil
  end

end
