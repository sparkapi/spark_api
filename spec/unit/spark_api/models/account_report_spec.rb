require './spec/spec_helper'

describe AccountReport do

  let(:account_report) { 
    AccountReport.new({
      "Id" => "12345",
      "Name" => "Agent McAgentson",
      "Office" => "Office Name",
      "Emails"=>  [],
      "Phones"=>  [],
      "Websites"=>  [],
      "Addresses"=>  []
    }) 
  }

  describe 'primary_email' do

    it 'returns the primary email address' do
      account_report.emails << double(:Address => 'foo@foo.com', :primary? => true)
      expect(account_report.primary_email).to eq account_report.emails.primary.Address
    end

    it 'returns nil when there is no primary email address' do
      account_report.emails << double(:Address => 'foo@foo.com', :primary? => false)
      expect(account_report.primary_email).to eq nil
    end

    it 'returns nil when there are no email addresses' do
      allow(account_report).to receive(:emails).and_return nil
      expect(account_report.primary_email).to eq nil
    end
    
  end

  describe 'primary_phone' do

    it 'returns the primary phone number' do
      account_report.phones << double(:Number => '88', :primary? => true)
      expect(account_report.primary_phone).to eq account_report.phones.primary.Number
    end

    it 'returns nil when there is no primary phone number' do
      account_report.phones << double(:Number => '88', :primary? => false)
      expect(account_report.primary_phone).to eq nil
    end

    it 'returns nil when there are no phone numbers' do
      allow(account_report).to receive(:phones).and_return nil
      expect(account_report.primary_phone).to eq nil
    end
    
  end

  describe 'logo' do

    it 'returns the logo' do
      logo = SparkApi::Models::Base.new( {"Type" => "Logo"} )
      not_logo = SparkApi::Models::Base.new( {"Type" => "Nope" } )
      account_report.images = [logo, not_logo]
      expect(account_report.logo).to be logo
    end

    it 'returns nil if there is no logo' do
      not_logo = SparkApi::Models::Base.new( {"Type" => "Nope" } )
      account_report.images = [not_logo]
      expect(account_report.logo).to be nil
    end

    it 'returns nil if there are no images' do
      expect(account_report.images).to be nil
      expect(account_report.logo).to be nil
    end
    
  end
  
end
