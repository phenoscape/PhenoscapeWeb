class SearchController < ApplicationController
  
  def index
    
  end
  
  def anatomy
    @term = params[:id]
  end
  
end
