require_relative 'dev_auth'

class Custom_auth
  include Dev_auth
  attr_accessor :role
  def initialize(role=:user)
    @role = role
    if @role == :dev then
      self.initialize_as_dev
      self.authenticate_as_dev
    else
      # your normal auth logic here
    end
  end
end

#example usage
auth = Custom_auth.new(:dev)
account = auth.client.get '/my/account'
pp account
