module FlexmlsApi
  class SystemInfo < Model


    def self.get
      new(FlexmlsApi.client.get('/system')[0])
    end

  end
end
