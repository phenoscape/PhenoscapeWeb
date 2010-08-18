class Term
  
  def self.find(id, result_options={})
    Request.find('term', id, result_options)
  end
  
  
  def self.names(ids, result_options={})
    ids = [ids] unless ids.is_a?(Array)
    Request.post('term/names', JSON.generate({:ids => ids}), result_options)
  end
  
end