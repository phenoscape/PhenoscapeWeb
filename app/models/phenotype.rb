class Phenotype
  
  #Return phenotype result from data service
  def self.find(params={}, result_options={})
    Request.find('phenotype', params, result_options)
  end
  
end