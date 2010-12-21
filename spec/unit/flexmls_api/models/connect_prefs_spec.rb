require 'flexmls_api'

describe FlexmlsApi::Connect do

  it "should respond to prefs" do
    FlexmlsApi::Connect.should respond_to(:prefs)
  end
  


end
