module FlexmlsApi
  class SystemInfo < Model


    class << self 
      def get
        new(FlexmlsApi.client.get('/system')[0])
      end
    end

  end
end
