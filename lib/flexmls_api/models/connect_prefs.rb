module FlexmlsApi
  class Connect < Model


    class << self 
      def prefs
        FlexmlsApi.client.get('/connect/prefs')
      end
    end

  end
end
