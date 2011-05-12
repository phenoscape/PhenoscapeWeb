class Phenotype
  
  #Return phenotype result from data service
  def self.find(params={}, result_options={})
    Request.find('phenotype', params, result_options)
  end
  
  
  #Return facet counts result from data service
  def self.facet_counts(term_type, params={}, result_options={})
    Request.find("phenotype/facet/#{term_type}", params, result_options)
  end
  
end