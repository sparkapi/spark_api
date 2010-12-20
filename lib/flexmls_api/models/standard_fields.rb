module FlexmlsApi
  class StandardFields < Model


    class << self 
      def get
        new(FlexmlsApi.client.get('/standardfields')[0])
      end
    end

  end
end
