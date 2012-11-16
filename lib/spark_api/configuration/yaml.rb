require 'yaml'
require 'erb'

module SparkApi
  module Configuration
    class YamlConfig
      KEY_CONFIGURATIONS = VALID_OPTION_KEYS  + [:oauth2] + OAUTH2_KEYS  
      DEFAULT_OAUTH2_PROVIDER = "SparkApi::Authentication::OAuth2Impl::CLIProvider"
      attr_accessor *KEY_CONFIGURATIONS
      attr_reader :client_keys, :oauth2_keys, :provider
      
      def initialize(filename=nil)
        @oauth2 = false
        load_file(filename) unless filename.nil?()
      end
      def load_file(file)
        @file = file
        @name = File.basename(file, ".yml")
        config = YAML.load(ERB.new(File.read(file)).result)[api_env]
        config["oauth2"] == true  ? load_oauth2(config) : load_api_auth(config)
      rescue => e
        SparkApi.logger().error("Unable to load config file #{file}[#{api_env}]")
        raise e
      end
      
      def oauth2?
        return oauth2 == true
      end

      def ssl_verify?
        return ssl_verify == true
      end
      
      def name
        @name
      end
      
      def api_env
        if env.include? "SPARK_API_ENV"
          env["SPARK_API_ENV"]
        elsif env.include? "RAILS_ENV"
          env["RAILS_ENV"]
        elsif env.include? "RACK_ENV"
          env["RACK_ENV"]
        else
          "development"
        end
      end
      
      # Used to specify the root of where to look for SparkApi config files
      def self.config_path
        path_prefix + "config/spark_api"
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
      
      private 
      def load_api_auth(config={})
        @client_keys = {}
        @oauth2_keys = {}
        config.each do |key,val|
          sym = key.to_sym
          if VALID_OPTION_KEYS.include?(sym)
            self.send("#{sym}=", val)
            @client_keys[sym] = val
          end
        end
      end
      def load_oauth2(config={})
        @oauth2_provider = DEFAULT_OAUTH2_PROVIDER
        @client_keys = {:oauth2_provider => @oauth2_provider }
        @oauth2_keys = {}
        @oauth2 = true
        config.each do |key,val|
          sym = key.to_sym
          if VALID_OPTION_KEYS.include?(sym)
            self.send("#{sym}=", val)
            @client_keys[sym] = val
          elsif OAUTH2_KEYS.include? sym
            self.send("#{sym}=", val)
            @oauth2_keys[sym] = val
          end
        end
      end
      # In a rails app, default to the rails root, regardless of where that may be      
      def self.path_prefix
        "#{Rails.root}/"
      rescue => e
        ""
      end
    end
  end
end
