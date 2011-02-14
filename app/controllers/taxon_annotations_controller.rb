class TaxonAnnotationsController < ApplicationController
  
  before_filter :filter_term_names, :only => :index
  # cache including query parameters
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }
  
  def index
    @taxon_annotations = TaxonAnnotation.find(query_params)
  end
  
  
  def download
    download_query_results(TaxonAnnotation, query_params)
  end
  
  
  private
  
  
    def query_params
      setup_query_params('taxon', [:taxa, :publications], :inferred => true)
    end
    
end
