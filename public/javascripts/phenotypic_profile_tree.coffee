$ = jQuery

class Tree
  constructor: (@container_id) ->
    @root_node = new TreeNode this, 'root'
    
    $ =>
      $("##{@container_id}").css('visibility', 'hidden') # Tree should not be visible at first

      # This event gets called when anything is added to or removed from the Phenotype list
      $('#term_info').change =>
        @destroy_spacetree()
        @create_spacetree()
        @query()
        @check_empty_state() # @query() must come before this call, because it calls @load_selected_phenotypes(), which sets @phenotype_count

  create_spacetree: () ->
    $('#tree_empty_state').hide()
    
    @spacetree = st ?= new $jit.ST
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
      ## This code had no effect and wasn't important anyway. Leaving the framework here, in case we want to distinguish selected nodes later.
      # onBeforePlotNode: (node) ->
      #   if node.selected
      #     node.data.$lineWidth = 1
      #   else
      #     node.data.$lineWidth = 0
      request: (nodeId, level, onComplete) =>
         @update_spacetree_callback = onComplete.onComplete
         @query(nodeId)
 
  destroy_spacetree: () ->
    @spacetree.removeSubtree('root', false, 'animate') if @spacetree?
  
  initialize_spacetree: () ->
    @spacetree.loadJSON @root_node
    @spacetree.compute()
    @spacetree.plot()
    unless @spacetree.graph.getNode(@spacetree.root).data.leaf_node
      @spacetree.onClick @spacetree.root
  
  update_spacetree: (node) ->
    return console.log "$jit failed to set update_spacetree_callback" unless @update_spacetree_callback
    @update_spacetree_callback node.id, node
  
  load_selected_phenotypes: () ->
    @phenotype_params = $("#search_sidebar form").serialize()
    @phenotype_count = $("#term_info .phenotype").length
    return
  
  query: (taxon_id=null) ->
    @load_selected_phenotypes()
    return unless @phenotype_count > 0
    
    @show_loading()
    
    url = '/phenotypes/profile_tree?' + decodeURIComponent(@phenotype_params)
    url += "&taxon=#{taxon_id}" if taxon_id? && taxon_id != 'root'

    $.ajax
      url: url
      type: 'get'
      dataType: 'script'
      data:
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
          node = node.find_or_create_child(this, match_child.taxon_id, match_child.name, {greatest_profile_match: match_child.greatest_profile_match})
    
    @hide_loading()
    
    if root_node.id == 'root'
      if matches.any()
        root_node.name = 'Phenotype query'
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
  
  ajax_error_handler: -> alert 'There was a problem requesting data. Check your internet connection or report this problem in feedback.'
  
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
    if @phenotype_count && @phenotype_count > 0
      empty_state_div.hide()
      tree_div.css('visibility', 'visible')
    else
      tree_div.css('visibility', 'hidden')
      empty_state_div.show()


class TreeNode
  constructor: (@tree, @id, @name, @data={}, @children=[]) ->
    @set_color() unless @data.$color
    @name = @id if !@name? or @name.blank()
  
  color: ->
    percentage = @data.greatest_profile_match / @tree.phenotype_count
    if percentage < .50 or @data.leaf_node
      'lightgray'
    else if percentage  < .75
      'yellow'
    else if percentage  < 1
      'orange'
    else
      'red'
  
  set_color: ->
    @data.$color = @color()
  
  find_or_create_child: (tree, id, name, data={}) ->
    child = @children.find (c) -> c.id == id
    return child if child?
    
    child = new TreeNode tree, id, name, data
    @children.push child
    child

window.profile_tree = new Tree 'tree'