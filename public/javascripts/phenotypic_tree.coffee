# Dependencies: prototype (for enumerators, array methods, and others) and jQuery (for DOM access and manipulation)
$ = jQuery

class Tree
  constructor: (@container_id) ->
    $ => # DOM ready
      container = $("##{@container_id}")
      container.css('visibility', 'hidden') # Tree should not be visible at first
      @options ||= {}
      @options.loading_background_color = "#DDE9EE"

      controller_div = $("##{@options.controller_id}")
      initial_page_load = true
      @initial_from_data = $("form##{@options.controller_form_id}").serialize()
      @initial_content = @get_current_state_content()
      
      # This event gets called when anything is added to or removed from the Phenotype list
      controller_div.change =>
        # Wait until the spacetree is done animating before we try to make it do anything
        if @spacetree?.busy
          return setTimeout =>
            controller_div.change()
          , 10

        # Save the sate, unless we got here by restoring the state
        new_state = false
        unless controller_div.data('restoring_state')
          path = @current_state_path()
          state =
            form_data: $("form##{@options.controller_form_id}").serialize()
            content: @get_current_state_content()
          popstate_callback = (event) =>
            controller_div.data 'restoring_state', true
            state = event.originalEvent?.state || {}
            content = state.content || @initial_content
            form_data = state.form_data || @initial_from_data
            for selector, html of content
              $("##{selector},.#{selector}").html(html)
            $("form##{@options.controller_form_id}").unserializeForm(form_data)
            controller_div.change()
          
          unless initial_page_load
            new_state = new StateTransition(path, state, popstate_callback)
        else
          controller_div.data 'restoring_state', false
        
        # If we're redirecting to change the URL (when pushState is unsupported), don't bother loading anything, but show the loading screen
        if new_state.redirecting
          @show_loading()
        else
          @destroy_spacetree()
          @create_spacetree()
          @query()
          @check_empty_state() # @query() must come before this call, because it calls @load_selected_terms(), which sets @term_count

      controller_div.change() # fire on page load, in case phenotypes are there from the profile tree
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
        type: 'rectangle'
        overridable: true
      Edge:
        type: 'bezier'
        overridable: true
      Navigation:
        enable: true
        panning: 'avoid nodes'
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
    catch err # we expect this to sometimes throw an exception, depending on the state. It doesn't matter though.
  
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
  
  center_canvas: (options) ->
    @spacetree.canvas.translate(-@spacetree.canvas.translateOffsetX, -@spacetree.canvas.translateOffsetY)
  
  load_selected_terms: ->
    @term_params = $("form##{@options.controller_form_id}").serialize()
  
  query: (taxon_id=null) ->
    @load_selected_terms()
    return unless @term_count > 0
    
    @show_loading()
    
    loading_root = !taxon_id?
    
    url = "#{@options.base_path}?#{decodeURIComponent(@term_params)}" # @term_params set in load_selected_terms
    url += "&taxon=#{taxon_id}" unless loading_root

    @sequence = (@sequence || 0) + 1
    $.ajax
      url: url
      type: 'get'
      dataType: 'script'
      data:
        sequence: @sequence
        levels: if loading_root then 2 else 1
        authenticitiy_token: AUTH_TOKEN
      success: => @hide_error()
      error: => @ajax_error_handler()
  
  query_callback: (sequence, root_node, empty_resultset=false) ->
    # A user can change options rapidly, and each change sends a new query. Only the most recent results matter.
    # Discard any responses that are not in response to the most recent query.
    return unless sequence is @sequence

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
    
    opts = 
      lines: 12
      length: 30
      width: 11
      radius: 30
      color: "#FFF"
      speed: 1
      trail: 60
      shadow: false
    @loading_spinner ?= new Spinner(opts).spin(document.getElementById("#{@container_id}-loading");)
    
    
    self = @
    $("##{@container_id}").animate {backgroundColor: self.options.loading_background_color},
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
    $("##{@container_id}").prepend $('<div class="error rounded-small visualize-area">An error occurred. You might reload the page and try again.</div>')
  
  hide_error: ->
    $("##{@container_id} .error").remove()
  
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
      tree_node_class:    ProfileTreeNode
      base_path:          '/phenotypes/profile_tree'
      controller_id:      'term_info'
      controller_form_id: 'query_form'

    super @container_id
  
  get_current_state_content: ->
    content = {}
    content[@options.controller_id] = $("##{@options.controller_id}").html()

  create_spacetree: ->
    super
      Node:
        height: 30
        width: 160
        type: 'rectangle'
        overridable: true
        levelDistance: 500
      request: (nodeId, level, onComplete) =>
        # Bugfix: For some reason, spacetree tries to fetch grandchildren (with n ajax queries)
        # when clicking a node whose children are already loaded. When this happens, level is 0.
        # These ajax queries will be dropped, since we we use @sequence now to ignore all but the latest.
        # This caused the spacetree to sit waiting in busy mode for them forever, freezing up the tree.
        return @spacetree.busy = false if level is 0
        
        @update_spacetree_callback = onComplete.onComplete
        @query nodeId
      onCreateLabel: (label, node) =>
        # Set label style
        label = $(label)
        label.attr 'id', node.id
        formatted_percent_match = "#{Math.round(node.data.percent_match * 100)}% match" if node.data.percent_match
        label.attr 'title', formatted_percent_match if formatted_percent_match
        label.html node.name
        label.css backgroundColor: node.data.color
        unless node.data.leaf_node
          label.click =>
            # Ignore requests to click the currently selected node
            return if @spacetree.graph.nodes[node.id] == @spacetree.clickedNode
            
            @center_canvas()
            window.profile_tree.spacetree.onClick node.id
  
  update_spacetree: (node) ->
    throw "$jit failed to set update_spacetree_callback" unless @update_spacetree_callback
    @update_spacetree_callback node.id, node
  
  load_selected_terms: ->
    super()
    @term_count = $("##{@options.controller_id}").find(".phenotype").length
  
  # Converts matches from the data source into TreeNodes and stores them in the tree
  query_callback: (sequence, matches, root_taxon_id) ->
    # A user can change options rapidly, and each change sends a new query. Only the most recent results matter.
    # Discard any responses that are not in response to the most recent query.
    return unless sequence is @sequence

    root_node = @find_node(root_taxon_id) || @root_node
    matches = matches.sortBy (m) -> m.name
    for match in matches
      node = root_node.find_or_create_child @, match.taxon_id, match.name, greatest_profile_match: match.greatest_profile_match
      if match.matches?
        match.matches = match.matches.sortBy (m) -> m.name
        for match_child in match.matches
          node.find_or_create_child @, match_child.taxon_id, match_child.name, greatest_profile_match: match_child.greatest_profile_match
    
    empty_resultset = (matches.length == 0)
    super sequence, root_node, empty_resultset
    
  current_state_path: ->
    @options.base_path + "?" + $("form##{@options.controller_form_id}").serialize()



