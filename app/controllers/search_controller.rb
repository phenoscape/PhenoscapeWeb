require "json"

## FIXME class-level documentation missing
class SearchController < ApplicationController
  
  caches_page :entity
  caches_page :gene
  caches_page :taxon
  
  ## FIXME need to document here the secrets of Rails as to when this
  ## gets called and why it actually has a function.
  def index
  end

  ## FIXME There seem to be a lot of common path prefixes and URL
  ## parameters interspersed throughout the code - should pull these
  ## together into a set of constants. Also, these are used in other
  ## controllers as well - maybe put into the base controller class?

  ## FIXME Should have method (and parameter!) documentation as to
  ## what it does and how it does it.  
  def entity
    if params[:find] == "true"
      match_id = find_match(params[:id], "TAO")
      #TODO check for nil match_id
      if (match_id)
        redirect_to(:action => :anatomy, :id => match_id)
        return
      else
        @input = params[:id]
        render(:action => "unknown_term")
        return
      end
    end
    @term = params[:id]
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
    @term_info = JSON.parse(response.body)
    @title = @term_info["name"]
    homology_response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term + "/homology")
    if homology_response.kind_of?(Net::HTTPOK)
      @homology_json = homology_response.body
      homology_data = JSON.parse(@homology_json)
      @homology = lump_homologies(homology_data)
    else
      @homology_json = JSON.generate({"homology" => []})
      @homology = []
    end
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary?examples=5&entity=" + @term)
    @summary = JSON.parse(response.body)
    sort_summary_characters!(@summary["characters"])
  end
  
  ## FIXME Should have method (and parameter!) documentation as to
  ## what it does and how it does it.
  def gene
    if params[:find] == "true"
      match_id = find_match(params[:id], "ZFIN")
      if (match_id)
        redirect_to(:action => :gene, :id => match_id)
        return
      else
        @input = params[:id]
        render(:action => "unknown_term")
        return
      end
    end
    @term = params[:id]
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
    @term_info = JSON.parse(response.body)
    @title = @term_info["name"]
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary?examples=5&subject=" + @term)
    @summary = JSON.parse(response.body)
    sort_summary_characters!(@summary["characters"])
  end
  
  ## FIXME Should have method (and parameter!) documentation as to
  ## what it does and how it does it.
  def taxon
    if params[:find] == "true"
      match_id = find_match(params[:id], "TTO")
      if (match_id)
        redirect_to(:action => :taxon, :id => match_id)
        return
      else
        @input = params[:id]
        render(:action => "unknown_term")
        return
      end
    end
    @term = params[:id]
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
    @term_info = JSON.parse(response.body)
    @title = @term_info["name"]
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary?examples=5&subject=" + @term)
    @summary = JSON.parse(response.body)
    sort_summary_characters!(@summary["characters"])
  end
  
  def general
    #in progress
    match_id = find_match(params[:id], "TTO,TAO,ZFIN")
    if match_id
      if match_id.index("TAO") == 0:
        redirect_to(:action => :entity, :id => match_id)
        return
      elsif match_id.index("TTO") == 0:
        redirect_to(:action => :taxon, :id => match_id)
        return
      elsif match_id.index("ZFIN") == 0:
        redirect_to(:action => :gene, :id => match_id)
        return
      end
    else
      @input = params[:id]
      render(:action => "unknown_term")
      return
    end
  end
  
  # try to find an exact term match for the given input in the given ontology
  private
  def find_match(input, ontology)
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/search?ontology=#{ontology}&name=true&syn=true&text=#{input}")
    matches = JSON.parse(response.body)["matches"]
    if not matches.empty?
     exact_name_matches = matches.find_all {|item| item["match_type"] == "name" and item["name"].downcase == input.downcase}
     if not exact_name_matches.empty?
       # pick one
       match = exact_name_matches[0]
       return match["id"]
     end
     synonym_matches = matches.find_all {|item| item["match_type"] == "synonym" and item["match_text"].downcase == input.downcase}
     if not synonym_matches.empty?
       # pick one
       match = synonym_matches[0]
       return match["id"]
     end
    end
    return nil
  end
  
  def lump_homologies(homology_data)
    homologs = Hash.new {|hash, key| hash[key] = {"sources" => []}}
    for statement in homology_data["homologies"]
      entry = homologs[statement["target"]["entity"]["id"]]
      entry["target"] = statement["target"]
      entry["sources"].push({"source" => entry["source"], "evidence" => entry["evidence"]})
    end
    return homologs.values.sort_by {|item| item["target"]["entity"]["name"]}
  end
  
  def sort_summary_characters!(characters)
    characters.sort! {|x,y| x["entity"]["name"] <=> y["entity"]["name"]}
  end
  
end
