require 'spec_helper'

describe SparkApi::Authentication::SingleSessionProvider do
  subject { SparkApi::Authentication::SingleSessionProvider.new({ :access_token => "the_token" }) }
  it "should initialize a new session with access_token" do
    expect(subject.load_session).to respond_to(:access_token)
    expect(subject.load_session.access_token).to eq("the_token")
  end
end
