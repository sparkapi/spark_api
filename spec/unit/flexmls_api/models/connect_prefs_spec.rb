require './spec/spec_helper'

describe FlexmlsApi::Models::Connect do

  it "should respond to prefs" do
    FlexmlsApi::Models::Connect.should respond_to(:prefs)
  end

end
