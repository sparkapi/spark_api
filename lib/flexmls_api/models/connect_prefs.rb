module FlexmlsApi
  module Models
    class Connect < Base
      self.element_name="connect"
      def self.prefs
        connection.get("#{path}/prefs")
      end
    end
  end
end
