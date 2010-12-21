module FlexmlsApi
  class StandardFields < Model


    def self.get
      new(FlexmlsApi.client.get('/standardfields')[0])
    end

  end
end
