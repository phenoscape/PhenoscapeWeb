# Dependencies: prototype (for enumerators, array methods, and others) and jQuery (for DOM access and manipulation)
$ = jQuery

class Tree
  constructor: (@container_id) ->
    $ => # DOM ready
      $("##{@container_id}").css('visibility', 'hidden') # Tree should not be visible at first

      term_info_div = $('#term_info')
      initial_page_load = true
      
      # This event gets called when anything is added to or removed from the Phenotype list
      term_info_div.change =>
        path = @current_state_path()

        # If we're redirecting to change the URL (when pushState is unsupported), don't bother loading anything, but show the loading screen
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
    
    @root_node ||= @options.tree_node_class.create_root @
    
    jit_default_options =
      injectInto: @container_id
      duration: 300
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
    $.extend jit_default_options, jit_options
    jit_options = jit_default_options
    
    # Override fitsInCanvas, so labels don't disappear when the top-left corner is not in the canvas
    $jit.ST.Label.HTML.prototype.fitsInCanvas = -> true
    
    # Create a new spacetree unless it already exists
    @spacetree ?= new $jit.ST jit_options
  
  destroy_spacetree: ->
    @root_node = null
    try
      @spacetree.removeSubtree(@spacetree.root, true, 'replot') if @spacetree?
    catch err
      console.log err if console?.log
  
  initialize_spacetree: ->
    # If the first level has only one child, replace the root with that child
    if @root_node.children.length == 1
      @root_node = @root_node.children[0]
      @root_node.data.is_root = true

    @spacetree.loadJSON @root_node
    @spacetree.compute()
    @spacetree.plot()
    unless @spacetree.graph.getNode(@spacetree.root).data.leaf_node
      @spacetree.onClick @spacetree.root
  
  load_selected_terms: ->
    @term_params = $("form#query_form}}").serialize()
  
  query: (taxon_id=null) ->
    @load_selected_terms()
    return unless @term_count > 0
    
    @show_loading()
    
    loading_root = !taxon_id?
    
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
  
  query_callback: (root_node, empty_resultset=false) ->
    @hide_loading()

    if root_node.data.is_root
      unless empty_resultset
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
    
    search_nodes = [@root_node]
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
      request: (nodeId, level, onComplete) =>
        @update_spacetree_callback = onComplete.onComplete
        @query nodeId
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
  
  update_spacetree: (node) ->
    throw "$jit failed to set update_spacetree_callback" unless @update_spacetree_callback
    @update_spacetree_callback node.id, node
  
  load_selected_terms: ->
    super()
    @term_count = $("#term_info .phenotype").length
  
  # Converts matches from the data source into TreeNodes and stores them in the tree
  query_callback: (matches, root_taxon_id) ->
    root_node = @find_node(root_taxon_id) || @root_node
    matches = matches.sortBy (m) -> m.name
    for match in matches
      node = root_node.find_or_create_child @, match.taxon_id, match.name, greatest_profile_match: match.greatest_profile_match
      if match.matches?
        match.matches = match.matches.sortBy (m) -> m.name
        for match_child in match.matches
          node.find_or_create_child @, match_child.taxon_id, match_child.name, greatest_profile_match: match_child.greatest_profile_match
    
    empty_resultset = (matches.length == 0)
    super root_node, empty_resultset
    
  current_state_path: ->
    @options.base_path + "?" + $('form[name=complex_query_form]').serialize()



