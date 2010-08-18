# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  @@GENUS_ID = "TTO:genus"
  @@SPECIES_ID = "TTO:species"
  @@HAS_RANK = "has_rank"
  
  # takes a taxon structure or term info structure and determines if possesses an italic rank
  def italicize_taxon?(taxon)
    rank_id = nil
    if taxon.has_key?("rank")
      rank_id = taxon["rank"]["id"]
    elsif taxon.has_key?("parents")
      for link in taxon["parents"]
        if link["relation"]["id"] == @@HAS_RANK
          rank_id = link["target"]["id"]
        end
      end
    end
    return [@@GENUS_ID, @@SPECIES_ID].include?(rank_id)
  end
  
  def extinct_taxon?(taxon)
    if taxon.has_key?("extinct")
      return taxon["extinct"]
    else
      return false
    end
  end
  
  def taxon_rank(taxon)
    if taxon.has_key?("rank")
      return taxon["rank"]
    elsif taxon.has_key?("parents")
      for link in taxon["parents"]
        if link["relation"]["id"] == @@HAS_RANK
          return link["target"]
        end
      end
    end
    return nil
  end
  
  def taxon_link(term)
    logger.debug("Taxon: " + term.to_s)
    id = term["id"]
    name = term["name"]
    classes = []
    if italicize_taxon?(term)
      classes.push("italic-taxon")
    end
    if extinct_taxon?(term)
      classes.push("extinct-taxon")
    end
    clazz = classes.empty? ? "" : 'class="' + classes.join(" ") + '"'
    return %Q'<a #{clazz} href="/search/taxon/#{id}" title="#{id}">#{name}</a>'
  end
  
  def taxon_name(term)
    id = term["id"]
    name = term["name"]
    classes = []
    if italicize_taxon?(term)
      classes.push("italic-taxon")
    end
    if extinct_taxon?(term)
      classes.push("extinct-taxon")
    end
    clazz = classes.empty? ? "" : 'class="' + classes.join(" ") + '"'
    return %Q'<span #{clazz} title="#{id}">#{name}</span>'
  end
  
  @@subject_relation_mappings = {
    "OBO_REL:is_a" => "is a type of",
    "OBO_REL:part_of" => "is part of",
    "part_of" => "is part of",
    "OBO_REL:develops_from" => "develops from"
  }
  
  @@object_relation_mappings = {
    "OBO_REL:is_a" => "has subtype",
    "OBO_REL:part_of" => "may have part",
    "part_of" => "may have part",
    "OBO_REL:develops_from" => "develops into"
  }
  
  def subject_rel(id, default)
    return (@@subject_relation_mappings.has_key? id) ? @@subject_relation_mappings[id] : default
  end
  
  def object_rel(id, default)
    return (@@object_relation_mappings.has_key? id) ? @@object_relation_mappings[id] : default
  end
  
  def postcomposition?(term_info)
    # this is not a reliable means to determine if post-composition
    #TODO should replace with flag in term info data
    return term_info["id"].include?("^")
  end
  
  def empty?(text)
    return (text == nil or text == "")
  end
  
  def textOrNone(text)
    return empty?(text) ? "<i>None</i>" : (text)
  end
  
  def obscure_email(email)
    return nil if email.nil? #Don't bother if the parameter is nil.
    lower = ('a'..'z').to_a
    upper = ('A'..'Z').to_a
    email.split('').map { |char|
      output = lower.index(char) + 97 if lower.include?(char)
      output = upper.index(char) + 65 if upper.include?(char)
      output ? "&##{output};" : (char == '@' ? '&#0064;' : char)
      }.join
  end
  
  def entity_link(term)
    id = term["id"]
    name = term["name"]
    return %Q'<a href="/search/entity/#{id}" title="#{id}">#{name}</a>'
  end
  
  def gene_link(term)
    id = term["id"]
    name = term["name"]
    return %Q'<a href="/search/gene/#{id}" title="#{id}">#{name}</a>'
  end
  
  def quality_link(term)
    id = term["id"]
    name = term["name"]
    return %Q'<span title="#{id}">#{name}</span>'
  end
  
  def zfin_url(term)
    id = term["id"]
    fixed_id = id.sub(/^ZFIN:/, "")
    return "http://zfin.org/cgi-bin/webdriver?MIval=aa-markerview.apg&OID=#{fixed_id}"
  end
  
  def bioportal_tao_url(term)
    id = term["id"]
    return "http://bioportal.bioontology.org/virtual/1110/" + id
  end
  
  def bioportal_tto_url(term)
    id = term["id"]
    return "http://bioportal.bioontology.org/virtual/1081/" + id
  end
  
  def ontology(term)
    id = term["id"]
    ontology = case
    when id.index("^") != nil: ""
    when id.index("TAO") == 0: "Teleost Anatomy"
    when id.index("TTO") == 0: "Teleost Taxonomy"
    when id.index("PATO") == 0: "Quality"
    when id.index("GO") == 0: "Gene Ontology"
    when id.index("BSPO") == 0: "Spatial Ontology"
    else ""
    end
    return ontology
  end
  
  
  def sort_column(link_text, sort_field, shared_locals={})
    render :partial => "/shared/sort_column", :locals => {:link_text => link_text, :sort_by => sort_field}.merge(shared_locals)
  end
  
  
  def link_to_source_popup(annotation)
    url_hash = {:controller => :annotation_sources, :action => :popup}
    url_hash[:node_type] = annotation['gene'] ? 'gene' : 'taxon'
    url_hash[:node_id] = annotation[url_hash[:node_type]]['id']
    ['entity', 'quality', 'related_entity'].each{|field| url_hash["#{field}_id"] = annotation[field]['id'] if annotation[field] }
    url_hash[:include_inferred] = (params[:filter] && params[:filter][:include_inferred])
    url_hash[:publications] = params[:filter][:publications] if params[:filter]
    return link_to_remote(image_tag('page_text.gif', :alt => 'Source data'), :url => url_hash)
  end
  
  
  def link_submit_to(text, url_options={}, options={})
    options[:function] ||= 'link_to_function'
    options[:method] ||= 'get'
    options[:form_name] ||= 'complex_query_form'
    action = url_options.is_a?(String) ? url_options : url_for(url_options)
    
    js =  "document.#{options[:form_name]}.action = '#{action}';"
    js += "document.#{options[:form_name]}.method = '#{options[:method]}';"
    js += "document.#{options[:form_name]}.submit();"
    
    send(options[:function], text, js)
  end
  
  
  def button_submit_to(text, type, options={})
    link_submit_to(text, type, options.merge({:function => 'button_to_function'}))
  end
  
  
  def filter_term_name(id)
    return @filter_term_names[id.to_s]['name'] if @filter_term_names[id.to_s]
    return ''
  end
  
  
  def filter_operator(index, section_name)
    operator = (params[:filter] && params[:filter]["#{section_name}_match_type"] == 'all') ? 'and' : 'or'
    return (index.to_i > 0 ? "<div class='#{section_name} filter_operator'>#{operator}</div>" : '')
  end
  
end
