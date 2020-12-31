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
    expect(SystemInfo).to respond_to(:get)
  end
  
  it "should have a primary_logo instance method" do
    expect(@sysinfo).to respond_to(:primary_logo)
  end

  it "should respond to attributes" do
    ['Name','OfficeId','Id','MlsId','Office','Mls'].each do |k|
      expect(@sysinfo.send k.to_sym).to be_a(String)
    end
    expect(@sysinfo.Configuration).to be_a(Array)
  end

  it "should have an array of config items" do
    expect(@sysinfo.Configuration).to be_a(Array)
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
      expect(@sysinfo.primary_logo).to eq(nil)
    end

    it "should return the first logo when several are present" do
      expect(@sysinfo_with_logos.primary_logo).to be_a(Hash)
    end 
  end

  context "/system", :support do
    on_get_it "should return system settings and configuration"
  end

  context "/system/languages", :support do
    on_get_it "should return a list of languages"
  end

  context "/system/accounts", :support do
    on_get_it "should return account metadata"
  end

  after(:each) do 
    @sysinfo = nil
  end

end
