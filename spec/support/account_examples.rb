shared_examples_for :account do |test_class|

  let(:account) {
    test_class.new({
        "Id" => "12345",
        "Name" => "Agent McAgentson",
        "Office" => "Office Name",
        "Emails"=>  [],
        "Phones"=>  [],
        "Websites"=>  [],
        "Addresses"=>  []
      })
  }

  describe 'logo' do

    it 'returns the logo' do
      logo = SparkApi::Models::Base.new( {"Type" => "Logo"} )
      not_logo = SparkApi::Models::Base.new( {"Type" => "Nope" } )
      account.images = [logo, not_logo]
      expect(account.logo).to be logo
    end

    it 'returns nil if there is no logo' do
      not_logo = SparkApi::Models::Base.new( {"Type" => "Nope" } )
      account.images = [not_logo]
      expect(account.logo).to be nil
    end

    it 'returns nil if there are no images' do
      expect(account.images).to be nil
      expect(account.logo).to be nil
    end
    
  end

end
