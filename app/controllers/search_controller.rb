class SearchController < ApplicationController
  
  def index
    
  end
  
  def anatomy
    @term = params[:id]
    #response = Net::HTTP.get_response("localhost", "/OBD-WS/phenotypes/summary/" + @term)
    response = Net::HTTP.get_response("localhost", "/javascripts/dummy_anatomy_summary.js")
    logger.info(ActiveSupport::JSON.decode(response.body)["qualities"][0]["taxon_annotations"]["annotation_count"])
    @summary = ActiveSupport::JSON.decode(response.body)
    
  end
  
  def taxonomy
    @term = params[:id]
  end
  
end
