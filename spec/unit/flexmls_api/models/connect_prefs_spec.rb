require './spec/spec_helper'

describe FlexmlsApi::Connect do

  it "should respond to prefs" do
    FlexmlsApi::Connect.should respond_to(:prefs)
  end

end
