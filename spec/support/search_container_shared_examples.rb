shared_examples_for 'search_container' do
  let(:instance) { described_class.new( respond_to?(:initialization_args) ? initialization_args : {} ) }

  methods = [:template, :filter, :sort_id, :sort_id=].each do |method|

    it "responds to the method ##{method.to_s}" do
      expect(instance.respond_to?(method)).to eq(true)
    end
  end
end
