module SparkApi
  module Models
    class Account < Base
      extend Finders
      self.element_name="accounts"
      
      SUBELEMENTS = [:emails, :phones, :websites, :addresses, :images]
      attr_accessor :my_account, *SUBELEMENTS 
      
      def initialize(attributes={})
        @emails = subresource(Email, "Emails", attributes)
        @phones = subresource(Phone, "Phones", attributes)
        @websites = subresource(Website, "Websites", attributes)
        @addresses = subresource(Address, "Addresses", attributes)
        if attributes["Images"]
          @images = [] 
          attributes["Images"].each { |i| @images << Image.new(i) }
        else
          @images = nil
        end
        @my_account = false
        super(attributes)
      end

      def self.my(arguments={})
        account  = collect(connection.get("/my/account", arguments)).first
        account.my_account = true
        account
      end
      
      def my_account?
        @my_account
      end
      
      def self.by_office(office_id, arguments={})
        collect(connection.get("#{self.path()}/by/office/#{office_id}", arguments))
      end

      def primary_img(typ)
        if @images.is_a?(Array)
          matches = @images.select {|i| i.Type == typ}
          matches.sort do |a,b| 
            if a.Name.nil? && !b.Name.nil?
              1
            elsif b.Name.nil? && !a.Name.nil?
              -1
            else
              a.Name.to_s <=> b.Name.to_s
            end 
          end.first
        else
          nil
        end
      end
      
      def save(arguments={})
        self.errors = [] # clear the errors hash
        begin
          return save!(arguments)
        rescue BadResourceRequest => e
          self.errors << { :code => e.code, :message => e.message }
          SparkApi.logger.error("Failed to save resource #{self}: #{e.message}")
        rescue NotFound => e
          self.errors << {:code => e.code, :message => e.message}
          SparkApi.logger.error("Failed to save resource #{self}: #{e.message}")
        end
        false
      end
      def save!(arguments={})
        # The long-term idea is that any setting in the user's account could be updated by including
        # an attribute and calling PUT /my/account, but for now only the GetEmailUpdates attribute 
        # is supported
        
        save_path = "/accounts/"+self.Id
        
        ojbsome = {}
        if attributes['GetEmailUpdates']
          save_path = my_account? ? "/my/account" : self.class.path
          ojbsome["GetEmailUpdates"] = attributes['GetEmailUpdates']
        end
        if attributes['PasswordValidation']
          ojbsome["PasswordValidation"] = attributes['PasswordValidation']
        end
        if attributes['Password']
          ojbsome["Password"] = attributes['Password']
        end    
          
        results = connection.put save_path, ojbsome, arguments
        true
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
      end
    end
  end

end
