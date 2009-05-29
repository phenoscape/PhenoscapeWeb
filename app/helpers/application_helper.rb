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
  
  
end
