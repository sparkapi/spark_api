module FlexmlsApi
  module Models
    class Account < Base
      self.element_name="accounts"
      
      SUBELEMENTS = [:emails, :phones, :websites, :addresses, :images]
      attr_accessor *SUBELEMENTS
      
      def initialize(attributes={})
        @emails = subresource(Email, "Emails", attributes)
        @phones = subresource(Phone, "Phones", attributes)
        @websites = subresource(Website, "Websites", attributes)
        @addresses = subresource(Address, "Addresses", attributes)
        @images = subresource(Image, "Images", attributes)
        super(attributes)
      end

      def self.my(arguments={})
        collect(connection.get("/my/account", arguments)).first
      end

      private

      def subresource(klass, key, attributes)
        return nil unless attributes.key?(key)
        array = attributes[key]
        result = PrimaryArray.new()
        array.each do |i|
          result << klass.new(i)
        end
        result
      end

      class Email < Base
        include Primary
      end

      class Phone < Base
        include Primary
      end

      class Website < Base
        include Primary
      end

      class Address < Base
        include Primary
      end
      class Image < Base
        include Primary
      end
    end
  end

end