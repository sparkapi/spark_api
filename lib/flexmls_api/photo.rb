module FlexmlsApi
  class Photo < Model
    

    def primary? 
      @attributes["Primary"] == true 
    end

  end
end
