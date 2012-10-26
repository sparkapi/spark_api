module SparkApi
  module Models

    class Portal < Base
      extend Finders
      include Concerns::Savable

      self.element_name = "portal"

      def self.my(arguments = {})
        portal = collect(connection.get("/portal", arguments)).first
        portal = Portal.new if portal.nil?
        portal
      end

      def enabled?
        @attributes['Enabled'] == true
      end

      def enable
        @attributes['Enabled'] = true
        save
      end

      def disable
        @attributes['Enabled'] = false
        save
      end

      def post_data; attributes end

    end

  end
end
