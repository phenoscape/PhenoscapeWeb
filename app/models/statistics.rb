class Statistics
  
  def self.find(params={}, result_options={})
    Request.find('statistics', params, result_options)
  end
  
end