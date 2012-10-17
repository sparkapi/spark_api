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

  subject do
    Subscription.new({
      :SearchId => 1,
      :RecipientIds => ["20000426173054342350000000"],
      :Subject => "Test subject",
      :Message => "This could be a message."
    })
  end

  context "/subscriptions", :support do
    on_get_it "should get sum subscriptions"

    on_post_it "should create a new subscription" do
      stub_api_post("/subscriptions", @subscription.attributes.as_json, 'subscriptions/post.json')
      subject.save.should be(true)
    end

    on_put_it "should update a subscription" do
      stub_api_put("/subscriptions", @subscription.attributes.as_json, 'subscriptions/post.json')
      subject.save.should be(true)
    end

  end

end
