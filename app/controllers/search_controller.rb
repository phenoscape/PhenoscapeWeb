## FIXME class-level documentation missing
class SearchController < ApplicationController
  
  
  ## FIXME need to document here the secrets of Rails as to when this
  ## gets called and why it actually has a function.
  def index
    response = Net::HTTP.get_response(self.request.host, timestamp_path())
    @timestamp = Date.strptime(JSON.parse(response.body)["refresh_date"])
    @statistics = Statistics.find()
  end
  
  
  def autocomplete
    search_params = @template.search_params_for_term(SOURCE_KEYS[params[:ac_term_source]], params[:ac_term_id])
    controller = (SOURCE_KEYS[params[:ac_term_source]] == :gene) ? :gene_annotations : :taxon_annotations
    redirect_to :controller => controller, :action => :index, :params => search_params
  end
  
  
  def term_filter
    term_id = nil
    unless params[:term_id].blank?
      term_id = params[:term_id]
      set_filter_term_names_for_ids(term_id)
    end
    render :update do |page|
      page.replace_html 'term_filter', '' if params[:next_term_index].to_i == 0
      page.insert_html :bottom, 'term_filter', :partial => 'term_filter_item', 
        :locals => {:term_id => term_id, :index => params[:next_term_index].to_i, :field_name => params[:field_name]}
      page << "jQuery('#term_filter_container').dialog('close')"
    end
  end
  
  
  def phenotype_filter
    phenotype, term_ids = {}, []
    [:entity, :quality, :related_entity].each do |phenotype_component|
      unless params["#{phenotype_component}_id"].blank?
        phenotype[phenotype_component] = params["#{phenotype_component}_id"]
        term_ids << phenotype[phenotype_component]
      end
    end
    set_filter_term_names_for_ids(term_ids)
    
    render :update do |page|
      if !params[:replace_phenotype_index].blank?
        page.replace_html "phenotype_filter_item_#{params[:replace_phenotype_index]}", :partial => 'phenotype_filter_item', 
          :locals => {:phenotype => phenotype, :index => params[:replace_phenotype_index].to_i}
        page << "jQuery('#broaden_refine_menu').click();"
      else
        page.replace_html 'phenotype_filter', '' if params[:next_phenotype_index].to_i == 0
        page.insert_html :bottom, 'phenotype_filter', :partial => 'phenotype_filter_item', :locals => {:phenotype => phenotype, 
          :index => params[:next_phenotype_index].to_i}
        page << "jQuery('#phenotype_filter_container').dialog('close')"
      end
      page << "changeSectionFilterOperators('phenotypes');"
    end
  end
  
  
  def publication_filter
    publication_id = nil
    unless params[:publication_id].blank?
      publication_id = params[:publication_id]
      set_filter_term_names_for_ids(publication_id)
    end
    render :update do |page|
      page.replace_html 'publication_filter', '' if params[:next_publication_index].to_i == 0
      page.insert_html :bottom, 'publication_filter', :partial => 'publication_filter_item', 
        :locals => {:publication_id => publication_id, :index => params[:next_publication_index].to_i}
      page << "jQuery('#publication_filter_container').dialog('close')"
      page << "changeSectionFilterOperators('publications');"
    end
  end
  
  
  def term_tooltip
    @term = Term.find(params[:id])
    @term_type = Term.type(@term)
    @term = Term.find_taxon(params[:id]) if @term_type == :taxon
    render :partial => 'term_tooltip'
  end
  
  
  def timestamp_path()
    return "/OBD-WS/timestamp/"
  end
  
end
