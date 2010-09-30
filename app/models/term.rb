class Term
  
  def self.find(id, result_options={})
    Request.find('term', id, result_options)
  end
  
  
  def self.find_taxon(id, result_options={})
    Request.find('term/taxon', id, result_options)
  end
  
  
  def self.names(ids, result_options={})
    ids = [ids] unless ids.is_a?(Array)
    Request.post('term/names', JSON.generate({:ids => ids, :render_postcompositions => 'structure'}), result_options)
  end
  
  
  def self.path(id, result_options={})
    Request.find("term/#{id}/path")
  end
  
  
  def self.type(term)
    return (term['source'] ? SOURCE_KEYS[term['source']['id']] : :entity)
  end
  
end