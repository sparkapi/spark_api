#require File.expand_path('../connection', __FILE__)
module FlexmlsApi 
  class Base
    attr_accessor *Configuration::VALID_OPTION_KEYS

    def initialize(options={})
      options = FlexmlsApi.options.merge(options)
      Configuration::VALID_OPTION_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end


    include Connection
  end
end
