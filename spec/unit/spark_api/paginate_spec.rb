require './spec/spec_helper'

class PaginateResponseTester
  include SparkApi::PaginateHelper
end

class PaginateModelTester < SparkApi::Models::Base
  @tester = PaginateResponseTester.new
  attr_accessor :val
  def initialize (val)
    @val = val
  end
  class << self
    attr_accessor :options
    def get(options)
      @options = options
      json = "{#{paginate_json}}"
      hash = JSON.parse(json)
      results = @tester.paginate_response([1,2,3,4,5,6,7,8,9,10], hash["Pagination"])
      collect(results)
    end
  end
end

class PaginateModelTester50 < PaginateModelTester
  @tester = PaginateResponseTester.new
  def self.per_page
      50
  end
end


describe SparkApi::PaginateResponse do
  describe "paginate_response" do
    subject { PaginateResponseTester.new } 
    it "should give me the first page" do
      json = "{#{paginate_json}}"
      hash = JSON.parse(json)
      results = subject.paginate_response([1,2,3,4,5,6,7,8,9,10], hash["Pagination"])
      expect(results.offset).to eq(0)
      expect(results.next_page).to eq(2)
      expect(results.previous_page).to eq(nil)
      expect(results.current_page).to eq(1)
      expect(results.per_page).to eq(10)
      expect(results.total_pages).to eq(4)
      expect(results.total_entries).to eq(38)
      expect(results[0]).to eq(1)
    end
    it "should give me the second page" do
      json = "{#{paginate_json(2)}}"
      hash = JSON.parse(json)
      results = subject.paginate_response([11,12,13,14,15,16,17,18,19,20], hash["Pagination"])
      expect(results.offset).to eq(10)
      expect(results.next_page).to eq(3)
      expect(results.previous_page).to eq(1)
      expect(results.current_page).to eq(2)
      expect(results.per_page).to eq(10)
      expect(results.total_pages).to eq(4)
      expect(results.total_entries).to eq(38)
      expect(results[0]).to eq(11)
    end
    it "should give me the third page" do
      json = "{#{paginate_json(3)}}"
      hash = JSON.parse(json)
      results = subject.paginate_response([21,22,23,24,25,26,27,28,29,30], hash["Pagination"])
      expect(results.offset).to eq(20)
      expect(results.next_page).to eq(4)
      expect(results.previous_page).to eq(2)
      expect(results.current_page).to eq(3)
      expect(results.per_page).to eq(10)
      expect(results.total_pages).to eq(4)
      expect(results.total_entries).to eq(38)
      expect(results[0]).to eq(21)
    end
    it "should give me the last page" do
      json = "{#{paginate_json(4)}}"
      hash = JSON.parse(json)
      results = subject.paginate_response([31,32,33,34,35,36,37,38], hash["Pagination"])
      expect(results.offset).to eq(30)
      expect(results.next_page).to eq(nil)
      expect(results.previous_page).to eq(3)
      expect(results.current_page).to eq(4)
      expect(results.per_page).to eq(10)
      expect(results.total_pages).to eq(4)
      expect(results.total_entries).to eq(38)
      expect(results[0]).to eq(31)
      expect(results[-1]).to eq(38)
    end
  end
end

describe SparkApi::Paginate do
  describe "paginate" do
    it "should give me a will paginate collection" do
      results = PaginateModelTester.paginate(:page => 1)
      expect(results).to be_a(WillPaginate::Collection)
      expect(results.offset).to eq(0)
      expect(results.next_page).to eq(2)
      expect(results.previous_page).to eq(nil)
      expect(results.current_page).to eq(1)
      expect(results.per_page).to eq(10)
      expect(results.total_pages).to eq(4)
      expect(results.total_entries).to eq(38)
      
      expect(results[0]).to be_a(PaginateModelTester)
      expect(results[0].val).to eq(1)
      
    end
      
    it "should give me pagination options" do
      PaginateModelTester.paginate(:page => 1)
      opts = PaginateModelTester.options
      expect(opts["_pagination"]).to eq(1)
      expect(opts["_limit"]).to eq(25)
      expect(opts["_page"]).to eq(1)
      expect(opts.has_key?(:page)).to eq(false)
    end
  end

  describe "per_page" do
    it "should set the default model max results per page" do
      results = PaginateModelTester50.paginate(:page => 1)
      opts = PaginateModelTester50.options
      expect(opts["_limit"]).to eq(50)
    end
  end
  
  # non unit-y real world test of paginations with listings
  context "paginating listings" do
    before(:each) do
      stub_auth_request
    end

    subject { SparkApi::Models::Listing }
    it "gives me page one of listings" do
      json = <<-JSON 
        {"D": {
          "Success": true, 
          "Results": [#{ListingJson.create_all(10)}],
          #{paginate_json}
        }}
      JSON
      stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/listings").
        with(:query => {
          :ApiSig => "4a00ca0e657c824d85a5fe1007d9c52d",
          :ApiUser => "foobar",
          :AuthToken => "c401736bf3d3f754f07c04e460e09573",
          :_limit => '10',
          :_page => '1',
          :_pagination => '1'
        }).
        to_return(:body => json)
      results = subject.paginate(:page=>1, :per_page=>10)
      expect(results).to be_a(WillPaginate::Collection)
      expect(results.offset).to eq(0)
      expect(results.next_page).to eq(2)
      expect(results.previous_page).to eq(nil)
      expect(results.current_page).to eq(1)
      expect(results.per_page).to eq(10)
      expect(results.total_pages).to eq(4)
      expect(results.total_entries).to eq(38)
      expect(results.length).to eq(10)
      
      expect(results[0]).to be_a(subject)
      expect(results[0].ListPrice).to eq(50000.0)
      
    end
    it "gives me page two of listings" do
      json = <<-JSON 
        {"D": {
          "Success": true, 
          "Results": [#{ListingJson.create_all(10)}],
          #{paginate_json(2)}
        }}
      JSON
      stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/listings").
        with(:query => {
          :ApiSig => "094d3851a0c4c4563baf70ca45087e30",
          :ApiUser => "foobar",
          :AuthToken => "c401736bf3d3f754f07c04e460e09573",
          :_limit => '10',
          :_page => '2',
          :_pagination => '1'
        }).
        to_return(:body => json)
      results = subject.paginate(:page=>2, :per_page=>10)
      expect(results.next_page).to eq(3)
      expect(results.previous_page).to eq(1)
      expect(results.current_page).to eq(2)
    end
    it "gives me page four of listings" do
      json = <<-JSON 
        {"D": {
          "Success": true, 
          "Results": [#{ListingJson.create_all(8)}],
          #{paginate_json(4)}
        }}
      JSON
      stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/listings").
        with(:query => {
          :ApiSig => "dcfce1fe9289c905f8d2d01cbb850edc",
          :ApiUser => "foobar",
          :AuthToken => "c401736bf3d3f754f07c04e460e09573",
          :_limit => '10',
          :_page => '4',
          :_pagination => '1'
        }).
        to_return(:body => json)
      results = subject.paginate(:page=>4, :per_page=>10)
      expect(results.next_page).to eq(nil)
      expect(results.previous_page).to eq(3)
      expect(results.current_page).to eq(4)
      expect(results.per_page).to eq(10)
      expect(results.total_pages).to eq(4)
      expect(results.total_entries).to eq(38)
      
      expect(results.length).to eq(8)
      expect(results[0]).to be_a(subject)
      expect(results[0].ListPrice).to eq(50000.0)
    end
    
  end
end
