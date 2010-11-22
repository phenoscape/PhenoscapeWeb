module TermHelper
  
  SYNONYM_SCOPES = {"EXACT" => "exact", "RELATED" => "related"}
  
  def formatted_synonym(synonym)
    label = synonym["name"]
    scope = SYNONYM_SCOPES[synonym["scope"]] if synonym.has_key? "scope"
    label += %| <span class="synonym-scope">(#{scope})</span>|
    return label
  end
  
end
