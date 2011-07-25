class PhenotypesController < ApplicationController
  
  before_filter :filter_term_names, :only => :index
  # cache including query parameters
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }
  caches_action :facets, :cache_path => Proc.new { |controller| controller.params }
  
  def index
    @phenotypes = Phenotype.find(query_params)
  end
  
  
  def facets
    setup_facet_counts
    @phenotypes = Phenotype.find(query_params)
  end
  
  
  def profile_tree
    params[:source] = 'profile_tree' # Used in _phenotype_filter_item.html.erb to hide broaden/refine link
    filter_term_names
    respond_to do |format|
      format.html do
        @phenotypes = Phenotype.find(query_params)
      end
      format.js do
        # Query for taxa for the given phenotypes
        qp = query_params
        qp['taxon'] = params[:taxon] if params[:taxon].present?
        @taxa = Phenotype.profile(qp)
        
        # Collect taxon IDs for name lookup later
        taxon_ids = @taxa['matches'].map {|taxon| taxon['taxon_id'] }

        # Query for another level of taxa, if specified
        if params[:levels].to_i > 1
          @taxa['matches'].each do |taxon|
            qp['taxon'] = taxon['taxon_id']
            taxon['matches'] = Phenotype.profile(qp)['matches']
            taxon_ids += taxon['matches'].map {|t| t['taxon_id'] }
          end
        end
        
        # Look up names for the taxa 
        name_map = Term.names(taxon_ids)['terms'].each_with_object({}) {|term, map| map[term['id']] = term['name'] }
        @taxa['matches'].each do |taxon|
          taxon['name'] = name_map[taxon['taxon_id']]
          if taxon['matches']
            taxon['matches'].each do |t|
              t['name'] = name_map[t['taxon_id']]
            end
          end
        end
        
        render :js => "window.profile_tree.query_callback(JSON.decode('#{@taxa['matches'].to_json}'), '#{params[:taxon]}')"
      end
    end
  end
  
  
  def download
    download_query_results(Phenotype, query_params)
  end
  
  
  private
  
  
    def query_params
      sections = [:taxa, :genes]
      sections << :publications unless action_name == 'facets'
      setup_query_params('entity', sections, :any_or_all_sections => sections, :inferred => false)
    end
    
    
    def setup_facet_counts
      params[:facet_paths] ||= {}
      params[:filter] ||= {}
      params[:filter][:phenotypes] = {'0' => {}}
      [:taxa, :genes].each{|type| params[:filter][type] = {'0' => nil} }
      @selected_term_ids = {}
      [:entity, :quality, :related_entity, :taxon, :gene].each do |term_type|
        term_ids = params[:facet_paths][term_type].present? ? params[:facet_paths][term_type].split(',') : []
        selected_term_id = term_ids.any? ? term_ids.last : nil
        @selected_term_ids[term_type] = selected_term_id
        
        #setup params[:filter] for phenotypes query based on params[:*_path] vars  
        if selected_term_id
          if [:entity, :quality, :related_entity].include?(term_type)
            params[:filter][:phenotypes]['0'][term_type] = selected_term_id
          else
            params[:filter][(term_type == :taxon ? :taxa : :genes)]['0'] = selected_term_id
          end
        end
      end
      [:phenotypes, :taxa, :genes].each{|type| params[:filter][type] = nil if params[:filter][type]['0'].blank? }
      unless params[:filter][:phenotypes].nil?
        params[:filter][:phenotypes]['0'][:including_parts] = (params[:facet_paths][:part_of].to_s == 'true')
      end
      
      [:entity, :quality, :related_entity, :taxon, :gene].each do |term_type|
        facet_options = {:path => params[:facet_paths][term_type]}
        facet_options[:part_of] = (params[:facet_paths][:part_of].to_s == 'true')
        [:entity, :quality, :related_entity, :taxon, :gene].each{|tt| facet_options[tt] = @selected_term_ids[tt] }
        results = Phenotype.facet_counts(term_type, facet_options)
        instance_variable_set("@#{term_type}_facets", results)
      end
      
      filter_term_names
    end
    
end
