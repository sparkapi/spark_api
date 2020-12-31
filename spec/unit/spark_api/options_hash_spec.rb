require './spec/spec_helper'

describe SparkApi::OptionsHash do
  it "should convert symbol parameters to a string" do
    h = {:parameter_one => 1,
         "parameter_two" => 2,
         3 => 3}
    o_h = SparkApi::OptionsHash.new(h)
    expect(o_h.keys.size).to eq(3)
    expect(o_h["parameter_one"]).to eq(1)
    expect(o_h["parameter_two"]).to eq(2)
    expect(o_h[3]).to eq(3)
  end
end
