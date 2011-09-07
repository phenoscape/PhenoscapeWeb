$ = jQuery

class Tree
  constructor: (@container_id) ->
    $ => # DOM ready
      $("##{@container_id}").css('visibility', 'hidden') # Tree should not be visible at first

      # This event gets called when anything is added to or removed from the Phenotype list
      term_info_div = $('#term_info')
      initial_page_load = true
      term_info_div.change =>
        path = @options.base_path + "?" + $('form[name=complex_query_form]').serialize()

        # If we're redirecting to change the URL (pushState unsupported), don't bother loading anything, but show the loading screen
        if !initial_page_load && new StateTransition(path).redirecting
          @show_loading()
        else
          @destroy_spacetree()
          @create_spacetree()
          @query()
        
        @check_empty_state() # @query() must come before this call, because it calls @load_selected_terms(), which sets @term_count

      term_info_div.change() # fire on page load, in case phenotypes are there from the profile tree
      initial_page_load = false

  create_spacetree: (jit_options) ->
    $('#tree_empty_state').hide()
    
    @root_node ||= @options.tree_node_class.create_root this
    
    jit_default_options =
      injectInto: @container_id
      duration: 600
      transition: $jit.Trans.Quart.easeOut
      levelDistance: 100
      levelsToShow: 1
      Node:
        autoHeight: true
        autoWidth: true
        # height: 20
        # width: 60
        type: 'rectangle'
        overridable: true
      Edge:
        type: 'bezier'
        overridable: true
      ## This code had no effect and wasn't important anyway. Leaving the framework here, in case we want to distinguish selected nodes later.
      # onBeforePlotNode: (node) ->
      #   if node.selected
      #     node.data.$lineWidth = 1
      #   else
      #     node.data.$lineWidth = 0
      request: (nodeId, level, onComplete) =>
        @update_spacetree_callback = onComplete.onComplete
        @query nodeId
    $.extend jit_default_options, jit_options
    jit_options = jit_default_options
    
    @spacetree = st ?= new $jit.ST jit_options
  
  destroy_spacetree: ->
    @root_node = null
    try
      @spacetree.removeSubtree('root', true, 'animate') if @spacetree?
    catch err
  
  initialize_spacetree: ->
    @spacetree.loadJSON @root_node
    @spacetree.compute()
    @spacetree.plot()
    unless @spacetree.graph.getNode(@spacetree.root).data.leaf_node
      @spacetree.onClick @spacetree.root
  
  update_spacetree: (node) ->
    return console.log "$jit failed to set update_spacetree_callback" unless @update_spacetree_callback || !console
    @update_spacetree_callback node.id, node
  
  load_selected_terms: ->
    @term_params = $("#search_sidebar form").serialize()
    return
  
  query: (taxon_id=null) ->
    @load_selected_terms()
    return unless @term_count > 0
    
    @show_loading()
    
    loading_root = !taxon_id? || taxon_id == 'root'
    
    url = "#{@options.base_path}?#{decodeURIComponent(@term_params)}" # @term_params set in load_selected_terms
    url += "&taxon=#{taxon_id}" unless loading_root

    $.ajax
      url: url
      type: 'get'
      dataType: 'script'
      data:
        levels: if loading_root then 2 else 1
        authenticitiy_token: AUTH_TOKEN
      error: @ajax_error_handler

  # Converts matches from the data source into TreeNodes and stores them in the tree
  query_callback: (matches, root_taxon_id) ->
    root_node = @find_node(root_taxon_id) || @root_node
    matches = matches.sortBy (m) -> m.name
    for match in matches
      node = root_node.find_or_create_child(this, match.taxon_id, match.name, {greatest_profile_match: match.greatest_profile_match})
      if match.matches?
        match.matches = match.matches.sortBy (m) -> m.name
        for match_child in match.matches
          node.find_or_create_child(this, match_child.taxon_id, match_child.name, {greatest_profile_match: match_child.greatest_profile_match})
    
    @hide_loading()
    
    if root_node.id == 'root'
      if matches.any()
        root_node.name ||= 'Phenotype query'
        root_node.data.leaf_node = false
        root_node.set_color()
      else
        root_node.name = 'No results'
        root_node.data.leaf_node = true
        root_node.set_color()

      @initialize_spacetree()
    else
      @update_spacetree root_node
  
  show_loading: ->
    @loading = true
    
    $("##{@container_id}").animate {backgroundColor: '#BBE2D6'},
      duration: 'fast'
      queue: true
    
    $("##{@container_id}-loading").show()
  
  hide_loading: ->
    @loading = false
    
    $("##{@container_id}").animate {backgroundColor: '#FFFFFF'},
      duration: 'fast'
      queue: true
      complete: =>
        $("##{@container_id}-loading").hide() unless @loading # Check @loading because of potential race conditions - if started loading again while fading out
  
  ajax_error_handler: (jqXHR, textStatus, errorThrown) ->
    alert 'There was a problem requesting data. Check your internet connection or report this problem in feedback.'
    if console
      console.log "Error:"
      console.log jqXHR
      console.log textStatus
      console.log errorThrown
  
  find_node: (id) ->
    return null unless id? && id.length > 0
    
    search_nodes = @root_node.children
    while search_nodes.any()
      result_node = search_nodes.find (node) -> node.id == id
      return result_node if result_node?
      search_nodes = search_nodes.map (node) -> node.children
      search_nodes = search_nodes.flatten()
      
    return null
  
  check_empty_state: ->
    tree_div = $("##{@container_id}")
    empty_state_div = $("##{@container_id}-empty")
    if @term_count && @term_count > 0
      empty_state_div.hide()
      tree_div.css('visibility', 'visible')
    else
      tree_div.css('visibility', 'hidden')
      empty_state_div.show()


