class TermController < ApplicationController
  
  before_filter :validate_term_type, :except => :tree
  
  def tree
    path = Term.path(params[:id])['path']
    level = 0
    path.each_with_index{|level_node, node_index| level = node_index and break if level_node['id'] == params['id']}
    render :partial => 'term_tree_children', :locals => {:path => path, :level => level}
  end
  
  
  private
  
  
    def validate_term_type
      redirect_to :controller => :search, :action => :index and return if params[:id].blank?
      
      if ['taxon','publication'].include?(action_name)
        term = Term.send("find_#{action_name}", params[:id])
      else
        term = Term.find(params[:id])
      end
      term_type = Term.type(term).to_s
      unless action_name == term_type
        redirect_to :action => term_type, :id => params[:id] and return
      end
      instance_variable_set("@#{action_name}", term)
    end
  
  
end
