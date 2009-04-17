# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  
  def format_taxon(name)
    if name.include? " "
      return "<i>" + name + "</i>"
    else
      return name
    end
  end
  
  
end
