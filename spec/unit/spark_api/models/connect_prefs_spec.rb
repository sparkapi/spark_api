require './spec/spec_helper'

describe Connect do

  it "should respond to prefs" do
    expect(Connect).to respond_to(:prefs)
  end

end
