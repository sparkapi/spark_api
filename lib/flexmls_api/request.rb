module FlexmlsApi::Request

  def request(method, path, options={}, raw = false)
    fullpath = "http://#{endpoint}/#{version}/#{path}"
    puts "#{method.to_s.upcase} #{fullpath}"
  end


end
