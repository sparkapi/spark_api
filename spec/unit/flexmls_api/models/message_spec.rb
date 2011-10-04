require './spec/spec_helper'


describe Message do
  before(:each) do
    stub_auth_request
  end
  
  subject do
    m = Message.new
    m.attributes["Type"] = "ShowingRequest"
    m.attributes["EventDateTime"] = "2011-09-15T14:00:00"
    m.attributes["SenderId"] = "20110112234857732941000000"
    m.attributes["Subject"] = "Showing Request For 123 Main St, MLS # 12-345"
    m.attributes["Body"] = "A showing is requested for ..."
    m.attributes["ListingId"] = "20110112234857732941000000"
    m
  end   
  
  it "should get all my messages"

  it "should get a single message"

  it "should save a new message" do
    stub_api_post("/messages", 'messages/new.json', 'messages/post.json')
    subject.save.should be(true)
  end

  it "should save a new message with recipients" do
    stub_api_post("/messages", 'messages/new_with_recipients.json', 'messages/post.json')
    subject.attributes["Recipients"] =  ["20110112234857732941000000","20110092234857738467000000"]
    subject.save.should be(true)
  end

  it "should fail saving" do
    stub_api_post("/messages", 'messages/new_empty.json') do |request|
      request.to_return(:status => 400, :body => fixture('errors/failure.json'))
    end
    m=subject.class.new
    m.save.should be(false)
    expect{ m.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 400 }
  end

end