class ProfileTree extends Tree
  constructor: (@container_id) ->
    @options =
      tree_node_class:  ProfileTreeNode
      base_path:        '/phenotypes/profile_tree'

    super @container_id
  
  create_spacetree: ->
    super
      Navigation:
        enable: true
        panning: true
      onCreateLabel: (label, node) ->
        # Set label style
        label = $(label)
        label.attr 'id', node.id
        label.html node.name
        unless node.data.leaf_node
          label.click -> st.onClick node.id
        label.css
          cursor: 'pointer'
          color: '#333'
          fontSize: '0.8em'
          padding: '3px'
          'white-space': 'nowrap'
  
  load_selected_terms: ->
    @term_count = $("#term_info .phenotype").length
    super()
  
  initialize_spacetree: ->
    # If the first level has only one child, replace the root with that child
    if @root_node.children.length == 1
      @root_node = @root_node.children[0]
      @root_node.id = 'root'

    super()



class VariationTree extends Tree
  constructor: (@container_id) ->
    @options =
      tree_node_class:  VariationTreeNode
      base_path:        '/phenotypes/variation_tree'

    super @container_id

  create_spacetree: ->
    super
      onCreateLabel: (label, node) ->
        # Set label style
        label = $(label)
        label.attr 'id', node.id
        label.html node.name
        unless node.data.leaf_node
          label.click -> st.onClick node.id
        label.css
          cursor: 'pointer'
          color: '#333'
          fontSize: '0.8em'
          padding: '3px'
          'white-space': 'nowrap'
  
  load_selected_terms: ->
    @term_count = 1 # will this concept exist? query depends on it
    super()
  
  initialize_spacetree: ->
    super() # TODO



class TreeNode
  constructor: (@tree, @id, @name, @data={}, @children=[]) ->
    @set_color() unless @data.$color
    @name = @id if !@name? or @name.blank()

  set_color: ->
    @data.$color = @color()

  find_or_create_child: (tree, id, name, data={}) ->
    child = @children.find (c) -> c.id == id
    return child if child?

    child = new @constructor tree, id, name, data
    @children.push child
    child
  
  @create_root: (tree) ->
    new this tree, 'root'


class ProfileTreeNode extends TreeNode
  color: ->
    percentage = @data.greatest_profile_match / @tree.term_count
    if percentage < .50 or @data.leaf_node
      'lightgray'
    else if percentage  < .75
      'yellow'
    else if percentage  < 1
      'orange'
    else
      '#F44' # a lighter red


class VariationTreeNode extends TreeNode
  color: ->
    'white'



class StateTransition
  constructor: (@path) -> if @pushstate_supported then @push_state() else @redirect()
  pushstate_supported: !!history.pushState
  push_state: -> history.pushState {}, "", @path
  redirect: -> window.location = @path
  redirecting: !history.pushState



$ ->
  window.profile_tree = new ProfileTree 'profile-tree' if $('#profile-tree').length > 0
  window.variation_tree = new VariationTree 'variation-tree' if $('#variation-tree').length > 0
