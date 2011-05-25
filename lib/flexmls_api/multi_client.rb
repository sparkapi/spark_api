module FlexmlsApi
  #===Active support for multiple clients
  module MultiClient
    
    # Activate a specific instance of the client (with appropriate config settings).  Each client 
    # is lazily instanciated by calling the matching FlexmlsApi.symbol_name method on the 
    # FlexmlsApi module.  It's the developers responsibility to extend the module and provide this
    # method.
    # Parameters
    #  @sym - the unique symbol identifier for a client configuration.
    #  &block - a block of code to run with the specified client enabled, after which the original
    #    client setting will be reenabled
    def activate(sym)
      if block_given?
        original_client = Thread.current[:flexmls_api_client]
        activate_client(sym)
        begin
          yield
        ensure
          Thread.current[:flexmls_api_client] = original_client
        end
      else
        activate_client(sym)
      end
    end
    
    private 
    
    # set the active client for the symbol
    def activate_client(sym)
      active_client = Thread.current[sym] || FlexmlsApi.send(sym)
      Thread.current[:flexmls_api_client] = active_client unless active_client.nil?
    rescue NoMethodError => e
      raise ArgumentError, "The symbol #{sym} is missing a corresponding FlexmlsApi.#{sym} method.", e.backtrace
    end
  end
end
