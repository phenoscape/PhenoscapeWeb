class TaxaController < ApplicationController
  
  before_filter :filter_term_names, :only => :index
  # cache including query parameters
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }
  
  def index
    @taxa = Taxon.find(query_params)
  end
  
  
  def download
    download_query_results(Taxon, query_params)
  end
  
  
  private
  
    
    def query_params
      setup_query_params('order', [:taxa, :publications], 
        :any_or_all_sections => [:phenotypes, :publications], :inferred => true)
    end

end
