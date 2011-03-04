module FlexmlsApi
  class PrimaryArray < Array
    
    def primary
      find_primary
    end

    private 
    
    # This is a very simplistic but reliable implementation.
    def find_primary
      self.each do |arg|
        if arg.primary?
          return arg
        end
      end
      nil
    end
  end
  
  #=== Primary: interface to implement for elements that are added to a "PrimaryArray" collection
  module Primary
    # Return true if the element is the primary resource in a collection.
    # Default implementation looks for a "Primary" attribute
    def primary?
      @attributes.key?("Primary") && self.Primary == true
    end
  end
end
