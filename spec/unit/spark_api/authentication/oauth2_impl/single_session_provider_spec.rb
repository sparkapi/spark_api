require 'spec_helper'

describe SparkApi::Authentication::SingleSessionProvider do
  subject { SparkApi::Authentication::SingleSessionProvider.new({ :access_token => "the_token" }) }
  it "should initialize a new session with access_token" do
    subject.load_session.should respond_to(:access_token)
    subject.load_session.access_token.should eq("the_token")
  end
end
