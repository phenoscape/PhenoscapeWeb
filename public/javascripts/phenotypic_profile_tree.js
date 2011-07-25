/* This script was compiled from CoffeeScript. Do not edit this file directly, or the changes will be overwritten next time the coffee script is compiled. */
(function() {
  var $, Tree, TreeNode;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = jQuery;
  Tree = (function() {
    function Tree(container_id) {
      this.container_id = container_id;
      this.root_node = new TreeNode(this, 'root');
      $(__bind(function() {
        return $('#term_info').change(__bind(function() {
          this.destroy_spacetree();
          this.create_spacetree();
          this.query();
          return this.check_empty_state();
        }, this));
      }, this));
    }
    Tree.prototype.create_spacetree = function() {
      $('#tree_empty_state').hide();
      return this.spacetree = typeof st !== "undefined" && st !== null ? st : st = new $jit.ST({
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
        },
        request: __bind(function(nodeId, level, onComplete) {
          this.update_spacetree_callback = onComplete.onComplete;
          return this.query(nodeId);
        }, this)
      });
    };
    Tree.prototype.destroy_spacetree = function() {
      if (this.spacetree != null) {
        return this.spacetree.removeSubtree('root', false, 'animate');
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
      if (!this.update_spacetree_callback) {
        return console.log("$jit failed to set update_spacetree_callback");
      }
      return this.update_spacetree_callback(node.id, node);
    };
    Tree.prototype.load_selected_phenotypes = function() {
      this.phenotype_params = $("#search_sidebar form").serialize();
      this.phenotype_count = $("#term_info .phenotype").length;
    };
    Tree.prototype.query = function(taxon_id) {
      var url;
      if (taxon_id == null) {
        taxon_id = null;
      }
      this.load_selected_phenotypes();
      if (!(this.phenotype_count > 0)) {
        return;
      }
      this.show_loading();
      url = '/phenotypes/profile_tree?' + decodeURIComponent(this.phenotype_params);
      if ((taxon_id != null) && taxon_id !== 'root') {
        url += "&taxon=" + taxon_id;
      }
      return $.ajax({
        url: url,
        type: 'get',
        dataType: 'script',
        data: {
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
            node = node.find_or_create_child(this, match_child.taxon_id, match_child.name, {
              greatest_profile_match: match_child.greatest_profile_match
            });
          }
        }
      }
      this.hide_loading();
      if (root_node.id === 'root') {
        if (matches.any()) {
          root_node.name = 'Phenotype query';
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
    Tree.prototype.ajax_error_handler = function() {
      return alert('There was a problem requesting data. Check your internet connection or report this problem in feedback.');
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
      var empty_state_div;
      empty_state_div = $("#" + this.container_id + "-empty");
      if (this.phenotype_count && this.phenotype_count > 0) {
        return empty_state_div.hide();
      } else {
        return empty_state_div.show();
      }
    };
    return Tree;
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
    TreeNode.prototype.color = function() {
      var percentage;
      percentage = this.data.greatest_profile_match / this.tree.phenotype_count;
      if (percentage < .50 || this.data.leaf_node) {
        return 'lightgray';
      } else if (percentage < .75) {
        return 'yellow';
      } else if (percentage < 1) {
        return 'orange';
      } else {
        return 'red';
      }
    };
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
      child = new TreeNode(tree, id, name, data);
      this.children.push(child);
      return child;
    };
    return TreeNode;
  })();
  window.profile_tree = new Tree('tree');
}).call(this);
