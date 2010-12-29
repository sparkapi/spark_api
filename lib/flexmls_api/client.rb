module FlexmlsApi
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
