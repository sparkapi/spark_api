require 'erb'
module FlexmlsApi
  module Configuration
    class YamlConfig
      KEY_CONFIGURATIONS = VALID_OPTION_KEYS  + [:oauth2] + OAUTH2_KEYS  
      
      attr_accessor *KEY_CONFIGURATIONS
      attr_reader :client_keys, :oauth2_keys
      
      def initialize(filename=nil)
        @client_keys = {}
        @oauth2_keys = {}
        @oauth2 = false
        load_file(filename) unless filename.nil?()
      end
      def load_file(file)
        @client_keys = {}
        @oauth2_keys = {}
        @file = file
        @name = File.basename(file, ".yml")
        config = YAML.load(ERB.new(File.read(file)).result)[api_env]
        config.each do |key,val|
          sym = key.to_sym
          if KEY_CONFIGURATIONS.include? sym
            self.send("#{sym}=", val)
            if VALID_OPTION_KEYS.include?(sym)
              @client_keys[sym] = val
            elsif OAUTH2_KEYS.include?(sym)
              @oauth2_keys[sym] = val
            end
          end
        end
      rescue => e
        FlexmlsApi.logger().error("Unable to load config file #{file}[#{api_env}]")
        raise e
      end
      
      def oauth2?
        return oauth2 == true
      end
      
      def name
        @name
      end
      def api_env
        current_env = "development"
        if env.include?("FLEXMLS_API_ENV")
          current_env = env["FLEXMLS_API_ENV"]
        elsif env.include?("RAILS_ENV")
          current_env = env["RAILS_ENV"]
        end
        return current_env
      end
      
      # Used to specify the root of where to look for flexmlsApi config files
      def self.config_path
        "config/flexmls_api"
      end
      
      def self.config_keys()
        files = Dir["#{config_path}/*.yml"]
        files.map {|f| File.basename(f,".yml") }
      end
      
      def self.exists?(name)
        File.exists? "#{config_path}/#{name}.yml"
      end

      def self.build(name)
        yaml = YamlConfig.new("#{config_path}/#{name}.yml")
      end
      
      protected
      def env
        ENV
      end

    end
  end
end

