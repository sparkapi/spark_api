module SparkApi
  module Models
    class AccountReport < Account
      def self.report(account_id, arguments={})
        collect(connection.get("/accounts/#{account_id}/report", arguments)).first
      end

      def DisplayName
        self.Name
      end

      def primary_email
        if Array(emails).any? && emails.primary
          emails.primary.Address
        end
      end

      def primary_phone
        if Array(phones).any? && phones.primary
          phones.primary.Number
        end
      end

    end
  end
end
