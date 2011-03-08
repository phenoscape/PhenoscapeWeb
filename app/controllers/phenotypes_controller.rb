class PhenotypesController < ApplicationController
  
  before_filter :filter_term_names, :only => :index
  # cache including query parameters
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }
  
  def index
    @phenotypes = Phenotype.find(query_params)
  end
  
  
  def download
    download_query_results(Phenotype, query_params)
  end
  
  
  private
  
  
    def query_params
      setup_query_params('entity', [:taxa, :publications, :genes], :any_or_all_sections => [:taxa, :genes, :publications], :inferred => false)
    end
    
end
