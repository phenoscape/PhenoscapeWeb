class AnnotationSourcesController < ApplicationController
  
  def popup
    phenotype, term_ids = {}, []
    [:entity, :quality, :related_entity].each do |phenotype_component|
      unless params["#{phenotype_component}_id"].blank?
        phenotype[phenotype_component] = params["#{phenotype_component}_id"]
        term_ids << phenotype[phenotype_component]
      end
    end
    term_ids << params[:node_id]
    set_filter_term_names_for_ids(term_ids)
    
    node_type = params[:node_type] == 'taxon' ? :taxon : :gene
    annotation_sources = AnnotationSource.find(node_type, {:query => build_json_query(node_type, phenotype)})
    
    render :update do |page|
      page.replace_html 'annotation_source_popup', :partial => 'popup_content', 
        :locals => {:phenotype => phenotype, :annotation_sources => annotation_sources}
      page << "jQuery('#annotation_source_popup').dialog('open');"
    end
  end
  
  
  private
  
    
    #builds json query specification
    def build_json_query(node_type, phenotype)
      phenotype_params  = {}
      phenotype.each{|component, id| phenotype_params[component] = {:id => id} }
      query = {:phenotype => [phenotype_params]}
      query[node_type] = [{:id => params[:node_id]}]
      query[:include_inferred] = (params[:include_inferred] == 'true')
      query[:publication] = []
      params[:publications].each{|index, id| query[:publication] << {:id => id} } if params[:publications]
      return URI.encode(JSON.generate(query))
    end
    
end