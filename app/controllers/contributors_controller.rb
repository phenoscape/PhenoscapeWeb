class ContributorsController < ApplicationController
  
  caches_page :index
  
  def index
    @title = "Contributors"
  end  

end
