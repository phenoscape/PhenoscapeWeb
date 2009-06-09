## FIXME class-level documentation missing
class SearchController < ApplicationController
  
  caches_page :anatomy
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
  def anatomy
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
    @term_info = ActiveSupport::JSON.decode(response.body)
    homology_response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term + "/homology")
    @homology_json = homology_response.body
    homology_data = ActiveSupport::JSON.decode(@homology_json)
    @homology = lump_homologies(homology_data)
    begin
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary?examples=5&entity=" + @term)
      @summary = ActiveSupport::JSON.decode(response.body)
    rescue Timeout::Error
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
      @term_info = ActiveSupport::JSON.decode(response.body)
      render(:action => "anatomy_timeout")
    end
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
    @examples_length = 2
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
    @term_info = ActiveSupport::JSON.decode(response.body)
    begin
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary?examples=5&subject=" + @term)
      #response = Net::HTTP.get_response(self.request.host, "/javascripts/dummy_summary_results.js")
      @summary = ActiveSupport::JSON.decode(response.body)
    rescue Timeout::Error
      render(:action => "generic_timeout")
    end
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
    @examples_length = 2
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
    @term_info = ActiveSupport::JSON.decode(response.body)
    begin
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary?examples=5&subject=" + @term)
      #response = Net::HTTP.get_response(self.request.host, "/javascripts/dummy_summary_results.js")
      @summary = ActiveSupport::JSON.decode(response.body)
    rescue Timeout::Error
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
      @term_info = ActiveSupport::JSON.decode(response.body)
      render(:action => "anatomy_timeout")
    end
  end
  
  # try to find an exact term match for the given input in the given ontology
  private
  def find_match(input, ontology)
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/search?ontology=#{ontology}&name=true&syn=true&text=#{input}")
    matches = ActiveSupport::JSON.decode(response.body)["matches"]
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
  
end
