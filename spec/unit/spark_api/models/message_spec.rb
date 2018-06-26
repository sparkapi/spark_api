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

  context "/messages", :support do
    on_get_it "should get all my messages" do
      stub_api_get("/messages", 'messages/get.json')
      messages = Message.find(:all)
      expect(messages.size).to eq(2)
    end

    on_post_it "should save a new message" do
      stub_api_post("/messages", 'messages/new.json', 'messages/post.json')
      expect(subject.save).to be(true)
    end

    on_post_it "should save a new message with recipients" do
      stub_api_post("/messages", 'messages/new_with_recipients.json', 'messages/post.json')
      subject.attributes["Recipients"] =  ["20110112234857732941000000","20110092234857738467000000"]
      expect(subject.save).to be(true)
    end

    on_post_it "should fail saving" do
      stub_api_post("/messages", 'messages/new_empty.json') do |request|
        request.to_return(:status => 400, :body => fixture('errors/failure.json'))
      end
      m=subject.class.new
      expect(m.save).to be(false)
      expect{ m.save! }.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to eq(400) }
    end
  end

  context "/messages/<message_id>", :support do
    on_get_it "should get a single message" do
      subject.attributes["Id"] = "20110353423434130982000000"
      stub_api_get("/messages/#{subject.Id}", "messages/get.json")
      expect(subject).to be_a(Message)
    end
  end

  context "/messages/<message_id>/replies", :support do
    on_get_it "should get all the replies" do
      subject.attributes["Id"] = "20110353423434130982000000"
      stub_api_get("/messages/#{subject.Id}/replies", "messages/get.json", :_expand => 'Body, Sender')
      expect(subject.replies.size).to eq(2)
    end

  end

  context "/messages/unread", :support do

    on_get_it "gets unread messages" do
      stub_api_get("/messages/unread", 'messages/get.json', {})
      messages = Message.unread
      messages.size.should == 2
      messages.first.should be_a Message
    end

    on_get_it "gets unread messages count" do
      stub_api_get("/messages/unread", 'messages/count.json', _pagination: 'count')
      Message.unread_count.should == 78
    end

  end

end
