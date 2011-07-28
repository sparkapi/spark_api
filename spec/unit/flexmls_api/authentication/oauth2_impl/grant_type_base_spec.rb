require './spec/spec_helper'
require './spec/oauth2_helper'

describe FlexmlsApi::Authentication::OAuth2Impl::GrantTypeBase do
  subject { FlexmlsApi::Authentication::OAuth2Impl::GrantTypeBase }
  # Make sure the client boostraps the right plugin based on configuration.
  it "create should " do
    expect {subject.create(nil, InvalidAuth2Provider.new())}.to  raise_error(FlexmlsApi::ClientError){ |e| e.message.should == "Unsupported grant type [not_a_real_type]" }
  end
end
