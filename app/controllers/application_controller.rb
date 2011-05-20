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
  
  before_filter :set_host
  
  
  def set_host
    Request.host = self.request.host
  end
  
  
  #find all possible filter term ids and set id array
  def filter_term_names
    term_ids = []
    possible_terms = [:genes, :taxa, :publications]
    possible_terms.each do |term_type|
      term_ids += params[:filter][term_type].values if params[:filter] && params[:filter][term_type]
    end
    if params[:filter] && params[:filter][:phenotypes]
      params[:filter][:phenotypes].each{|index, ph| term_ids += ph.values.compact }
    end
    ['true', 'false', true, false].each{|val| term_ids.delete(val) } #remove any boolean values from "including parts" field
    
    #Add any ids from facet paths if present
    [:entity, :quality, :related_entity, :taxon, :gene].each do |term_type|
      results = instance_variable_get("@#{term_type}_facets")
      if results && results['facet'].any?
        term_ids += results['facet'].map{|i| i["id"]}.compact
        term_ids += results['facet'].last['children'].map{|i| i["id"]}.compact
      end
    end
    
    set_filter_term_names_for_ids(term_ids.uniq.compact)
  end
  
  
  def set_filter_term_names_for_ids(term_id_or_ids)
    term_ids = term_id_or_ids.is_a?(Array) ? term_id_or_ids : [term_id_or_ids]
    term_ids.compact!
    @filter_term_names = {}
    unless term_ids.blank?
      result = Term.names(term_ids)
      if result['terms'] && result['terms'].any?
        result['terms'].each{|term| @filter_term_names[term['id']] = term }
      end
    end
  end
  
  
  #sets up params used for query to data service for taxon annotations
  def setup_query_params(default_sortby, additional_param_items=[], options={})
    params[:filter] ||= {}
    params[:filter][:phenotypes] ||= []
    params[:filter][:index] ||= 0
    params[:filter][:limit] ||= 20
    params[:filter][:sortby] ||= default_sortby
    params[:filter][:desc] ||= 'false'
    additional_param_items.each{|item_name| params[:filter][item_name] ||= [] }
    
    #Compile query params and send request
    query_params = {:query => build_json_query(additional_param_items, options)}
    [:index, :limit, :sortby, :desc].each{|f| query_params[f] = params[:filter][f] }
    query_params[:postcompositions] = 'structure'
    return query_params
  end
  
  
  #builds json query specification
  def build_json_query(additional_param_items=[], options={})
    options[:any_or_all_sections] ||= []
    
    query = {:phenotype => []}
    additional_param_items.each do |item_name|
      query[item_name.to_s.singularize.to_sym] = []
      query[:gene_class] = [] if item_name.to_s.singularize.to_sym == :gene
    end
    query[:include_inferred] = (params[:filter][:include_inferred] == 'true') if options[:inferred]
    options[:any_or_all_sections].each do |section| 
      query["match_all_#{section}".to_sym] = (params[:filter]["#{section}_match_type"] == 'all')
    end
    
    params[:filter][:phenotypes].each do |index, ph|
      phenotype = {}
      [:entity, :quality, :related_entity].each do |phenotype_component|
        phenotype[phenotype_component] = {:id => ph[phenotype_component]} unless ph[phenotype_component].blank?
      end
      phenotype[:entity][:including_parts] = (ph[:including_parts] == 'true') if phenotype[:entity]
      query[:phenotype] << phenotype
    end
    additional_param_items.each do |item_name|
      params[:filter][item_name].each do |index, id|
        if item_name.to_s == 'genes'
          query_section_name = Gene.gene_class?(@filter_term_names[id]) ? :gene_class : :gene
          query[query_section_name] << {:id => id}
        else
          query[item_name.to_s.singularize.to_sym] << {:id => id}
        end
      end
    end
    pp query
    return URI.encode(JSON.generate(query))
  end
  
  
  #construct download from query results in tab-delimited or JSON format
  def download_query_results(model_class, q_params)
    q_params[:index] = 0
    q_params[:limit] = nil
    q_params[:postcompositions] = 'none'
    filename = model_class.to_s.pluralize.titleize
    if params[:media] == 'json'
      send_data(model_class.find(q_params, :format => :plain), :filename => "#{filename}.json", :type => :json)
    else #tab-delimited text
      q_params[:media] = 'txt'
      send_data(model_class.find(q_params, :format => :plain), :filename => "#{filename}.txt", :type => :text)
    end
  end
  
  
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

