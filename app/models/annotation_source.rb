class AnnotationSource
  
  def self.taxon(params={}, result_options={})
    AnnotationSource.find(:taxon, params, result_options)
  end
  
  
  def self.gene(params={}, result_options={})
    AnnotationSource.find(:gene, params, result_options)
  end
  
  
  def self.find(node_type=:gene, params={}, result_options={})
    node_type = :taxon unless node_type == :gene
    Request.find("annotation/#{node_type}/source", params, result_options)
  end
  
end