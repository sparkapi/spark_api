module SparkApi
  module Models
    module Dirty

      def changed?
        changed.any?
      end

      def changed
        changed_attributes.keys
      end

      def changes
        Hash[changed.map { |attr| [attr, attribute_change(attr)] }]
      end

      def previous_changes
        @previously_changed
      end

      # hash with changed attributes and their original values
      def changed_attributes
        @changed_attributes ||= {}
      end

      # hash with changed attributes and their new values
      def dirty_attributes
        changed.inject({}) { |h, k| h[k] = attributes[k.to_s]; h }
      end

      private

      def reset_dirty
        @previously_changed = changed_attributes
        @changed_attributes.clear
      end

      def attribute_changed?(attr)
        changed.include?(attr)
      end

      def attribute_change(attr)
        [changed_attributes[attr], @attributes[attr.to_s]] if attribute_changed?(attr)
      end

      def attribute_will_change!(attr)
        begin
          value = @attributes[attr.to_s]
          value = value.duplicable? ? value.clone : value
        rescue TypeError, NoMethodError; end

        changed_attributes[attr] = value unless changed.include?(attr)
      end

    end
  end
end
