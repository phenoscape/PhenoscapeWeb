class Gene
  
  #Return taxon annotation result from data service
  def self.find(params={}, result_options={})
    Request.find('gene/annotated', params, result_options)
  end
  
  
  def self.gene_class?(term)
    return false unless term['source'] && term['source']['id']
    ['gene_ontology', 'biological_process', 'molecular_function', 'cellular_component'].include?(term['source']['id'])
  end
  
end