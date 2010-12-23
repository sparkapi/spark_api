module FlexmlsApi
  module Models
    class Contact < Model

      def self.get
        instances = []
        resp = FlexmlsApi.client.get('/contacts')
        resp.each do |p|
          instances.push(new(p))
        end
        instances
      end

    end
  end
end
