require './spec/spec_helper'

describe FlexmlsApi::PropertyTypes do
  before(:each) do 
    @proptypes = FlexmlsApi::PropertyTypes.new({
      "MlsName"=>"Residential", 
      "MlsCode"=>"A"
    })
  end

  it "should respond to get" do
    FlexmlsApi::PropertyTypes.should respond_to(:get)
  end
  

  after(:each) do 
    @proptypes = nil
  end

end
