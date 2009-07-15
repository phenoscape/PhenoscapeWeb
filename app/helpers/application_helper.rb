# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  @@GENUS_ID = "TTO:genus"
  @@SPECIES_ID = "TTO:species"
  @@HAS_RANK = "has_rank"
  
  # takes a taxon structure or term info structure and determines if possesses an italic rank
  def italicize_taxon?(taxon)
    rank_id = nil
    if taxon.has_key?("rank")
      rank_id = taxon["rank"]
    elsif taxon.has_key?("parents")
      for link in taxon["parents"]
        if link["relation"]["id"] == @@HAS_RANK
          rank_id = link["target"]["id"]
        end
      end
    end
    return [@@GENUS_ID, @@SPECIES_ID].include?(rank_id)
  end
  
  def taxon_link(term)
    id = term["id"]
    name = term["name"]
    clazz = italicize_taxon?(term) ? 'class="italic-taxon"' : ""
    return %Q'<a #{clazz} href="/search/taxon/#{id}" title="#{id}">#{name}</a>'
  end
  
  def taxon_name(term)
    id = term["id"]
    name = term["name"]
    clazz = italicize_taxon?(term) ? 'class="italic-taxon"' : ""
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
  
  def empty?(text)
    return (text == nil or text == "")
  end
  
  def textOrNone(text)
    return empty?(text) ? "<i>None</i>" : h(text)
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
    return %Q'<a href="http://bioportal.bioontology.org/virtual/1107/#{id}" title="#{id}" target="_blank">#{name}</a>'
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
  
end
