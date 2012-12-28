module SparkApi
  module Models
    class Fields < Base
      self.element_name="fields"

      def self.order(card_fmt=nil, arguments={})
        connection.get("#{self.path}/order#{"/"+card_fmt unless card_fmt.nil?}", arguments)
      end

    end
  end
end
