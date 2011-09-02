require './spec/spec_helper'

describe FlexmlsApi::Authentication::BaseAuth  do
  subject {FlexmlsApi::Authentication::BaseAuth.new(nil) }
  it "should raise an error" do
    expect {subject.authenticate()}.to raise_error(){ |e| e.message.should == "Implement me!"}
    expect {subject.logout()}.to raise_error(){ |e| e.message.should == "Implement me!"}
    expect {subject.request(nil, nil, nil, nil)}.to raise_error(){ |e| e.message.should == "Implement me!"}
  end
end
