module FlexmlsApi
  # =API Client
  # Main class to setup and run requests on the API.  A default client is accessible globally as 
  # FlexmlsApi::client if the global configuration has been set as well.  Otherwise, this class may 
  # be instanciated separately with the configuration information.
  class Client
    include Authentication
    include Request
    
    attr_accessor *Configuration::VALID_OPTION_KEYS
    
    def initialize(options={})
      options = FlexmlsApi.options.merge(options)
      Configuration::VALID_OPTION_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

  end
end
