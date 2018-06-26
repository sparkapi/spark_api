require 'spec_helper'

describe SparkApi::Authentication::OAuth2Impl::GrantTypeBase do
  subject { SparkApi::Authentication::OAuth2Impl::GrantTypeBase }
  # Make sure the client boostraps the right plugin based on configuration.
  it "create should " do
    expect {subject.create(nil, InvalidAuth2Provider.new())}.to  raise_error(SparkApi::ClientError){ |e| expect(e.message).to eq("Unsupported grant type [not_a_real_type]") }
  end
end
