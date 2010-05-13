# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '4933eb45f528a9555fe7cf6351fabc91'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def render_optional_error_file(status_code)
    if status_code == :not_found
      render_404
    else
      render_error
    end
  end
  
  def render_404
    respond_to do |type|
      @title = "The page you were looking for doesn't exist (404)"
      type.html { render :template => "errors/error_404", :layout => "application", :status => 404 }
      type.all { render :nothing => true, :status => 404 }
    end
  end
  true
  
  def render_error
    respond_to do |type|
      @title = "We're sorry, but something went wrong (500)"
      type.html { render :template => "errors/error", :layout => "application", :status => 500 }
      type.all { render :nothing => true, :status => 500 }
    end
  end
  
end