class VariationTree extends Tree
  constructor: (@container_id) ->
    @options =
      tree_node_class:         VariationTreeNode
      base_path:               '/phenotypes/variation_tree'
      max_taxa_shown_in_group: 10
    
    @current_entity_id = window.location.pathname.sub(/.*\//, '') # essentially params[:id]

    super @container_id
    
    $ ->
      update_quality_name = ->
        $('.quality_name').html $('#quality_select option:selected').html()
      $('#quality_select').change ->
        update_quality_name()
        $('#term_info').change()
      update_quality_name()
      
      # Set up hover events for groups and phenotypes
      associated_targets = (hovered) ->
        targets = $(hovered) # Include the hovered element as a target
        associated = targets.data 'associated'
        if associated
          # Use getElementById since the ID has special characters in it that will throw off jQuery("#foo") selectors
          targets = targets.add($(document.getElementById(target))) for target in associated
        targets
      $(".node-group-with-phenotypes,#variation-table tbody tr:not(.empty)").live
        'mouseover': ->
          # Save the current classes
          associated_targets(@).each ->
            associated = $(@)
            associated.data 'classes', associated.attr('class')
            associated.addClass 'selected'
        'mouseout': ->
          # Restore the pre-mouseover clasess, if it was stored
          associated_targets(@).each ->
            associated = $(@)
            classes = associated.data 'classes'
            if classes
              associated.attr 'class', classes
        'click': ->
          a_t = associated_targets(@)
          a_t.each ->
            # Clear the restore data, making it permanent
            associated = $(@)
            associated.data 'classes', null
          
          # Unselect everything else
          others = $('.selected').not a_t
          others.removeClass 'selected'
          
      # Hovering nodes in the groups shouldn't trigger the hover event on the groups
      dont_propagate = (event) -> event.stopPropagation()
      $('.node-group-with-phenotypes .node-taxon').live
        'mouseover': dont_propagate
        'mouseout':  dont_propagate
        'click':     dont_propagate

  create_spacetree: ->
    super
      Edge:
        color: '#000'
        type: 'bezier'
        overridable: true
      Node:
        height: 1
        width: 130
        type: 'rectangle'
        overridable: true
        levelDistance: 500
      Label:
        type: 'HTML'
      Navigation:
        enable: true
        panning: 'avoid nodes'
      onCreateLabel: (label, node) => @create_label label, node
    
    @load_suggested_taxa()
    @check_top_level()
  
  destroy_spacetree: ->
    $('#variation-table').hide().find('tbody').empty()
    
    super
  
  load_selected_terms: ->
    super()
    @term_count = 1
  
  initialize_spacetree: ->
    for id, node of @spacetree.graph.nodes
      node.data.$height = $("##{id}").outerHeight()
      node.data.$width = $("##{id}").outerWidth()
    
    super()
  
  update_spacetree: (subtree) ->
    @spacetree.addSubtree subtree, 'replot'
    VariationTreeNode.click_node_when_ready @, subtree.id
  
  load_suggested_taxa: (attempt=0) ->
    if attempt > 1 # retry this many times
      return $('#suggested-taxa').html 'Failed to load suggested taxa'
      
    url = window.location.href.replace /\/variation_tree\//, '/variation_tree_suggested_taxa/'
    $.ajax
      url: url
      type: 'get'
      dataType: 'json'
      data:
        authenticitiy_token: AUTH_TOKEN
      error: => @load_suggested_taxa(attempt + 1)
      success: (data) ->
        suggested_taxa = $('#suggested-taxa')
        suggested_taxa.html ''
        for taxon in data.taxa
          link = $("<a href='#' class='suggested-taxon'>#{taxon.name}</a>")
          link.click (event) ->
            event.preventDefault()
            $('#term_id').val taxon.id
            $('#term_filter_form').submit()
          link.appendTo suggested_taxa
  
  # If we're at the top level of the tree, there's lots of uninteresting taxa to click through to get to anything real. Open the suggested taxa dialog.
  check_top_level: ->
    if !window.location.search
      $ -> $('#change-suggest-button').click()
  
  # Converts phenotype_sets from the data source into TreeNodes and stores them in the tree.
  # Also builds the phenotypes table.
  query_callback: (phenotype_sets, root_taxon_id, taxon_data) ->
    @change_taxon root_taxon_id, taxon_data[root_taxon_id].name
    root_node = @build_tree phenotype_sets, root_taxon_id, taxon_data
    @populate_phenotype_table phenotype_sets
    super root_node
  
  build_tree: (phenotype_sets, root_taxon_id, taxon_data) ->
    root_node = current_taxon_node = @find_node(root_taxon_id)
    root_node ||= @root_node
    current_taxon_node ||= root_node.find_or_create_child @, root_taxon_id, taxon_data[root_taxon_id].name,
      type: 'taxon'
      rank: taxon_data[root_taxon_id].rank?.name
      current: true
    current_taxon_node.estimateRenderHeight()
    # TODO: Sort phenotype set groups
    phenotype_sets.each (group) =>
      group_id = "group-#{hex_md5 JSON.encode group}" # There's no id or any unique identifier; encode the whole group and hash it
      group.group_id = group_id
      node = current_taxon_node.find_or_create_child @, group_id, group_id,
        type: 'group'
        phenotypes: group.phenotypes
        taxa: group.taxa.map (taxon_id) ->
          id: taxon_id
          name: taxon_data[taxon_id].name
          rank: taxon_data[taxon_id].rank?.name
      node.estimateRenderHeight()
    
    root_node
  
  populate_phenotype_table: (phenotype_sets) ->
    table = $('#variation-table')
    
    phenotypes = Phenotype.group_sets_by_phenotype(phenotype_sets)
    
    body = table.find 'tbody'
    body.html ''
    for identifier, phenotype of phenotypes
      row = $("<tr id='#{identifier}' class='phenotype-row'><td>#{phenotype.display_name}</td><td>#{phenotype.taxon_count}</td><td>#{phenotype.groups.length}</td></tr>")
      row.appendTo body
      row.data 'associated', phenotype.groups
    
    if body.html() == ''
      body.html '<tr class="empty"><td colspan="3">(none)</td></tr>'
    
    table.show()
  
  create_label: (label, node) ->
    label = $(label)
    label.attr 'id', node.id
    label.addClass 'node' # It already has this class, but I name it here to make it easier to find

    # Groups get treated differently; they have sub-divs for each taxon in the group
    # Style the nodes in an external stylesheet
    if node.data.type == 'group'
      label.addClass 'node-group'
      
      if node.data.taxa.length <= @options.max_taxa_shown_in_group
        node.data.taxa.each (taxon) =>
          grouped_taxon = $("<div class='node-taxon #{taxon.rank}' rel='#{taxon.id}'>#{taxon.name}</div>")
          grouped_taxon.appendTo label
          grouped_taxon.click (event) => VariationTreeNode.on_click(event, @, node, taxon)
      else
        taxon_select_container = $("<div class='node-taxon summary'></div>")
        taxon_selector = $("<select><option>#{node.data.taxa.length} taxa</option></select>")
        node.data.taxa.each (taxon) =>
          taxon_option = $("<option>#{taxon.name}</option>'")
          taxon_option.data 'taxon', taxon
          taxon_option.appendTo taxon_selector
        setTimeout =>
          taxon_selector.chosen().change (event) =>
            taxon = $(event.target).find('option:selected').data 'taxon'
            VariationTreeNode.on_click(event, @, node, taxon)
        , 0 # Queue this for after the taxon_selector has rendered in the DOM
        taxon_selector.appendTo taxon_select_container
        taxon_select_container.appendTo label
      
      if node.data.phenotypes.length == 0
        label.addClass 'node-group-without-phenotypes'
      else
        label.addClass 'node-group-with-phenotypes'
        label.data 'associated', (new Phenotype(phenotype).identifier() for phenotype in node.data.phenotypes)
    
    else
      label.addClass 'node-taxon'
      label.addClass node.data.rank
      label.html node.name
      label.click (event) => VariationTreeNode.on_click event, @, node,
        id: node.id
        name: node.name
        rank: node.data.rank
      
      if node.data.current       # Use the current class to keep track of the actual current node.
        label.addClass 'current' # node.data.current will stay true even after it's no longer current.
  
  current_state_path: ->
    base = @options.base_path
    taxon = "/" + @current_entity_id
    phenotype_filter = "?" + $('form[name=complex_query_form]').serialize()
    
    base + taxon + phenotype_filter
  
  change_taxon: (taxon_id, taxon_name) ->
    $('#current_taxon_id').val taxon_id
    $('#current_taxon_name').html taxon_name
  
  navigate_to_taxon: (taxon_id, taxon_name) ->
    @change_taxon taxon_id, taxon_name
    
    # TODO: test if the node is already present, and click on it instead of triggering a change()
    # Start over with a new query
    $('#term_info').change()
  
  navigate_to_entity: (entity_id, entity_name) ->
    @current_entity_id = entity_id
    $('#current_entity_id').val entity_id
    $('#current_entity_name').html entity_name
    @navigate_to_taxon()


class TreeNode
  constructor: (@tree, @id, @name, @data={}, @children=[]) ->
    @set_color() unless @data.$color
    @name = @id if !@name

  set_color: ->
    @data.$color = @color()

  # Find and return a decendent of this node that matches the given id.
  # If no descendent is found, create a the node using the given data and add it as a child of this node.
  find_or_create_child: (tree, id, name, data={}) ->
    child = @children.find (c) -> c.id == id
    return child if child?

    child = new @constructor tree, id, name, data
    @children.push child
    
    child
  
  @create_root: (tree) ->
    new @ tree, 'root', 'root', is_root: true


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
  color: -> 'transparent'
  
  estimateRenderHeight: ->
    effective_taxon_count = @data.taxa?.length
    effective_taxon_count = 1 if !effective_taxon_count
    summarize = effective_taxon_count > @tree.options.max_taxa_shown_in_group
    effective_taxon_count = 1 if summarize
    
    height = 30 * effective_taxon_count
    height += 10 if summarize
    height += 13 * 2 if @data.type == "group"
    
    @data.$height = height
  
  @on_click: (event, tree, node, taxon) ->
    event.preventDefault()
    target = $(event.target)
    
    # Don't do anything when the current node is clicked or the tree is busy.
    return if target.hasClass 'current' or tree.spacetree.busy
    
    # Update the form; query will use the form's values.
    tree.change_taxon taxon.id, taxon.name
    $('#clear-limit-tree-to').show()
    
    # Start the query to expand on the clicked taxon.
    tree.query taxon.id
    
    # The old current node is no longer current. Save its id though, so we can append to it.
    old_current_id = $('.node.current').removeClass('current').attr 'id'
    throw "No node is selected as current" unless old_current_id
    
    # If the clicked node is in a group, replace the current subtree with a new taxon node.
    if node.data.type == 'group'
      # Remove the subtree
      tree.spacetree.removeSubtree(old_current_id, false, 'replot')
      
      # Create a new node to replace the group
      subtree = tree.find_node old_current_id
      subtree.children = []
      child = subtree.find_or_create_child tree, taxon.id, taxon.name, rank: taxon.rank
      child.estimateRenderHeight()
      tree.spacetree.addSubtree(subtree, 'replot')
      
      # Set target to the newly created node
      target = $(document.getElementById(taxon.id))
    
    # Otherwise, it's a parent of the current node. Select it and remove its subtree
    else
      subtree_id = target.attr 'id'
      # Order matters here; removeSubtree triggers a refresh, which expects the last clickedNode to be in the graph
      tree.spacetree.clickedNode = tree.spacetree.graph.getNode(subtree_id)
      tree.spacetree.removeSubtree(subtree_id, false, 'replot')
      tree.find_node(subtree_id).children = []
    
    # Give the new/clicked node the current class.
    target.addClass 'current'
  
  @click_node_when_ready: (tree, id) ->
    unless tree.spacetree.busy
      tree.spacetree.onClick id
    else
      setTimeout ->
        VariationTreeNode.click_node_when_ready tree, id
      , 50



class StateTransition
  constructor: (@path) -> if @pushstate_supported then @push_state() else @redirect()
  pushstate_supported: !!history.pushState
  push_state: -> history.pushState {}, "", @path
  redirect: -> window.location = @path
  redirecting: !history.pushState



# TODO: Multi-entity phenotypes
class Phenotype
  constructor: (@phenotype) ->
  
  identifier: ->
    "e=#{@phenotype.entity.id};q=#{@phenotype.quality.id}"
  
  display_name: ->
    "#{@phenotype.entity.name} #{@phenotype.quality.name}"
  
  # Break phenotype_sets down into:
  #  {'phenotype_1_identifier': {phenotype: {...}, groups: ['group-1', 'group-2', ...]}, ...}
  @group_sets_by_phenotype: (phenotype_sets) ->
    phenotypes = {}
    for group in phenotype_sets
      for phenotype in group.phenotypes
        p = new Phenotype(phenotype)
        identifier = p.identifier()
        if phenotypes[identifier]
          phenotypes[identifier].groups.push group.group_id
          phenotypes[identifier].taxon_count += group.taxa.length
        else
          phenotypes[identifier] =
            phenotype: phenotype
            groups: [group.group_id]
            taxon_count: group.taxa.length
            display_name: p.display_name()
    
    phenotypes



$ ->
  window.profile_tree = new ProfileTree 'profile-tree' if $('#profile-tree').length > 0
  window.variation_tree = new VariationTree 'variation-tree' if $('#variation-tree').length > 0
