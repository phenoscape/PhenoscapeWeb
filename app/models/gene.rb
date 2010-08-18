class Gene
  
  #Return taxon annotation result from data service
  def self.find(params={}, result_options={})
    Request.find('gene/annotated', params, result_options)
  end
  
end