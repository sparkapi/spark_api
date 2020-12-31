require './spec/spec_helper'

describe SparkApi::Authentication::BaseAuth  do
  subject {SparkApi::Authentication::BaseAuth.new(nil) }
  it "should raise an error" do
    expect {subject.authenticate()}.to raise_error(){ |e| expect(e.message).to eq("Implement me!")}
    expect {subject.logout()}.to raise_error(){ |e| expect(e.message).to eq("Implement me!")}
    expect {subject.request(nil, nil, nil, nil)}.to raise_error(){ |e| expect(e.message).to eq("Implement me!")}
  end
end
