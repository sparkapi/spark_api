module SparkApi
  #===Active support for multiple clients
  module MultiClient
    include SparkApi::Configuration
    
    # Activate a specific instance of the client (with appropriate config settings).  Each client 
    # is lazily instanciated by calling the matching SparkApi.symbol_name method on the 
    # SparkApi module.  It's the developers responsibility to extend the module and provide this
    # method.
    # Parameters
    #  @sym - the unique symbol identifier for a client configuration.
    #  &block - a block of code to run with the specified client enabled, after which the original
    #    client setting will be reenabled
    def activate(sym)
      if block_given?
        original_client = Thread.current[:spark_api_client]
        begin
          activate_client(sym)
          yield
        ensure
          Thread.current[:spark_api_client] = original_client
        end
      else
        activate_client(sym)
      end
    end
    
    private 
    
    # set the active client for the symbol
    def activate_client(symbol)
      if !Thread.current[symbol].nil?
        active_client = Thread.current[symbol]
      elsif SparkApi.respond_to? symbol
        active_client = SparkApi.send(symbol)
      elsif YamlConfig.exists? symbol.to_s
        active_client = activate_client_from_config(symbol)
      else
        raise ArgumentError, "The symbol #{symbol} is not setup correctly as a multi client key."
      end
      Thread.current[symbol] = active_client
      Thread.current[:spark_api_client] = active_client
    end
    
    def activate_client_from_config(symbol)
      SparkApi.logger.debug { "Loading multiclient [#{symbol.to_s}] from config" }
      yaml = YamlConfig.build(symbol.to_s)
      if(yaml.oauth2?)
        Client.new(yaml.client_keys.merge({
              :oauth2_provider => Authentication::OAuth2Impl.load_provider(yaml.oauth2_provider, yaml.oauth2_keys),
              :authentication_mode => SparkApi::Authentication::OAuth2,
            }))
      else
        Client.new(yaml.client_keys)
      end
    end
    
  end
end
