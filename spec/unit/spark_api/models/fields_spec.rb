require './spec/spec_helper'

describe Fields do
  before(:each) do
    stub_auth_request
  end

  context "/fields/order", :support do
    on_get_it "should find field orders for all property types" do
      expect(Fields).to respond_to(:order)

      # stub request
      stub_api_get('/fields/order','fields/order.json')

      # request
      resources = subject.class.order

      # a standard array of results
      expect(resources).to be_an(Array)
      expect(resources.length).to eq(1)

      # make sure multiple property types are present
      expect(resources.first).to have_key("A")
      expect(resources.first).to have_key("B")

      expect(resources.first["A"]).to be_an(Array)
    end
  end

  context "/fields/order/<property_type>", :support do
    on_get_it "should find field order for a single property type" do
      expect(Fields).to respond_to(:order)

      # stub request
      stub_api_get('/fields/order/A','fields/order_a.json')

      # request
      resources = subject.class.order("A")

      # a standard array of results
      expect(resources).to be_an(Array)
      expect(resources.length).to eq(2)

      # validate a single entity
      group = resources.first[resources.first.keys.first]
      expect(group).to be_an(Array)
      expect(group.length).to eq(2)
      group.each do |field|
        expect(field).to have_key("Field")
      end

    end
  end

  context "/fields/order/settings", :support do
    on_get_it "returns the field order settings" do
      expect(Fields).to respond_to(:settings)

      # stub request
      stub_api_get('/fields/order/settings','fields/settings.json')

      # request
      settings = subject.class.settings

      # a standard array of results
      expect(settings).to be_an(Array)
      expect(settings.length).to eq(1)

      # make sure ShowingInstructions is present
      expect(settings.first).to have_key("ShowingInstructions")
      expect(settings.first["ShowingInstructions"]).to be_an(Array)
    end
  end


end
