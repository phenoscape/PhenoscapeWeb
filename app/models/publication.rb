class Publication
  
  #Return taxon annotation result from data service
  def self.find(params={}, result_options={})
    Request.find('publication/annotated', params, result_options)
  end
  
end