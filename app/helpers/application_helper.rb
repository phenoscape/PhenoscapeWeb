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
  
  
  def subject_relationship(id)
    relationship(id, :subject)
  end
  
  
  def object_relationship(id)
    relationship(id, :object)
  end
  
  
  def relationship(id, type='subject')
    mapping = type.to_s == 'subject' ? SUBJECT_RELATION_MAPPINGS : OBJECT_RELATION_MAPPINGS
    return (mapping.has_key? id) ? mapping[id] : id
  end
  
  
  def relationship_image_tag(id, type='subject')
    rel = relationship(id, type)
    return (rel ? image_tag("relationship_icons/#{rel.underscore.gsub(' ','_')}.gif", :alt => rel) : '')
  end
  
  
  def group_relationships(term)
    relationships = []
    if Term.type(term) == :taxon
      relationships[0] = {'Parent' => [term['parent']]}
      relationships[1] = {'Children' => []}
      term['children'].each{|element| relationships[1]['Children'] << element if element }
    else
      ['parents', 'children'].each_with_index do |rel_type, rel_index|
        relationships[rel_index] = {}
        term[rel_type].each do |element|
          rel_name = relationship(element['relation']['id'], (rel_index == 0 ? :subject : :object))
          relationships[rel_index][rel_name] ||= []
          relationships[rel_index][rel_name] << element['target']
        end
        #sort targets alphabetically by name
        relationships[rel_index].each do |rel_name, targets|
          relationships[rel_index][rel_name] = targets.sort{|a,b| a['name'].downcase <=> b['name'].downcase }
        end
      end
    end
    return relationships
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
  
  
  def external_link_to(link_text, link_url)
    link_to link_text + ' ' + image_tag('external_link_icon.gif'), link_url, :popup => true
  end
  
  
  def help_link(topic)
    link_to "[help]", "http://www.phenoscape.org/wiki/Knowledgebase:#{topic}", :popup => true, :class => "kb-help"
  end
  
  def filter_operator(index, section_name)
    operator = (params[:filter] && params[:filter]["#{section_name}_match_type"] == 'all') ? 'and' : 'or'
    return (index.to_i > 0 ? "<div class='#{section_name} filter_operator'>#{operator}</div>" : '')
  end
  
  
  def search_params_for_term(term_type, term_id)
    search_params = {}
    if !term_type.blank? && !term_id.blank?
      search_params[:filter] = {}
      case term_type
        when :entity, :quality
          search_params[:filter][:phenotypes] = {'0' => {term_type => term_id}}
        else # :gene, :taxon, :publication
          search_params[:filter][term_type.to_s.pluralize] = {'0' => term_id}
      end
    end
    return search_params
  end
  
  
  def filter_term_name(id)
    return @filter_term_names[id.to_s]['name'] if @filter_term_names[id.to_s]
    return ''
  end
  
  
  def add_names_to_filter_terms(terms)
    newTerms = {}
    terms.each do |term, id|
      newTerms[term] = {'id' => id, 'name' => filter_term_name(id)}
    end
    return newTerms
  end
  
  
  def filter_term_link(id)
    return term_link(@filter_term_names[id.to_s]) if @filter_term_names[id.to_s]
    return ''
  end
  
  
  def filter_term_page_link(id)
    return term_page_link(@filter_term_names[id.to_s]) if @filter_term_names[id.to_s]
    return ''
  end
  
   
  def term_page_link(term, link_text=nil, html_options={})
    if (term['name'].blank? && term['label'].blank?) && !term['parents'].blank?
      format_term(term, 'term_page_link')
    else
      type = Term.type(term)
      if type
        link_to((link_text ? link_text : display_term(term)), {:controller => :term, :action => type, :id => term['id']}, 
          html_options)
      end
    end
  end
  
  
  def term_link(term)
    if (term['name'].blank? && term['label'].blank?) && !term['parents'].blank?
      format_term(term, 'term_link')
    else
      element_id = "term_link_#{unique_id}"
      str = "<span id='#{element_id}' class='term_link'>#{display_term(term)}</span>"
      str += "<script>jQuery(document).ready(function(){initializeTooltip('##{element_id}', '#{term['id']}');})</script>"
      return str
    end
  end
  
  
  def format_term(term, link_method='term_link')
    if term['name'].blank? && term['label'].blank?
      if term['parents']
        genus = {}
        differentia = []
        term['parents'].each_with_index do |relationship, index|
          relation_id = relationship['relation']['id']
          if relation_id == "OBO_REL:is_a"
            genus = relationship['target']
          else
            relation_substitute = POSTCOMPOSTION_RELATION_MAPPINGS[relation_id] || "of"
            differentia << " #{relation_substitute} " + send(link_method, relationship['target'])
          end
        end
        return send(link_method, genus) + differentia.join(", ");
      else
        term['name'] = 'unnamed'
        return send(link_method, term)
      end
    else
      send(link_method, term)
    end
  end
  
  
  def display_term(term)
    content_tag :span, :class => term_css_classes(term) do
      h(term['name'].blank? && term['label'].blank? ? 'unnamed' : (term['name'] || term['label']))
    end
  end
  
  
  def term_css_classes(term)
    css_class = ''
    css_class += ' extinct-taxon' if term['extinct']
    css_class += ' italic-taxon' if term['rank'] && ['genus', 'species'].include?(term['rank']['name'])
    css_class += ' italic' if Term.type(term) == :gene
    return css_class
  end
  
  
  def comma_separated_list(items, options={})
    if items.length <= 10
      items.map!{|i| send(options[:helper_per_item], i)} if options[:helper_per_item]
      return items.join(', ')
    end
    options[:tooltip] ||= false
    
    suffix = unique_id
    collapsed_set = items[0..9]
    collapsed_set.map!{|i| send(options[:helper_per_item], i)} if options[:helper_per_item]
    str = "<span id='less_content_#{suffix}'>#{collapsed_set.join(', ')}...<br />"
    if options[:tooltip]
      str += term_page_link(options[:tooltip], "[Show All #{items.length}]", :class => 'toggle_link') + "</span>"
    else
      expanded_set = options[:helper_per_item] ? items.map{|i| send(options[:helper_per_item], i)} : items
      str += link_to_function("[Show All #{items.length}]", "toggleCommaSeparatedList('#{suffix}')", :class => 'toggle_link')
      str += "</span><span id='more_content_#{suffix}' style='display:none;'>" + expanded_set.join(', ')
      str += "<br />" + link_to_function("[Collapse]", "toggleCommaSeparatedList('#{suffix}')", :class => 'toggle_link') + "</span>"
    end
    return str
  end
  
  
  def unique_id
    "#{(Time.now.to_f*1000).to_i}#{rand(9999)}"
  end
  
end
