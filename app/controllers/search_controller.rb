class SearchController < ApplicationController
    
  def index
  end
  
  def anatomy
    @term = params[:id]
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary/anatomy/" + @term)
    #response = Net::HTTP.get_response("localhost", "/javascripts/dummy_anatomy_summary.js")
    @summary = ActiveSupport::JSON.decode(response.body)
  end
  
  def gene
    @term = params[:id]
    #response = Net::HTTP.get_response(self.request.host, "/javascripts/dummy_gene_summary.js")
    response = Net::HTTP.get_response(self.request.host, "/OBD-WS/phenotypes/summary/gene/" + @term)
    @results = ActiveSupport::JSON.decode(response.body)
  end
  
  def taxonomy
    @term = params[:id]
  end
  
  def phenotypes
    type = params[:type]
    if type == "taxa"
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
  end
  
end
