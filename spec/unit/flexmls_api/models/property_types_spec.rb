require './spec/spec_helper'

describe FlexmlsApi::Models::PropertyTypes do
  before(:each) do 
    @proptypes = FlexmlsApi::Models::PropertyTypes.new({
      "MlsName"=>"Residential", 
      "MlsCode"=>"A"
    })
  end

  it "should respond to get" do
    FlexmlsApi::Models::PropertyTypes.should respond_to(:get)
  end
  

  after(:each) do 
    @proptypes = nil
  end

end