class VariationTree extends Tree
  constructor: (@container_id) ->
    @options =
      tree_node_class:         VariationTreeNode
      base_path:               '/phenotypes/variation_tree'
      controller_id:           'term_info'
      controller_form_id:      'query_form'
      max_taxa_shown_in_group: 20
    
    @current_entity_id = window.location.pathname.sub(/.*\//, '') # essentially params[:id]
    
    # Set the quality name before super() saves the initial state
    $ =>
      update_quality_name = ->
        $('.quality_name').html $('#quality_select option:selected').html()
      $('#quality_select').change =>
        update_quality_name()
        $("##{@options.controller_id}").change()
      update_quality_name()
    
    super @container_id
    
    $ ->
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
          if $(@).data('sticky')
            a_t.data 'sticky', null
            $('.selected').removeClass 'selected'
          else
            a_t.addClass 'selected'
            a_t.data 'sticky', true
          
          a_t.each ->
            # Clear the restore data, making it permanent
            associated = $(@)
            associated.data 'classes', null
          
          # Unselect everything else
          others = $('.selected').not a_t
          others.removeClass 'selected'
          others.data 'sticky', null
      
      # Hovering nodes in the groups shouldn't trigger the hover event on the groups
      dont_propagate = (event) -> event.stopPropagation()
      $('.node-group-with-phenotypes .node-taxon').live
        'mouseover': dont_propagate
        'mouseout':  dont_propagate
        'click':     dont_propagate

  get_current_state_content: ->
    'current_entity_name': $("#current_entity_name").html()
    'quality_name': $(".quality_name").html()

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
      onCreateLabel: (label, node) => @create_label label, node
    
    @load_suggested_taxa()
  
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
    
    # Loading spinner
    if attempt == 0
      opts = 
        lines: 10
        length: 4
        width: 3
        radius: 5
        color: "#000"
        speed: 2
        trail: 60
        shadow: false
      new Spinner(opts).spin(document.getElementById('suggested-taxa');)
    
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
        data.taxa.sortBy((taxon) -> taxon.name).each (taxon) ->
          link = $("<a href='#' class='suggested-taxon'>#{taxon.name}</a>")
          link.click (event) ->
            event.preventDefault()
            $('#term_id').val taxon.id
            $('#term_filter_form').submit()
          link.appendTo suggested_taxa
  
  # Converts phenotype_sets from the data source into TreeNodes and stores them in the tree.
  # Also builds the phenotypes table.
  query_callback: (sequence, phenotype_sets, root_taxon_id, taxon_data) ->
    # A user can change options rapidly, and each change sends a new query. Only the most recent results matter.
    # Discard any responses that are not in response to the most recent query.
    return unless sequence is @sequence

    # Wait until the spacetree is done animating before we try to make it do anything
    if @spacetree.busy
      return setTimeout =>
        self.query_callback.call this, sequence, phenotype_sets, root_taxon_id, taxon_data
      , 10
    
    @change_taxon root_taxon_id, taxon_data[root_taxon_id].name
    root_node = @build_tree phenotype_sets, root_taxon_id, taxon_data
    @populate_phenotype_table phenotype_sets

    super sequence, root_node
  
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
      
      # Sort the taxa in a group alphabetically
      node.data.taxa = node.data.taxa.sortBy (taxon) -> taxon.name
      
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
    phenotype_filter = "?" + $("form##{@options.controller_form_id}").serialize()
    
    base + taxon + phenotype_filter
  
  change_taxon: (taxon_id, taxon_name) ->
    $('#current_taxon_id').val taxon_id
    $('#current_taxon_name').html taxon_name
  
  navigate_to_taxon: (taxon_id, taxon_name) ->
    @change_taxon taxon_id, taxon_name
    
    # TODO: test if the node is already present, and click on it instead of triggering a change()
    # Start over with a new query
    $("##{@options.controller_id}").change()
  
  navigate_to_entity: (entity_id, entity_name) ->
    @current_entity_id = entity_id
    $('#current_entity_id').val entity_id
    $('#current_entity_name').html entity_name
    @navigate_to_taxon()


class TreeNode
  constructor: (@tree, @id, @name, @data={}, @children=[]) ->
    @set_color() unless @data.color
    @data.$color = 'transparent'
    @name = @id if !@name

  set_color: ->
    @data.color = @color()

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
  constructor: (@tree, @id, @name, @data={}, @children=[]) ->
    @data.percent_match = @percent_match()
    
    super

  color: ->
    # Calculate a color on a gradient at a percentage along the gradient.
    # Colors should be arrays with three rgb integer values (out of 255), eg: start_color: [0, 127, 255]
    # Percentage should be a number between 0 and 1, representing 0-100% along the gradient between start_color and end_color.
    # Returns a CSS rgb() string, ie: "rgb(0,127,255)"
    color_on_gradient = (start_color, end_color, percentage) ->
      diff = [end_color[0] - start_color[0], end_color[1] - start_color[1], end_color[2] - start_color[2]]
      "rgb(#{Math.round(start_color[0] + diff[0] * percentage)},#{Math.round(start_color[1] + diff[1] * percentage)},#{Math.round(start_color[2] + diff[2] * percentage)})"
    
    percentage = @percent_match()
    if !percentage or percentage < .33
      'rgb(212,212,212)'
    else if percentage < .5
      color_on_gradient([212, 212, 212], [255, 255, 0], (percentage - .33) / (.5 - .33))
    else
      color_on_gradient([255, 255, 0], [255, 68, 68], (percentage - .5) / (1 - .5))
  
  percent_match: ->
    @data.greatest_profile_match / @tree.term_count


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
    
    # Center the canvas if we've panned a far way off
    tree.center_canvas()
    
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
  constructor: (@path, @state, @popstate_callback) ->
    if @pushstate_supported
      @push_state()
      @set_popstate()
    else
      @redirect()
  pushstate_supported: !!history.pushState
  push_state: -> history.pushState @state, '', @path
  redirect: -> window.location = @path
  redirecting: !history.pushState
  set_popstate: ->
    w = $(window)
    w.unbind 'popstate'
    w.bind 'popstate', @popstate_callback



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
