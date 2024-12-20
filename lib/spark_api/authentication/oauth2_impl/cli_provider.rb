module SparkApi
  module Authentication
    module OAuth2Impl
      class CLIProvider < SparkApi::Authentication::BaseOAuth2Provider
        SESSION_FILE = '.spark_api_oauth2'
        
        def initialize(credentials)
          super(credentials)
          @grant_type = :password
          @persistent_sessions = false
          @session_alias = "default"
        end
        
        attr_accessor :persistent_sessions, :session_alias

        def redirect(url)
          puts "Missing OAuth2 session, redirecting..."
          puts "Please visit #{url}, login as a user, and paste the authorization code here:"
          puts "Authorization code?"
          raw_code = gets.strip

          unless raw_code.match?(/^\w+$/)
            raise "Invalid authorization code. Please try again."
          end
        end
                
        def load_session()
          @session ||= load_persistent_session
        end
      
        def save_session(session)
          @session = session
          save_persistent_session
        end
      
        def destroy_session
          destroy_persistent_session
          @session = nil
        end
      
        def persistent_sessions?
          persistent_sessions == true
        end
        
        private 
        
        def load_persistent_session
          return nil unless persistent_sessions?
          s = load_file[session_key]["session"]
          OAuthSession.new(s)
        rescue => e
          puts "no file: #{e.message}"
        end

        def save_persistent_session
          return unless persistent_sessions? && !@session.nil?
          yaml = load_file
          unless yaml.include? session_key
            yaml[session_key] = {}
            yaml[session_key]["created"] = Time.now   
          end
          yaml[session_key]["session"] = @session.to_hash
          yaml[session_key]["modified"] = Time.now   
          File.open(filename, "w") {|f| f.write(yaml.to_yaml) }
        end
        
        def session_key
          "#{client_id}_#{session_alias}"
        end
        
        def destroy_persistent_session
          return unless persistent_sessions?
          yaml = load_file
          return unless yaml.include? session_key 
          yaml[session_key].delete("session")
          File.open(filename, "w") {|f| f.write(yaml.to_yaml) }
        end
        
        def filename
          ENV['HOME'] + "/" + SESSION_FILE
        end
        
        def load_file
          yaml = {}
          begin
            yaml = YAML.respond_to?(:unsafe_load) ? YAML.unsafe_load(File.open(filename)) : YAML.load(File.open(filename))
            yaml = {} if yaml == false
          rescue => e
            puts "no file: #{e.message}"
          end
          yaml
        end
      end
    end
  end
end
