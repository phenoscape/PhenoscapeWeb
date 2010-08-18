class GeneAnnotation
  
  #Return gene annotation result from data service
  def self.find(params={}, result_options={})
    Request.find('annotation/gene', params, result_options)
  end
  
end