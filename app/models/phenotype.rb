class Phenotype
  
  #Return phenotype result from data service
  def self.find(params={}, result_options={})
    Request.find('phenotype', params, result_options)
  end
  
  
  #Return facet counts result from data service
  def self.facet_counts(term_type, params={}, result_options={})
    Request.find("phenotype/facet/#{term_type}", params, result_options)
  end
  
  
  #Return profile tree result from data service
  def self.profile(params={}, result_options={})
    Request.find("phenotype/profile", params, result_options)
  end
  
  
  #Return variation tree result from data service
  def self.variationsets(params={}, result_options={})
    Request.find("phenotype/variationsets", params, result_options)
  end
  
end