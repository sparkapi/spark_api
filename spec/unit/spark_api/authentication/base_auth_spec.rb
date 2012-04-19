require './spec/spec_helper'

describe SparkApi::Authentication::BaseAuth  do
  subject {SparkApi::Authentication::BaseAuth.new(nil) }
  it "should raise an error" do
    expect {subject.authenticate()}.to raise_error(){ |e| e.message.should == "Implement me!"}
    expect {subject.logout()}.to raise_error(){ |e| e.message.should == "Implement me!"}
    expect {subject.request(nil, nil, nil, nil)}.to raise_error(){ |e| e.message.should == "Implement me!"}
  end
end
