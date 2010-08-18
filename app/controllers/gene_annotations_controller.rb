class GeneAnnotationsController < ApplicationController
  
  before_filter :filter_term_names, :only => :index
  
  
  def index
    @gene_annotations = GeneAnnotation.find(query_params)
  end
  
  
  def download
    download_query_results(GeneAnnotation, query_params)
  end
  
  
  private
  
    
    def query_params
      setup_query_params('gene', [:genes])
    end

end
