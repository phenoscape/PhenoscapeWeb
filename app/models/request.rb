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
    result = JSON.parse(result) if options[:format] == :json rescue raise("Error parsing JSON response for query: http://" + self.host + url_prefix + url_suffix + "\nPost data:\n#{request.body}\nResponse:\n#{result}")
    return result
  end
  
  
  def self.result(url_suffix, url_prefix='/OBD-WS/')
    http = Net::HTTP.new(self.host)
    http.read_timeout = 500
    response = http.get(url_prefix + url_suffix)
    #response = Net::HTTP.get_response(self.host, url_prefix + url_suffix)
    return response.body
  end
  
  
  # An entity with multiple parents is returned with parents in a random-ish order.
  # These need to be sorted so we can keep track of whether or not they are saved in the workspace.
  def self.sort_parents!(structure)
    if structure.is_a? Hash
      # Sort parents
      if structure['parents']
        # Recurse into parents inside parents before sorting
        structure['parents'].select{|parent| parent['target']['parents'].present? }.each do |meta_parent|
          sort_parents! meta_parent['target']['parents']
        end
        
        # Sort the parents
        structure['parents'].sort! do |a,b|
          # Fall back to using parents.inspect when a target has parents and is not an entity with a name. It's consistent, because we just sorted it.
          (a['target']['name'] || a['target']['parents'].inspect) <=> (b['target']['name'] || a['target']['parents'].inspect)
        end
      end
      
      # Recurse into hash values
      structure.values.each do |substructure|
        sort_parents! substructure
      end
      
    # Traverse arrays
    elsif structure.is_a? Array
      structure.each do |element|
        sort_parents! element
      end
    end
    
    # Ignore strings
    
    # Return the result structure, even though we modified it in place
    return structure
  end
  
  
  def self.json_result(url_suffix, url_prefix='/OBD-WS/')
    parsed_json = JSON.parse(result(url_suffix, url_prefix)) rescue raise("Error parsing JSON response for query: http://" + self.host + url_prefix + url_suffix)
    return sort_parents! parsed_json
  end
  
  
  def self.host
    return @@host
  end
  
  
  def self.host=(val)
    @@host = val
  end
  
end