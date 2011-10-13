class Attribute
  def self.all(options={})
    attributes_hash = Request.json_result('term/attributes')['attributes']
    if options[:format] == :array_for_select_options
      return attributes_hash.map { |attr| [attr['name'], attr['id']] }
    end
    return attributes_hash
  end
end
