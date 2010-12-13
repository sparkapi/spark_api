module FlexmlsApi
class Client
  include Authentication
  def initialize(secret = '', key ='', url='')
    @secret = secret
    @key = key
    @url = url
  end

end
end