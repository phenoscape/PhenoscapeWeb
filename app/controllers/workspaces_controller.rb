class WorkspacesController < ActionController::Base

  before_filter :initialize_session_workspace

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

  after_filter :debug_session
  private
    def debug_session
      logger.error "SESSION: #{session.inspect}"
    end
    
    def initialize_session_workspace
      session[:workspace] ||= {}
    end
  
end