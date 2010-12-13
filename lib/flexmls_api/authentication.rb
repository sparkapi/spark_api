
module FlexmlsApi::Authentication

  def authenticate
    sig = sign("#{@secret}ApiKey#{@key}")
    url = "#{url}/v1/auth/login?ApiKey=#{@key}&ApiSig=#{sig}"
    # TODO replace with faraday?
    c = Curl::Easy.http_post( url, "" ) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['flexmlsAPI-User-Agent'] = 'CurbClient'
    end
    r = JSON.parse( c.body_str )
    r["D"]["Results"][0]["AuthToken"]
  end
  
  def sign(sig)
    Digest::MD5.hexdigest( sig )
  end

  def sign_token(path, params, data="")
    sign( "#{@secret}ApiKey#{@key}ServicePath#{service_path}#{build_param_string(parameters)}#{post_data}" )
  end
  
  def build_param_string(param_hash)
    return "" if param_hash.nil?

      sorted_keys = param_hash.keys.sort { |a,b|
            a.to_s <=> b.to_s
      }

      params = ""
      sorted_keys.each do |k|
        params += k.to_s + param_hash[k]
      end

      params
  end

end

