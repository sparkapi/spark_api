require './spec/spec_helper'

describe Connect do

  it "should respond to prefs" do
    Connect.should respond_to(:prefs)
  end

end
