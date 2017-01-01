module SparkApi
  module Models
    class AccountRoster < Account
      def self.roster(account_id, arguments={})
        collect(connection.get("/accounts/#{account_id}/roster", arguments)).first
      end
    end
  end
end
