require 'optparse'

if ENV["SPARK_API_CONSOLE"].nil?
  require 'spark_api'
else
  puts "Enabling console mode for local gem"
  Bundler.require(:default, "development") if defined?(Bundler)
  path = File.expand_path(File.dirname(__FILE__) + "/../../../lib/")
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
  require path + '/spark_api'
end

module SparkApi
  module CLI
    class ConsoleCLI
      OPTIONS_ENV = {
        :endpoint          => "API_ENDPOINT",
        # OAUTH2 Options
        :access_uri  => "ACCESS_URI",
        :username=> "USERNAME",
        :password=> "PASSWORD",
        :client_id=> "CLIENT_ID",
        :client_secret=> "CLIENT_SECRET",
        # API AUTH Options
        :api_key => "API_KEY", 
        :api_secret => "API_SECRET",
        :api_user => "API_USER",
        # OTHER
        :debug=> "DEBUG",
        :console => "SPARK_API_CONSOLE"  # not a public option, meant to distinguish bin/spark_api and script/console
      }
      
      def self.execute(stdout, arguments=[])
        options = setup_options(stdout,arguments)
        libs =  " -r irb/completion"
        # Perhaps use a console_lib to store any extra methods I may want available in the cosole
        libs << (options[:oauth2] ? setup_oauth2 : setup_api_auth)
        
        bundler = (options[:console] ? "bundle exec" : "")  
        cmd = "#{export_env(options)} #{bundler} #{irb} #{libs} --simple-prompt"
        puts "Loading spark_api gem..."
        exec "#{cmd}"
      end
      
      def self.irb()
        RUBY_PLATFORM =~ /(:?mswin|mingw)/ ? 'irb.bat' : 'irb'
      end
      
      private
      def self.setup_options(stdout,arguments)
        env_options = {
          :oauth2            => false,
          :endpoint          => ENV[OPTIONS_ENV[:endpoint]],
          # OAUTH2 Options
          :access_uri  => ENV[OPTIONS_ENV[:access_uri]],
          :username=> ENV[OPTIONS_ENV[:username]],
          :password=> ENV[OPTIONS_ENV[:password]],
          :client_id=> ENV[OPTIONS_ENV[:client_id]],
          :client_secret=> ENV[OPTIONS_ENV[:client_secret]],
          # API AUTH Options
          :api_key => ENV[OPTIONS_ENV[:api_key]], 
          :api_secret => ENV[OPTIONS_ENV[:api_secret]],
          :api_user => ENV[OPTIONS_ENV[:api_user]],
          :console => ENV[OPTIONS_ENV[:console]]
        }
        cli_options = {}
        file_options = {}
        parser = OptionParser.new do |opts|
          opts.banner = <<-BANNER.gsub(/^          /,'')
            #{version}
            SparkApi Client Console - http://sparkplatform.com/docs/overview/api
            
            Usage: #{File.basename($0)} [options]
            
            Environment Variables: some options (as indicated below), will default to values of keys set in the environment. 
        
            Options are:
          BANNER
          opts.separator ""
          opts.on("-o","--oauth2",
                  "Run the API using OAuth2 credentials.  The client defaults to using the Spark API authentication mode for access. ",
                  "See http://sparkplatform.com/docs/authentication/authentication for more information on authentication types.",
                  "Default: false") { |arg| cli_options[:oauth2] = arg }
          opts.on("-e","--endpoint ENDPOINT",
                  "URI of the API.",
                  "Default: ENV['#{OPTIONS_ENV[:endpoint]}']") { |arg| cli_options[:endpoint] = arg }

          # OAUTH2
          opts.on("--client_id CLIENT_ID",
                  "OAuth2 client id",
                  "Default: ENV['#{OPTIONS_ENV[:client_id]}']") { |arg| cli_options[:client_id] = arg }
          opts.on("--client_secret CLIENT_SECRET",
                  "OAuth2 client secret",
                  "Default: ENV['#{OPTIONS_ENV[:client_secret]}']") { |arg| cli_options[:client_secret] = arg }
          opts.on("-u","--username USERNAME",
                  "OAuth2 username",
                  "Default: ENV['#{OPTIONS_ENV[:username]}']") { |arg| cli_options[:username] = arg }
          opts.on("-p","--password PASSWORD",
                  "OAuth2 password",
                  "Default: ENV['#{OPTIONS_ENV[:password]}']") { |arg| cli_options[:password] = arg }
          opts.on("--access_uri ACCESS_URI",
                  "OAuth2 path for granting access to the application",
                  "Default: ENV['#{OPTIONS_ENV[:access_uri]}']") { |arg| cli_options[:access_uri] = arg }
                    
          # API AUTH
          opts.on("--api_key API_KEY",
                  "Authentication key for running the api using the default api authentication",
                  "Default: ENV['#{OPTIONS_ENV[:api_key]}']") { |arg| cli_options[:api_key] = arg }
          opts.on("--api_secret API_SECRET",
                  "API secret for the api key",
                   "Default: ENV['#{OPTIONS_ENV[:api_secret]}']") { |arg| cli_options[:api_secret] = arg }
          opts.on("--api_user API_USER",
                  "ID of the Spark user to run the client as.",
                  "Default: ENV['#{OPTIONS_ENV[:api_user]}']") { |arg| cli_options[:api_user] = arg }
                    
          opts.on("-f", "--file FILE",
                  "Load configuration for yaml file.") { |arg| file_options = parse_file_options(arg) }
          opts.on("-d", "--debug",
                  "Show detailed request logging information.") { |arg| cli_options[:debug] = arg }
          opts.on("-v", "--version",
                  "Show client version.") { stdout.puts version; exit }
          opts.on("-h", "--help",
                  "Show this help message.") { stdout.puts opts; exit }
          opts.parse!(arguments)
        
        end
        options = env_options.merge(file_options.merge(cli_options))
        return options
      end
      
      def self.setup_api_auth
        " -r #{File.dirname(__FILE__) + '/../../lib/spark_api/cli/api_auth.rb'}"
      end
  
      def self.setup_oauth2
        " -r #{File.dirname(__FILE__) + '/../../lib/spark_api/cli/oauth2.rb'}"
      end
      
      def self.export_env(options)
        run_env = ""
        OPTIONS_ENV.each do |k,v|
          run_env << " #{v}=\"#{options[k]}\"" unless options[k].nil?
        end
        run_env
      end
      
      private 
      def self.parse_file_options(file)
        yaml = SparkApi::Configuration::YamlConfig.new(file)
        return {:oauth2 => yaml.oauth2}.merge(yaml.client_keys.merge(yaml.oauth2_keys))
      end
      
      def self.version
        "SparkApi v#{SparkApi::VERSION}"
      end
    end
  end
end
