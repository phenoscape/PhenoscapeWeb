class GenesController < ApplicationController
  
  before_filter :filter_term_names, :only => :index
  # cache including query parameters
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }
  
  def index
    @genes = Gene.find(query_params)
  end
  
  
  def download
    download_query_results(Gene, query_params)
  end
  
  
  private
  
    
    def query_params
      setup_query_params('gene', [], :any_or_all_sections => [:phenotypes])
    end

end
