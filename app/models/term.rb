class Term
  
  def self.find(id, result_options={})
    Request.find('term', id, result_options)
  end
  
  
  def self.find_taxon(id, result_options={})
    Request.find('term/taxon', id, result_options)
  end
  
  
  def self.find_publication(id, result_options={})
    Request.find('term/publication', id, result_options)
  end
  
  
  def self.find_publication_matrix(id, params={}, result_options={})
    Request.find("term/publication/#{id}/matrix", params, result_options)
  end
  
  
  def self.find_publication_otus(id, params={}, result_options={})
    Request.find("term/publication/#{id}/otus", params, result_options)
  end
  
  
  def self.names(ids, result_options={})
    ids = [ids] unless ids.is_a?(Array)
    Request.post('term/names', JSON.generate({:ids => ids, :render_postcompositions => 'structure'}), result_options)
  end
  
  
  def self.path(id, result_options={})
    Request.find("term/#{id}/path")
  end
  
  
  def self.type(term)
    if term['source']
      return SOURCE_KEYS[term['source']['id']]
    elsif (term['type']) && (term['type']['id'] == 'SO:0001027')
      return :zfin_genotype
    elsif (term['type']) && (term['type']['id'] == 'SO:0000034')
      return :zfin_morpholino
    end
    return :entity
  end
  
end