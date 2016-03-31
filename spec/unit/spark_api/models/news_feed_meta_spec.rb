require './spec/spec_helper'


describe NewsFeedMeta do

  let(:news_feed_meta) { NewsFeedMeta.new }

  before(:each) do
    stub_auth_request
    stub_api_get("/newsfeeds/meta", "newsfeeds/meta.json")
  end

  describe 'minimum_core_fields' do
    it 'returns the minimum number of required fields' do
      expect(news_feed_meta.minimum_core_fields).to eq 3
    end
  end

  describe 'core_field_names' do
    it 'returns an array including both the CoreSearchFields and the CoreStandardFields' do
      field_array = ["Location", "Status", "Property Type", "Postal Code", "List Price", "Total Bedrooms", 
        "Year Built", "Total SqFt.", "Sub Type", "Subdivision", "Map Area"]
      expect(news_feed_meta.core_field_names).to eq field_array    
    end
  end

  describe 'core_fields' do
    it 'returns an array including both the CoreSearchFields and the CoreStandardFields' do
      field_array = ["Location", "MlsStatus", "PropertyType", "PostalCode", "ListPrice", "BedsTotal", 
        "YearBuilt", "BuildingAreaTotal", "PropertySubType", "SubdivisionName", "MLSAreaMinor"]
      expect(news_feed_meta.core_fields).to eq field_array    
    end
  end

end
