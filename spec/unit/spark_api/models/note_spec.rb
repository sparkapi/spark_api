require './spec/spec_helper'

describe Note do

  it "responds to instance and class methods" do
    expect(Note).to respond_to(:get)
    expect(Note.new).to respond_to(:save)
    expect(Note.new).to respond_to(:save!)
    expect(Note.new).to respond_to(:delete)
  end

  context "when shared with a contact" do
    before :each do
      @note = Listing.new(:ListingKey => "1234").shared_notes("5678")
      stub_auth_request
    end

    it "should have the correct path" do
      expect(@note.path).to eq("/listings/1234/shared/notes/contacts/5678")
    end

    context "/listings/<listing_id>/shared/notes/contacts/<contact_id>", :support do
      on_get_it "GET should get my notes" do
        stub_api_get("#{@note.path}", 'notes/agent_shared.json')
        ret = @note.get
        expect(ret.Note).to eq("lorem ipsum dolor sit amet")
      end

      on_get_it "should return a nil when no shared notes exist" do
        stub_api_get("#{@note.path}", 'notes/agent_shared_empty.json')
        expect(@note.get).to be_nil
      end

      on_delete_it "should allow you to delete an existing note" do
        stub_api_delete("#{@note.path}", 'generic_delete.json')
        @note.new.delete # test that no exceptions are raised
      end

      on_put_it "should raise an exception when adding a note fails" do
        n = @note.new(:Note => "lorem ipsum dolor")

        stub_api_put("#{@note.path}", 'notes/new.json') do |request|
          request.to_return(:status => 500, :body => fixture('generic_failure.json'))
        end

        expect { n.save! }.to raise_error(SparkApi::ClientError) { |e| expect(e.status).to eq(500) }
        expect { n.save }.to raise_error(SparkApi::ClientError) { |e| expect(e.status).to eq(500) }
      end

      on_put_it "should allow adding of a note" do
        n = @note.new(:Note => "lorem ipsum dolor")
        stub_api_put("#{@note.path}", 'notes/new.json', 'notes/add.json')
        n.save
        expect(n.ResourceUri).to eq('/v1/listings/20100909200152674436000000/shared/notes/contacts/20110407212043616271000000/')
      end

    end

    after :each do
      @note = nil
    end
  end
end
