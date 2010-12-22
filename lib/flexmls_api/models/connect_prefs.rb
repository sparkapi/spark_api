module FlexmlsApi
  module Models
    class Connect < Model

      def self.prefs
        FlexmlsApi.client.get('/connect/prefs')
      end
      
    end
  end
end
