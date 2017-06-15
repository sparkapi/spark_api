module StubApiRequests

  def stub_api_get(service_path, stub_fixture="success.json", opts={}, &block)
    stub_api_request(:get, service_path, stub_fixture, nil, opts, &block)
  end

  def stub_api_delete(service_path, stub_fixture="success.json", opts={}, &block)
    stub_api_request(:delete, service_path, stub_fixture, nil, opts, &block)
  end

  def stub_api_post(service_path, body, stub_fixture="success.json", opts={}, &block)
    stub_api_request(:post, service_path, stub_fixture, body, opts, &block)
  end

  def stub_api_put(service_path, body, stub_fixture="success.json", opts={}, &block)  
    stub_api_request(:put, service_path, stub_fixture, body, opts, &block)
  end

  def expect_api_request(meth, service_path, body=nil, opts={})
    args = with_args(service_path, opts, body)
    expect(a_request(meth, full_path(service_path)).with(args))
  end
  
  private

  def full_path(path)
    "#{SparkApi.endpoint}/#{SparkApi.version}#{path}"
  end

  def stub_api_request(meth, service_path, stub_fixture, body, opts, &block)
    args = with_args(service_path, opts, body)
    s = stub_request(meth, full_path(service_path)).with(args)

    if(block_given?)
      yield s
    else
      s.to_return(:body => fixture(stub_fixture))
    end
    log_stub(s)
  end

  def with_args(service_path, opts, body=nil)
    if body.is_a?(Hash)
      body = { :D => body } unless body.empty? 
    elsif !body.nil?
      body = MultiJson.load(fixture(body).read)
    end
    body_str = body.nil? ? body : MultiJson.dump(body)

    params = {:ApiUser => "foobar", :AuthToken => "c401736bf3d3f754f07c04e460e09573"}.merge(opts)
    query = {:ApiSig => get_signature(service_path, params, body_str) }
    query.merge!(params)

    ret = {query: query}
    ret[:body] = body unless body.nil?
    ret
  end

  def test_client
    @test_client ||= SparkApi::Client.new({:api_key=>"", :api_secret=>""})
  end

  def get_signature(service_path, params, body_str=nil)
    test_client.authenticator.sign_token("/#{SparkApi.version}#{service_path}", params, body_str)
  end

  def log_stub(s)
    SparkApi.logger.debug("Stubbed Request: #{s.inspect} \n\n")
    return s
  end

end
