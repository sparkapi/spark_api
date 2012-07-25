require './spec/spec_helper'

describe SparkApi::OptionsHash do
  it "should convert symbol parameters to a string" do
    h = {:parameter_one => 1,
         "parameter_two" => 2,
         3 => 3}
    o_h = SparkApi::OptionsHash.new(h)
    o_h.keys.size.should eq(3)
    o_h["parameter_one"].should eq(1)
    o_h["parameter_two"].should eq(2)
    o_h[3].should eq(3)
  end
end
