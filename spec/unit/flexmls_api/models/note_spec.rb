require './spec/spec_helper'

describe Note do


  it "responds to instance and class methods" do
    Note.should respond_to :get
    Note.new.should respond_to :save
    Note.new.should respond_to :save!
    Note.new.should respond_to :delete
  end

  context "when shared with a contact" do
    before :each do
      @note = Listing.new(:ListingKey => "1234").shared_notes("5678")
      stub_auth_request
    end

    it "should have the correct path" do
      @note.path.should == "/listings/1234/shared/notes/contacts/5678"
    end

    it "should get my notes" do
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}#{@note.path}").
        with(:query => {
          :ApiSig => '8b00f10700a479b86acd03776cfea34f',
          :AuthToken => 'c401736bf3d3f754f07c04e460e09573',
          :ApiUser => 'foobar'
        }).
        to_return(:body => fixture('agent_shared_note.json'))
      ret = @note.get
      ret.Note.should == "lorem ipsum dolor sit amet"
    end

    it "should return a nil when no shared notes exist" do
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}#{@note.path}").
        with(:query => {
          :ApiSig => '8b00f10700a479b86acd03776cfea34f',
          :AuthToken => 'c401736bf3d3f754f07c04e460e09573',
          :ApiUser => 'foobar'
        }).
        to_return(:body => fixture('agent_shared_note_empty.json'))
      @note.get.should be_nil
    end

    it "should allow you to delete an existing note" do
      stub_request(:delete, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}#{@note.path}").
        with(:query => {
          :ApiSig => '8b00f10700a479b86acd03776cfea34f',
          :ApiUser => 'foobar',
          :AuthToken => 'c401736bf3d3f754f07c04e460e09573'
        }).
        to_return(:body => fixture('generic_delete.json'))
      @note.new.delete # test that no exceptions are raised
    end 

    it "should raise an exception when adding a note fails" do
      n = @note.new(:Note => "lorem ipsum dolor")
      stub_request(:put, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}#{@note.path}").
        with(:query => {
          :ApiSig => '1e8bcca11ab7307ca99463f199a58c7d',
          :ApiUser => 'foobar', 
          :AuthToken => 'c401736bf3d3f754f07c04e460e09573'
        }).
        to_return(:status => 500, :body => fixture('generic_failure.json'))

      expect { n.save! }.to raise_error(FlexmlsApi::ClientError) { |e| e.status.should == 500 }
      expect { n.save }.to raise_error(FlexmlsApi::ClientError) { |e| e.status.should == 500 }
    end

    it "should allow adding of a note" do
      n = @note.new(:Note => "lorem ipsum dolor")

      stub_request(:put, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}#{@note.path}").
        with(:query => {
          :ApiSig => '1e8bcca11ab7307ca99463f199a58c7d',
          :ApiUser => 'foobar', 
          :AuthToken => 'c401736bf3d3f754f07c04e460e09573'
        }).
        to_return(:body => fixture('add_note.json'))

      n.save
      n.ResourceUri.should == '/v1/listings/20100909200152674436000000/shared/notes/contacts/20110407212043616271000000/'
    end

    after :each do
      @note = nil
    end
  end
end
