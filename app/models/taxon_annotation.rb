class TaxonAnnotation
  
  #Return taxon annotation result from data service
  def self.find(params={}, result_options={})
    Request.find('annotation/taxon/distinct', params, result_options)
  end
  
end