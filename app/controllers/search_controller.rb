class SearchController < ApplicationController
    
  def index
  end
  
  def anatomy
    @term = params[:id]
    ##mockup##
    # render(:action => "anatomy_mockup")
    # return
    ##mockup##
    @examples_length = 2
    # response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
    # @term_info = ActiveSupport::JSON.decode(response.body)
    begin
      #response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary?entity=" + @term)
      response = Net::HTTP.get_response("localhost", "/javascripts/dummy_summary_results.js")
      @summary = ActiveSupport::JSON.decode(response.body)
      @term_info = {"id"=>"TEST", "name"=>"TEST"}
    rescue Timeout::Error
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
      @term_info = ActiveSupport::JSON.decode(response.body)
      render(:action => "anatomy_timeout")
    end
  end
  
  def gene
    @term = params[:id]
    ##mockup##
    # render(:action => "gene_mockup")
    #     return
    ##mockup##
    @examples_length = 2
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
    @term_info = ActiveSupport::JSON.decode(response.body)
    begin
      #response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary?subject=" + @term)
      response = Net::HTTP.get_response("localhost", "/javascripts/dummy_summary_results.js")
      @summary = ActiveSupport::JSON.decode(response.body)
    rescue Timeout::Error
      render(:action => "generic_timeout")
    end
  end
  
  def taxon
    @term = params[:id]
    @examples_length = 2
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
    @term_info = ActiveSupport::JSON.decode(response.body)
    begin
      #response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary?subject=" + @term)
      response = Net::HTTP.get_response("localhost", "/javascripts/dummy_summary_results.js")
      @summary = ActiveSupport::JSON.decode(response.body)
    rescue Timeout::Error
      response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + @term)
      @term_info = ActiveSupport::JSON.decode(response.body)
      render(:action => "anatomy_timeout")
    end
  end
  
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
