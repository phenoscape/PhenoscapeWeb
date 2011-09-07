(function() {
  var $, ProfileTree, ProfileTreeNode, StateTransition, Tree, TreeNode, VariationTree, VariationTreeNode;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  $ = jQuery;
  Tree = (function() {
    function Tree(container_id) {
      this.container_id = container_id;
      $(__bind(function() {
        var initial_page_load, term_info_div;
        $("#" + this.container_id).css('visibility', 'hidden');
        term_info_div = $('#term_info');
        initial_page_load = true;
        term_info_div.change(__bind(function() {
          var path;
          path = this.options.base_path + "?" + $('form[name=complex_query_form]').serialize();
          if (!initial_page_load && new StateTransition(path).redirecting) {
            this.show_loading();
          } else {
            this.destroy_spacetree();
            this.create_spacetree();
            this.query();
          }
          return this.check_empty_state();
        }, this));
        term_info_div.change();
        return initial_page_load = false;
      }, this));
    }
    Tree.prototype.create_spacetree = function(jit_options) {
      var jit_default_options;
      $('#tree_empty_state').hide();
      this.root_node || (this.root_node = this.options.tree_node_class.create_root(this));
      jit_default_options = {
        injectInto: this.container_id,
        duration: 600,
        transition: $jit.Trans.Quart.easeOut,
        levelDistance: 100,
        levelsToShow: 1,
        Node: {
          autoHeight: true,
          autoWidth: true,
          type: 'rectangle',
          overridable: true
        },
        Edge: {
          type: 'bezier',
          overridable: true
        },
        request: __bind(function(nodeId, level, onComplete) {
          this.update_spacetree_callback = onComplete.onComplete;
          return this.query(nodeId);
        }, this)
      };
      $.extend(jit_default_options, jit_options);
      jit_options = jit_default_options;
      return this.spacetree = typeof st !== "undefined" && st !== null ? st : st = new $jit.ST(jit_options);
    };
    Tree.prototype.destroy_spacetree = function() {
      this.root_node = null;
      try {
        if (this.spacetree != null) {
          return this.spacetree.removeSubtree('root', true, 'animate');
        }
      } catch (err) {

      }
    };
    Tree.prototype.initialize_spacetree = function() {
      this.spacetree.loadJSON(this.root_node);
      this.spacetree.compute();
      this.spacetree.plot();
      if (!this.spacetree.graph.getNode(this.spacetree.root).data.leaf_node) {
        return this.spacetree.onClick(this.spacetree.root);
      }
    };
    Tree.prototype.update_spacetree = function(node) {
      if (!(this.update_spacetree_callback || !console)) {
        return console.log("$jit failed to set update_spacetree_callback");
      }
      return this.update_spacetree_callback(node.id, node);
    };
    Tree.prototype.load_selected_terms = function() {
      this.term_params = $("#search_sidebar form").serialize();
    };
    Tree.prototype.query = function(taxon_id) {
      var loading_root, url;
      if (taxon_id == null) {
        taxon_id = null;
      }
      this.load_selected_terms();
      if (!(this.term_count > 0)) {
        return;
      }
      this.show_loading();
      loading_root = !(taxon_id != null) || taxon_id === 'root';
      url = "" + this.options.base_path + "?" + (decodeURIComponent(this.term_params));
      if (!loading_root) {
        url += "&taxon=" + taxon_id;
      }
      return $.ajax({
        url: url,
        type: 'get',
        dataType: 'script',
        data: {
          levels: loading_root ? 2 : 1,
          authenticitiy_token: AUTH_TOKEN
        },
        error: this.ajax_error_handler
      });
    };
    Tree.prototype.query_callback = function(matches, root_taxon_id) {
      var match, match_child, node, root_node, _i, _j, _len, _len2, _ref;
      root_node = this.find_node(root_taxon_id) || this.root_node;
      matches = matches.sortBy(function(m) {
        return m.name;
      });
      for (_i = 0, _len = matches.length; _i < _len; _i++) {
        match = matches[_i];
        node = root_node.find_or_create_child(this, match.taxon_id, match.name, {
          greatest_profile_match: match.greatest_profile_match
        });
        if (match.matches != null) {
          match.matches = match.matches.sortBy(function(m) {
            return m.name;
          });
          _ref = match.matches;
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            match_child = _ref[_j];
            node.find_or_create_child(this, match_child.taxon_id, match_child.name, {
              greatest_profile_match: match_child.greatest_profile_match
            });
          }
        }
      }
      this.hide_loading();
      if (root_node.id === 'root') {
        if (matches.any()) {
          root_node.name || (root_node.name = 'Phenotype query');
          root_node.data.leaf_node = false;
          root_node.set_color();
        } else {
          root_node.name = 'No results';
          root_node.data.leaf_node = true;
          root_node.set_color();
        }
        return this.initialize_spacetree();
      } else {
        return this.update_spacetree(root_node);
      }
    };
    Tree.prototype.show_loading = function() {
      this.loading = true;
      $("#" + this.container_id).animate({
        backgroundColor: '#BBE2D6'
      }, {
        duration: 'fast',
        queue: true
      });
      return $("#" + this.container_id + "-loading").show();
    };
    Tree.prototype.hide_loading = function() {
      this.loading = false;
      return $("#" + this.container_id).animate({
        backgroundColor: '#FFFFFF'
      }, {
        duration: 'fast',
        queue: true,
        complete: __bind(function() {
          if (!this.loading) {
            return $("#" + this.container_id + "-loading").hide();
          }
        }, this)
      });
    };
    Tree.prototype.ajax_error_handler = function(jqXHR, textStatus, errorThrown) {
      alert('There was a problem requesting data. Check your internet connection or report this problem in feedback.');
      if (console) {
        console.log("Error:");
        console.log(jqXHR);
        console.log(textStatus);
        return console.log(errorThrown);
      }
    };
    Tree.prototype.find_node = function(id) {
      var result_node, search_nodes;
      if (!((id != null) && id.length > 0)) {
        return null;
      }
      search_nodes = this.root_node.children;
      while (search_nodes.any()) {
        result_node = search_nodes.find(function(node) {
          return node.id === id;
        });
        if (result_node != null) {
          return result_node;
        }
        search_nodes = search_nodes.map(function(node) {
          return node.children;
        });
        search_nodes = search_nodes.flatten();
      }
      return null;
    };
    Tree.prototype.check_empty_state = function() {
      var empty_state_div, tree_div;
      tree_div = $("#" + this.container_id);
      empty_state_div = $("#" + this.container_id + "-empty");
      if (this.term_count && this.term_count > 0) {
        empty_state_div.hide();
        return tree_div.css('visibility', 'visible');
      } else {
        tree_div.css('visibility', 'hidden');
        return empty_state_div.show();
      }
    };
    return Tree;
  })();
  ProfileTree = (function() {
    __extends(ProfileTree, Tree);
    function ProfileTree(container_id) {
      this.container_id = container_id;
      this.options = {
        tree_node_class: ProfileTreeNode,
        base_path: '/phenotypes/profile_tree'
      };
      ProfileTree.__super__.constructor.call(this, this.container_id);
    }
    ProfileTree.prototype.create_spacetree = function() {
      return ProfileTree.__super__.create_spacetree.call(this, {
        Navigation: {
          enable: true,
          panning: true
        },
        onCreateLabel: function(label, node) {
          label = $(label);
          label.attr('id', node.id);
          label.html(node.name);
          if (!node.data.leaf_node) {
            label.click(function() {
              return st.onClick(node.id);
            });
          }
          return label.css({
            cursor: 'pointer',
            color: '#333',
            fontSize: '0.8em',
            padding: '3px',
            'white-space': 'nowrap'
          });
        }
      });
    };
    ProfileTree.prototype.load_selected_terms = function() {
      this.term_count = $("#term_info .phenotype").length;
      return ProfileTree.__super__.load_selected_terms.call(this);
    };
    ProfileTree.prototype.initialize_spacetree = function() {
      if (this.root_node.children.length === 1) {
        this.root_node = this.root_node.children[0];
        this.root_node.id = 'root';
      }
      return ProfileTree.__super__.initialize_spacetree.call(this);
    };
    return ProfileTree;
  })();
  VariationTree = (function() {
    __extends(VariationTree, Tree);
    function VariationTree(container_id) {
      this.container_id = container_id;
      this.options = {
        tree_node_class: VariationTreeNode,
        base_path: '/phenotypes/variation_tree'
      };
      VariationTree.__super__.constructor.call(this, this.container_id);
    }
    VariationTree.prototype.create_spacetree = function() {
      return VariationTree.__super__.create_spacetree.call(this, {
        onCreateLabel: function(label, node) {
          label = $(label);
          label.attr('id', node.id);
          label.html(node.name);
          if (!node.data.leaf_node) {
            label.click(function() {
              return st.onClick(node.id);
            });
          }
          return label.css({
            cursor: 'pointer',
            color: '#333',
            fontSize: '0.8em',
            padding: '3px',
            'white-space': 'nowrap'
          });
        }
      });
    };
    VariationTree.prototype.load_selected_terms = function() {
      this.term_count = 1;
      return VariationTree.__super__.load_selected_terms.call(this);
    };
    VariationTree.prototype.initialize_spacetree = function() {
      return VariationTree.__super__.initialize_spacetree.call(this);
    };
    return VariationTree;
  })();
  TreeNode = (function() {
    function TreeNode(tree, id, name, data, children) {
      this.tree = tree;
      this.id = id;
      this.name = name;
      this.data = data != null ? data : {};
      this.children = children != null ? children : [];
      if (!this.data.$color) {
        this.set_color();
      }
      if (!(this.name != null) || this.name.blank()) {
        this.name = this.id;
      }
    }
    TreeNode.prototype.set_color = function() {
      return this.data.$color = this.color();
    };
    TreeNode.prototype.find_or_create_child = function(tree, id, name, data) {
      var child;
      if (data == null) {
        data = {};
      }
      child = this.children.find(function(c) {
        return c.id === id;
      });
      if (child != null) {
        return child;
      }
      child = new this.constructor(tree, id, name, data);
      this.children.push(child);
      return child;
    };
    TreeNode.create_root = function(tree) {
      return new this(tree, 'root');
    };
    return TreeNode;
  })();
  ProfileTreeNode = (function() {
    __extends(ProfileTreeNode, TreeNode);
    function ProfileTreeNode() {
      ProfileTreeNode.__super__.constructor.apply(this, arguments);
    }
    ProfileTreeNode.prototype.color = function() {
      var percentage;
      percentage = this.data.greatest_profile_match / this.tree.term_count;
      if (percentage < .50 || this.data.leaf_node) {
        return 'lightgray';
      } else if (percentage < .75) {
        return 'yellow';
      } else if (percentage < 1) {
        return 'orange';
      } else {
        return '#F44';
      }
    };
    return ProfileTreeNode;
  })();
  VariationTreeNode = (function() {
    __extends(VariationTreeNode, TreeNode);
    function VariationTreeNode() {
      VariationTreeNode.__super__.constructor.apply(this, arguments);
    }
    VariationTreeNode.prototype.color = function() {
      return 'white';
    };
    return VariationTreeNode;
  })();
  StateTransition = (function() {
    function StateTransition(path) {
      this.path = path;
      if (this.pushstate_supported) {
        this.push_state();
      } else {
        this.redirect();
      }
    }
    StateTransition.prototype.pushstate_supported = !!history.pushState;
    StateTransition.prototype.push_state = function() {
      return history.pushState({}, "", this.path);
    };
    StateTransition.prototype.redirect = function() {
      return window.location = this.path;
    };
    StateTransition.prototype.redirecting = !history.pushState;
    return StateTransition;
  })();
  $(function() {
    if ($('#profile-tree').length > 0) {
      window.profile_tree = new ProfileTree('profile-tree');
    }
    if ($('#variation-tree').length > 0) {
      return window.variation_tree = new VariationTree('variation-tree');
    }
  });
}).call(this);
