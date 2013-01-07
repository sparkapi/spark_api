require './spec/spec_helper'

describe Fields do
  before(:each) do
    stub_auth_request
  end

  context "/fields/order", :support do
    on_get_it "should find field orders for all property types" do
      Fields.should respond_to(:order)

      # stub request
      stub_api_get('/fields/order','fields/order.json')

      # request
      resources = subject.class.order

      # a standard array of results
      resources.should be_an(Array)
      resources.length.should eq(1)

      # make sure multiple property types are present
      resources.first.should have_key("A")
      resources.first.should have_key("B")

      resources.first["A"].should be_an(Array)
    end
  end

  context "/fields/order/<property_type>", :support do
    on_get_it "should find field order for a single property type" do
      Fields.should respond_to(:order)

      # stub request
      stub_api_get('/fields/order/A','fields/order_a.json')

      # request
      resources = subject.class.order("A")

      # a standard array of results
      resources.should be_an(Array)
      resources.length.should eq(2)

      # validate a single entity
      group = resources.first[resources.first.keys.first]
      group.should be_an(Array)
      group.length.should eq(2)
      group.each do |field|
        field.should have_key("Field")
      end

    end
  end


end
