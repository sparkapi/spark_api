require './spec/spec_helper'


describe Constraint do
  
  subject do
    Constraint.new(
      "RuleValue" => 1000000.0,
      "Value" => 1000001.0,
      "RuleFieldValue" => 1.0,
      "RuleField" => "ListPrice",
      "RuleName" => "MaxValue")
  end
  
  it "should print to string" do
    subject.to_s.should eq("MaxValue: Field(ListPrice,1.0) Value(1000000.0,1000001.0)")
  end

end
