# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def format_taxon(name)
    if name.include? " "
      return "<i>" + name + "</i>"
    else
      return name
    end
  end
  
  def taxon_link(term)
    id = term["id"]
    name = term["name"]
    name = "<i>" + name + "</i>" if name.include? " "
    return %Q'<a href="/search/taxon/#{id}" title="#{id}">#{name}</a>'
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
  
  def empty(text)
    return (text == nil or text == "")
  end
  
  def textOrNone(text)
    return empty(text) ? "<i>None</i>" : h(text)
  end
  
end
