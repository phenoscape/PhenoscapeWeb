class Request
  
  #params - hash of parameters sent to data service
  #options - hash of options used for parsing, setting up request, etc.
  #  :format - :json, or :plain
  def self.find(url, params={}, options={})
    if params.is_a?(Hash)
      params[:media] ||= 'json'
      params_str = params.blank? ? '' : params.to_params
      url += "?" + params_str unless params_str.blank?
    else
      url += "/#{params}" #ex: 'term/1'
    end
    options[:format] ||= :json
    method = options[:format] == :json ? :json_result : :result
    return Request.send(method, url)
  end
  
  
  def self.post(url_suffix, body=nil, options={}, url_prefix='/OBD-WS/')
    request = Net::HTTP::Post.new("http://" + self.host + url_prefix + url_suffix)
    request['content-type'] = 'application/json'
    request.body = body
    response = Net::HTTP.start(self.host){|http| http.request(request) }
    options[:format] ||= :json
    result = response.body
    result = JSON.parse(result) if options[:format] == :json
    return result
  end
  
  
  def self.result(url_suffix, url_prefix='/OBD-WS/')
    response = Net::HTTP.get_response(self.host, url_prefix + url_suffix)
    return response.body
  end
  
  
  def self.json_result(url_suffix, url_prefix='/OBD-WS/')
    return JSON.parse(result(url_suffix, url_prefix))
  end
  
  
  def self.host
    return @@host
  end
  
  
  def self.host=(val)
    @@host = val
  end
  
end