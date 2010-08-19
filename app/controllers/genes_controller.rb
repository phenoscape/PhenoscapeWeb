class GenesController < ApplicationController
  
  before_filter :filter_term_names, :only => :index
  
  
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
