module SparkApi
  module Models
    class VowAccount < Base
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name = "portal"

      def initialize(attributes={})
        super(attributes)
      end

      def singular?; true end

      def enabled?
        (@attributes['Settings'].class == Hash) && @attributes['Settings']['Enabled'] == 'true'
      end

      def enable
        change_setting :Enabled, 'true'
        save
      end

      def disable
        change_setting :Enabled, 'false'
        save
      end

      def change_password(new_password)
        attribute_will_change! 'Password'
        @attributes['Password'] = new_password
        save
      end

      def change_setting(key, val)
        attribute_will_change! "Settings"
        @attributes['Settings'] = {} if @attributes['Settings'].nil? || @attributes['Settings'] != Hash
        @attributes['Settings'][key.to_s] = val
      end

      def post_data; attributes end

    end
  end
end
