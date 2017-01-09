require 'spec_helper'

describe EmailLink do
  it_behaves_like 'search_container'

  let(:email_link) { EmailLink.new(Id: 5) }

  describe 'filter' do
    it 'returns a filter for the email link' do
      expect(email_link.filter).to eq "EmailLink Eq '#{email_link.id}'"
    end    
  end  

  describe 'listing_search_role' do
    it 'returns a symbol' do
      expect(EmailLink.new().listing_search_role).to eq(:public)
    end
  end
end
