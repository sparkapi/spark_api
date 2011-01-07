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
  
  it "should respond to attributes" do
    ['Name','OfficeId','Id','MlsId','Office','Mls'].each do |k|
      (@sysinfo.send k.to_sym).should be_a String
    end
    @sysinfo.Configuration.should be_a Array
  end

  it "should have an array of config items" do
    @sysinfo.Configuration.should be_a Array
  end

  after(:each) do 
    @sysinfo = nil
  end

end
