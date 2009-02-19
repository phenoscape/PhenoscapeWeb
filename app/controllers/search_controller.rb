class SearchController < ApplicationController
    
  def index
  end
  
  def anatomy
    @term = params[:id]
    ##mockup##
    render(:action => "anatomy_mockup")
    return
    ##mockup##
    begin
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary/anatomy/" + @term)
    #response = Net::HTTP.get_response("localhost", "/javascripts/dummy_anatomy_summary.js")
      @summary = ActiveSupport::JSON.decode(response.body)
    rescue Timeout::Error
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
      @term_info = ActiveSupport::JSON.decode(response.body)
      render(:action => "anatomy_timeout")
    end
  end
  
  def gene
    @term = params[:id]
    ##mockup##
    render(:action => "gene_mockup")
    return
    ##mockup##
    begin
    #response = Net::HTTP.get_response(self.request.host, "/javascripts/dummy_gene_summary.js")
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary/gene/" + @term)
      @results = ActiveSupport::JSON.decode(response.body)
    rescue Timeout::Error
      render(:action => "generic_timeout")
    end
  end
  
  def taxonomy
    @term = params[:id]
    ##mockup##
    render(:action => "taxon_mockup")
    return
    ##mockup##
  end
  
  def phenotypes
    type = params[:type]
    begin
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
        response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/anatomy/" + params[:id] + "/genes/" + params[:quality])
        #response = Net::HTTP.get_response(self.request.host, "/javascripts/dummy_anatomy_results_gene.js")
        @results = ActiveSupport::JSON.decode(response.body)
        render(:action => "genes_phenotypes")
      end
    rescue Timeout::Error
      render(:action => "generic_timeout")
    end
  end
  
  def annotation
    ##mockup##
    render(:action => "annotation_mockup")
    return
    ##mockup##
  end
  
  def publication
    ##mockup##
    render(:action => "publication_mockup")
    return
    ##mockup##
  end
  
end
