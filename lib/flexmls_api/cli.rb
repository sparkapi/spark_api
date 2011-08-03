require 'optparse'

module FlexmlsApi
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
        :verbose => "VERBOSE",
        :console => "FLEXMLS_API_CONSOLE"  # not a public option, meant to distinguish bin/flexmls_api and script/console
      }
      
      def self.execute(stdout, arguments=[])
        options = setup_options(stdout,arguments)
        libs =  " -r irb/completion"
        # Perhaps use a console_lib to store any extra methods I may want available in the cosole
        libs << (options[:oauth2] ? setup_oauth2 : setup_api_auth)
        
        bundler = (options[:console] ? "bundle exec" : "")  
        cmd = "#{export_env(options)} #{bundler} #{irb} #{libs} --simple-prompt"
        puts "Loading flexmls_api gem..."
        exec "#{cmd}"
      end
      
      def self.irb()
        RUBY_PLATFORM =~ /(:?mswin|mingw)/ ? 'irb.bat' : 'irb'
      end
      
      private
      def self.setup_options(stdout,arguments)
        options = {
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
        
        parser = OptionParser.new do |opts|
          opts.banner = <<-BANNER.gsub(/^          /,'')
            FlexmlsApi Client Console - http://www.flexmls.com/developers/api/
            
            Usage: #{File.basename($0)} [options]
            
            Environment Variables: some options (as indicated below), will default to values of keys set in the environment. 
        
            Options are:
          BANNER
          opts.separator ""
          opts.on("-o","--oauth2",
                  "Run the API using OAuth2 credentials.  The client defaults to using the flexmls API authentication mode for access. ",
                  "See http://www.flexmls.com/developers/api/api-services/authentication/ for more information on authentication types.",
                  "Default: false") { |arg| options[:oauth2] = arg }
          opts.on("-e","--endpoint",
                  "URI of the API.",
                  "Default: ENV['#{OPTIONS_ENV[:endpoint]}']") { |arg| options[:endpoint] = arg }

          # OAUTH2
          opts.on("--client_id",
                  "OAuth2 client id",
                  "Default: ENV['#{OPTIONS_ENV[:client_id]}']") { |arg| options[:client_id] = arg }
          opts.on("--client_secret",
                  "OAuth2 client secret",
                  "Default: ENV['#{OPTIONS_ENV[:client_secret]}']") { |arg| options[:client_secret] = arg }
          opts.on("-u","--username",
                  "OAuth2 username",
                  "Default: ENV['#{OPTIONS_ENV[:username]}']") { |arg| options[:username] = arg }
          opts.on("-p","--password",
                  "OAuth2 password",
                  "Default: ENV['#{OPTIONS_ENV[:password]}']") { |arg| options[:password] = arg }
          opts.on("--access_uri",
                  "OAuth2 path for granting access to the application",
                  "Default: ENV['#{OPTIONS_ENV[:access_uri]}']") { |arg| options[:access_uri] = arg }
                    
          # API AUTH
          opts.on("--api_key",
                  "Authentication key for running the api using the default api authentication",
                  "Default: ENV['#{OPTIONS_ENV[:api_key]}']") { |arg| options[:api_key] = arg }
          opts.on("--api_secret",
                  "API secret for the api key",
                   "Default: ENV['#{OPTIONS_ENV[:api_secret]}']") { |arg| options[:api_secret] = arg }
          opts.on("--api_user",
                  "ID of the flexmls user to run the client as.",
                  "Default: ENV['#{OPTIONS_ENV[:api_user]}']") { |arg| options[:api_user] = arg }
                    
          opts.on("-v", "--verbose",
                  "Show detailed request logging information.") { |arg| options[:verbose] = arg }
          opts.on("-h", "--help",
                  "Show this help message.") { stdout.puts opts; exit }
          opts.parse!(arguments)
        
        end
        
        return options
      end
      
      def self.setup_api_auth
        " -r #{File.dirname(__FILE__) + '/../../lib/flexmls_api/cli/api_auth.rb'}"
      end
  
      def self.setup_oauth2
        " -r #{File.dirname(__FILE__) + '/../../lib/flexmls_api/cli/oauth2.rb'}"
      end
      
      def self.export_env(options)
        run_env = ""
        OPTIONS_ENV.each do |k,v|
          run_env << " #{v}=\"#{options[k]}\"" unless options[k].nil?
        end
        run_env
      end
    end
  end
end
