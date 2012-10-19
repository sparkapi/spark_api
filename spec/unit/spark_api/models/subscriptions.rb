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

    on_get_it "should get sum subscriptions"

    on_post_it "should create a new subscription" do
      stub_api_post("/subscriptions", @subscription.attributes.as_json, 'subscriptions/post.json')
      subject.save.should be(true)
      subject.persisted?.should eq(true)
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
      resource = subject.class.get
      resource.Name = "A new subscription name"
      subject.save.should be(true)
    end

    on_delete_it "should delete a subscription" do
      stub_api_get("/subscriptions/#{id}", 'subscriptions/get.json')
      stub_api_delete("/subscriptions/#{id}", 'generic_delete.json')
      resource = subject.class.get
      resource.delete
    end

  end

end
