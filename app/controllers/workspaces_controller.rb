class WorkspacesController < ApplicationController
  include ApplicationHelper # for extract_term_components
  
  def show
    # see application.html.erb and workspace.js for the meat
  end
  
  def update
    categorized_term = JSON.parse params['data']
    categorized_components = extract_term_components(categorized_term.values.flatten)
    
    # Since we don't show annotations in the workspace, don't ever add an annotation to the workspace. Their components are still extracted and added.
    categorized_term = {} if categorized_term.keys.first == 'annotations'
    
    [categorized_term, categorized_components].each do |terms|
      terms.each do |type, items|
        existing = session[:workspace][type] || []
        session[:workspace][type] = (existing + items).uniq
      end
    end
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