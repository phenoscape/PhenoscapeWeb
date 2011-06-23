class WorkspacesController < ApplicationController

  def show
    
  end
  
  def update
    data = JSON.parse params['data']
    type = data.keys.first
    items = data.values.first
    existing = session[:workspace][type] || []
    session[:workspace][type] = (existing + items).uniq
  end
  
  def destroy
    data = JSON.parse params['data']
    type = data.keys.first
    items = data.values.first
    existing = session[:workspace][type] || []
    existing.delete_if {|item| items.include? item}
    session[:workspace][type] = existing
  end

end