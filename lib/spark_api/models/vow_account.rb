module SparkApi
  module Models
    class VowAccount < Base
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      def initialize(contact_id, attributes={})
          @contact_id = contact_id
          super(attributes)
      end

      def singular?
        true
      end

      def save_path
        "/contacts/#{@contact_id}/portal"
      end

      def enabled?
        (@attributes['Settings'].class == Hash) && @attributes['Settings']['Enabled'] == 'true'
      end

      def enable
        change_setting 'Enabled', 'true'
        save
      end

      def disable
        change_setting 'Enabled', 'false'
        save
      end

      def change_password(new_password)
        @attributes['Password'] = new_password
        attribute_will_change! 'Password'
        save
      end

      def change_setting(key, val)
        attribute_will_change! "Settings"

        @attributes['Settings'] = {} if @attributes['Settings'].nil? || @attributes['Settings'] != Hash
        @attributes['Settings'][key] = val
      end

      def post_data; attributes end

    end
  end
end
