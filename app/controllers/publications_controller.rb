class PublicationsController < ApplicationController
  
  before_filter :filter_term_names, :only => :index
  # cache including query parameters
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }
  
  def index
    @publications = Publication.find(query_params)
  end
  
  
  def download
    download_query_results(Publication, query_params)
  end
  
  
  private
  
    
    def query_params
      setup_query_params('publication', [:taxa], :any_or_all_sections => [:phenotypes, :taxa])
    end

end
