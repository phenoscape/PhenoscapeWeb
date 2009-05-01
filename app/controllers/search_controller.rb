## FIXME class-level documentation missing
class SearchController < ApplicationController

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
    @term = params[:id]
    #@examples_length = 2
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
    @term_info = ActiveSupport::JSON.decode(response.body)
    begin
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary?examples=5&entity=" + @term)
      #response = Net::HTTP.get_response(self.request.host, "/javascripts/dummy_summary_results.js")
      logger.info("RESULTS: " + response.body)
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
  
  ## FIXME Should have method (and parameter!) documentation as to
  ## what it does and how it does it.
  def phenotypes
    type = params[:type]
    begin
      @quality = params[:quality]
      if type == "taxa"
        ##mockup##
        render(:action => "taxa_phenotypes_mockup")
        return
        ##mockup##
        response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/anatomy/" + params[:id] + "/taxa/" + params[:quality])
        #response = Net::HTTP.get_response(self.request.host, "/javascripts/dummy_anatomy_results_taxon.js")
        @results = ActiveSupport::JSON.decode(response.body)
        #logger.info("RESULTS: " + ActiveSupport::JSON.encode(@results))
        render(:action => "taxa_phenotypes")
      else
        ##mockup##
        render(:action => "genes_phenotypes_mockup")
        return
        ##mockup##
        response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/anatomy/" + params[:id] + "/genes/" + params[:quality])
        #response = Net::HTTP.get_response(self.request.host, "/javascripts/dummy_anatomy_results_gene.js")
        @results = ActiveSupport::JSON.decode(response.body)
        render(:action => "genes_phenotypes")
      end
    rescue Timeout::Error
      render(:action => "generic_timeout")
    end
  end
  
  ## FIXME Should have method (and parameter!) documentation as to
  ## what it does and how it does it.
  def annotation
    ##mockup##
    render(:action => "annotation_mockup")
    return
    ##mockup##
  end
  
  ## FIXME Should have method (and parameter!) documentation as to
  ## what it does and how it does it.
  def publication
    ##mockup##
    render(:action => "publication_mockup")
    return
    ##mockup##
  end
  
end
