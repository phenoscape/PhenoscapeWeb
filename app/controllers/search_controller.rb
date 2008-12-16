class SearchController < ApplicationController
  
  def index
    
  end
  
  def anatomy
    @term = params[:id]
    response = Net::HTTP.get_response("localhost", "/OBD-WS/phenotypes/summary/" + @term)
    @summary = ActiveSupport::JSON.decode(response.body)
  end
  
  def taxonomy
    @term = params[:id]
  end
  
end
