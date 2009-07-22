class ContactController < ApplicationController
  
  caches_page :index
  
  def index
    @title = "Contact"
  end
  
end
