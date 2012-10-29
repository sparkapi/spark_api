require 'spec_helper'

describe Subscription do

  it "responds to crud methods" do
    Subscription.should respond_to(:get)
    Subscription.new.should respond_to(:save)
    Subscription.new.should respond_to(:delete)
  end

  before :each do
    stub_auth_request
  end

  let(:id){ "20101230223226074204000000" }

  context "/subscriptions", :support do

    on_get_it "should get sum subscriptions" do
      stub_api_get("/subscriptions", "subscriptions/get.json")
      subject.class.get
    end

    on_post_it "should create a new subscription" do
      @subscription = Subscription.new({
        :Name => "A new subscription name",
        :SearchId => "20101230223226074204000000",
        :RecipientIds => [ "20101230223226074204000000" ],
        :Subject => "my subject",
        :Message => "my message"
      })
      stub_api_post("/subscriptions", 'subscriptions/new.json', 'subscriptions/post.json')
      @subscription.save.should be(true)
      @subscription.persisted?.should eq(true)
    end

    it "should subscribe a contact by id" do
      stub_api_get("/subscriptions/#{id}", "subscriptions/get.json")
      stub_api_put("/subscriptions/#{id}/subscribers/20101230223226074306000000", nil, 'subscriptions/subscribe.json')
      resource = subject.class.find(id)
      resource.subscribe("20101230223226074306000000")
      resource.RecipientIds.size.should eq(2)
      resource.RecipientIds.any? { |c| c == "20101230223226074306000000" }.should eq(true)
    end

    it "should unsubscribe a contact by id" do
      stub_api_get("/subscriptions/#{id}", "subscriptions/get.json")
      stub_api_delete("/subscriptions/#{id}/subscribers/20101230223226074307000000", 'generic_delete.json')
      resource = subject.class.find(id)
      resource.unsubscribe("20101230223226074307000000")
      resource.RecipientIds.size.should eq(0)
    end

    it "should subscribe a contact by Contact object" do
      stub_api_get("/subscriptions/#{id}", "subscriptions/get.json")
      stub_api_put("/subscriptions/#{id}/subscribers/20101230223226074306000000", nil, 'subscriptions/subscribe.json')
      resource = subject.class.find(id)
      resource.subscribe(Contact.new({ :Id => "20101230223226074306000000" }))
      resource.RecipientIds.size.should eq(2)
      resource.RecipientIds.any? { |c| c == "20101230223226074306000000" }.should eq(true)
    end

    it "should unsubscribe a contact by Contact object" do
      stub_api_get("/subscriptions/#{id}", "subscriptions/get.json")
      stub_api_delete("/subscriptions/#{id}/subscribers/20101230223226074307000000", 'generic_delete.json')
      resource = subject.class.find(id)
      resource.unsubscribe(Contact.new({ :Id => "20101230223226074307000000" }))
      resource.RecipientIds.size.should eq(0)
    end

    it "should initialize RecipientIds as an array if nil" do
      stub_api_get("/subscriptions/#{id}", "subscriptions/get.json")
      stub_api_put("/subscriptions/#{id}/subscribers/20101230223226074306000000", nil, 'subscriptions/subscribe.json')
      resource = subject.class.find(id)
      resource.RecipientIds = nil
      resource.subscribe(Contact.new({ :Id => "20101230223226074306000000" }))
      resource.RecipientIds.size.should eq(1)
    end

  end

  context "/subscriptions/:id", :support do

    on_get_it "should get a subscription" do
      stub_api_get("/subscriptions/#{id}", "subscriptions/get.json")
      subject.class.find(id)
    end

    on_put_it "should update a subscription" do
      stub_api_get("/subscriptions/#{id}", 'subscriptions/get.json')
      stub_api_put("/subscriptions/#{id}", 'subscriptions/update.json', 'subscriptions/post.json')
      resource = subject.class.find(id)
      resource.Name = "A new subscription name"
      resource.save.should be(true)
    end

    on_delete_it "should delete a subscription" do
      stub_api_get("/subscriptions/#{id}", 'subscriptions/get.json')
      stub_api_delete("/subscriptions/#{id}", 'generic_delete.json')
      resource = subject.class.find(id)
      resource.delete
    end

  end

end
