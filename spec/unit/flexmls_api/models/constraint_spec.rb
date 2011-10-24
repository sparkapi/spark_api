require './spec/spec_helper'


describe Constraint do
  
  subject do
    Constraint.new(
      "RuleValue" => 1,
      "Value" => 0,
      "RuleFieldValue" => nil,
      "RuleField" => nil,
      "RuleName" => "MinValue")
  end
  
  it "should print to string" do
    subject.to_s.should eq("The minimum value for this field is 1")
  end

end
