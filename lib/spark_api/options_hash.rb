module SparkApi
  # Used for API client options that accept string keys instead of symbols -- 
  # turns all symbol keys into a string for consistancy, allowing applications
  # using the client to pass in parameters as symbols or strings.
  class OptionsHash < Hash 
    def initialize(from_hash={})
      from_hash.keys.each do |k|
        if k.is_a?(Symbol)
          self[k.to_s] = from_hash[k] 
        else
          self[k] = from_hash[k] 
        end
      end
      self
    end
  end
end
    
