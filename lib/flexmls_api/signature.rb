module FlexmlsApi
  module Signature
    def self.get_auth_token
      path = "/v1/session"
      sig = Digest::MD5.hexdigest("#{@@api_secret}ApiKey#{@@api_key}")
      resp = Curl::Easy.http_post("#{@@api_base}#{path}", "ApiSig=#{sig}&ApiKey=#{@@api_key}")
      JSON.parse(resp.body_str)['D']['Results'][0]['AuthToken']
    end 


    def self.generate_request_signature(user_key, user_secret, service_path, parameters = {}, post_data = "") 
      uri = Addressable::URI.parse(service_path)
      service_path = uri.path
      parameters["AuthToken"] = @@auth_token
      sig = "#{@@api_secret}ApiKey#{@@api_key}ServicePath#{service_path}#{build_param_string(parameters)}#{post_data}"
      hash_sig(sig) 
    end 
   
    def hash_sig(sig)
      Digest::MD5.hexdigest(sig)
    end

    def build_param_string(params = {}) 
      ret = ""
      params.sort {|a,b| a.to_s <=> b.to_s }.each do |k,v|
        ret += k.to_s + v.to_s
      end 
      ret 
    end 

  end
end
