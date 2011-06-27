/* Save to Workspace scripts */
(function($){
  $(document).ready(function() {
    setup_extensions();
    
    if ($('#save-all').length > 0)
      setup_save_to_workspace_on_queries();
      
    if ($('#workspace').length > 0)
      setup_workspace();
  });
  

  function setup_save_to_workspace_on_queries() {
    var save_boxes = $('.save');
    var save_all = $('#save-all');
    
    // Initialize checkboxes that were previously checked by the user
    save_boxes.each(function(i, element) {
      element = $(element);
      var category = element.attr('category');
      var data = JSON.decode(element.attr('rel'))[category][0];
      var was_checked = (SESSION_WORKSPACE_ITEMS[category] || []).has(data);
      element.attr('checked', was_checked);
    });
    
    function check_save_all_status() {
      save_all.attr('checked', save_boxes.are(':checked'));
    };
    check_save_all_status(); // on page load
    
    // Save checkbox click event
    save_boxes.click(function(event) {
      // Save the row to the session via AJAX
      var checkbox = $(event.target);
      var checked = checkbox.attr('checked'); // boolean
      var data = checkbox.attr('rel');
      $.ajax({
        url: '/workspace',
        type: 'post',
        data: {
          _method: checked ? 'put' : 'delete',
          data: data,
          authenticitiy_token: AUTH_TOKEN
        },
        success: undefined,
      });
      
      // Update the save-all checkbox if all other boxes are/were checked
      check_save_all_status();
    });
    
    // Save-all checkbox click event
    save_all.click(function(event) {
      var checked = $(event.target).attr('checked');
      var boxes = $('.save');

      // Collect data from all checkboxes
      var page_type;
      var items = boxes.map(function(i, element) {
        var hash = JSON.decode($(element).attr('rel'));

        // hash is of the form: {"type": [{...}]}; the hash value array only contains one element.
        for (type in hash) { // Iterate over the one type, because this is the only way I know to pull it out without knowing its name
          page_type = type;
          return hash[type][0];
        }
      }).get();
      var data = {};
      data[page_type] = items;
      data = JSON.encode(data);
      
      // Send it in one request
      $.ajax({
        url: '/workspace',
        type: 'post',
        data: {
          _method: checked ? 'put' : 'delete',
          data: data,
          authenticitiy_token: AUTH_TOKEN
        },
        success: undefined,
      });
      
      // Visibally check/uncheck all boxes
      boxes.attr('checked', checked);
    });
  };
  
  
  function setup_workspace() {
    var categories = ['taxa', 'genes', 'entities', 'qualities', 'publications', 'phenotypes'];
    var items = SESSION_WORKSPACE_ITEMS;
    var parent_categories = ['phenotypes', 'annotations'];
    var component_map = {
      'entity': 'entities',
      'related_entity': 'entities',
      'quality': 'qualities',
      'gene': 'genes',
      'taxon': 'taxa',
    };
    
    /* ensure each category is defined in items */
    function ensure_items_defines(category) {
      if (!items[category])
        items[category] = [];
    }
    categories.each(ensure_items_defines);
    parent_categories.each(ensure_items_defines);
    
    /* Copy phenotype and annotation (parent category) components to their respective catetgories */
    parent_categories.each(function(parent) {
      Object.keys(component_map).each(function(component) {
        var component_items_in_parent = items[parent].map(function(parent) {return parent[component]}).compact();
        items[component_map[component]] = items[component_map[component]].concat(component_items_in_parent);
      });
    });
    
    /* Define callbacks for items */
    function delete_item() {
      var delete_button = $(this);
      var item_container = delete_button.closest('.term');
      
      /* Remove the item from the workspace */
      var full_item_json = delete_button.attr('rel');
      $.ajax({
        url: '/workspace',
        type: 'post',
        data: {
          _method: 'delete',
          data: full_item_json,
          authenticitiy_token: AUTH_TOKEN
        },
        success: undefined,
      });
      
      /* Remove item visibly from the page */
      item_container.remove();
      
      return false; // Don't jump to top of page
    }
    
    /* Insert items from each category into the DOM */
    categories.each(function(category) {
      var container = $('#' + category + " .filter");
      if (items[category]) {
        // Uniq the JSON, because uniq removes duplicate objects or strings, not objects with duplicate contents
        var unique_json_array = items[category].map(function(item) {return JSON.encode(item)}).uniq();
        unique_json_array.each(function(item_json) {
          var item = JSON.decode(item_json);
          function filter_name() {
            
          }
          function set_up_checkbox(checkbox) {
            /* Keep a counter to make unique params */
            if (!this.counter)
              this.counter = 0
            this.counter++;
            
            if (category == 'phenotypes') {
              /* For phenotypes, we need to send params for each phenotype component */

              /* Create and insert hidden fields into the DOM */
              var hidden_fields = ['entity', 'quality', 'related_entity'].map(function(component) {
                if (item[component]) {
                  var name = 'filter[phenotypes][' + counter + '][' + component + ']';
                  return $('<input type="hidden" name="' + name + '" value="' + item[component]['id'] + '" />').insertAfter(checkbox);
                } else {
                  return null;
                }
              }).compact();
              
              /* Enable and disable them when the box is checked */
              function enable_if_checked(checkbox, targets) {
                targets.each(function(target) {
                  $(target).attr('disabled', !$(checkbox).data('checked'));
                });
              };
              checkbox.click(function() {
                /* We need to store the check state rather than relying on checkbox.attr('checked') to track it, 
                   because depending on whether the checkbox or the row is clicked, the attribute will have updated or not */
                checkbox.data('checked', !checkbox.data('checked'));
                enable_if_checked(this, hidden_fields)
                });
              checkbox.data('checked', false);
              enable_if_checked(checkbox, hidden_fields);
              
            } else {
              /* For everything else, we can just enable or disable the checkbox, which contains the filter value. */
              var name = 'filter[' + category + '][' + counter + ']';
              checkbox.attr('name', name).val(item['id']);
            }
          }
          var item_container = $('<div class="term"></div>');
          var use_checkbox = $('<input type="checkbox" class="left"/>');
          var term_container = $('<div class="term_name">' + SESSION_WORKSPACE_LINKS[item_json] + '</div>');
          var delete_button = $('<a href="#"><img src="/images/remove.png" alt="remove" title="remove" /></a>');
          var item_with_category = {};
          item_with_category[category] = [item];
          delete_button.attr('rel', JSON.encode(item_with_category));
          delete_button.click(delete_item).hide();
          var delete_container = $('<div class="right"></div>').append(delete_button);
          container.append(item_container);
          item_container.append(use_checkbox);
          set_up_checkbox(use_checkbox);
          item_container.append(delete_container);
          item_container.append(term_container);
          item_container.hover(
            function() {delete_button.show()},
            function() {delete_button.hide()}
          );
          
          /* When clicking on the row, toggle the checkbox. Don't toggle if a term name link was clicked */
          term_container.click(function(event) {
            if (!use_checkbox.attr('disabled') && $(event.target).hasClass('term_name')) {
              use_checkbox.click();
            }
          });
        });
      }
    });
    
    /* Enable and disable appropriate categories according to the Query for select */
    function select_query(query_option) {
      var type_sections = {
        'Phenotypes': 
          [{name: 'taxa', anyall: true},
           {name: 'genes', anyall: true},
           {name: 'entities', anyall: false},
           {name: 'qualities', anyall: true},
           {name: 'publications', anyall: true},
           {name: 'phenotypes', anyall: false}],
        'Phenotype annotations to taxa':
          [{name: 'taxa', anyall: false},
           {name: 'entities', anyall: false},
           {name: 'qualities', anyall: false},
           {name: 'publications', anyall: false},
           {name: 'phenotypes', anyall: false},
           {name: 'inferred_annotations'}],
        'Taxa':
          [{name: 'taxa', anyall: false},
           {name: 'entities', anyall: true},
           {name: 'qualities', anyall: true},
           {name: 'publications', anyall: true},
           {name: 'phenotypes', anyall: true},
           {name: 'inferred_annotations'}],
        'Phenotype annotations to genes':
          [{name: 'genes', anyall: false},
           {name: 'entities', anyall: false},
           {name: 'qualities', anyall: false},
           {name: 'phenotypes', anyall: false}],
        'Genes':
          [{name: 'entities', anyall: true},
           {name: 'qualities', anyall: true},
           {name: 'phenotypes', anyall: true}],
        'Comparative publications':
          [{name: 'taxa', anyall: true},
           {name: 'entities', anyall: true},
           {name: 'qualities', anyall: true},
           {name: 'phenotypes', anyall: true}],
      };
      
      function disable_section(selector) {
        var section = $(selector).not('.enabled');
        section.find(':input').not('[type="hidden"]').attr('disabled', true);
        section.find('.any_or_all').hide();
        section.addClass('disabled');
      };
      
      function enable_section(selector, enable_anyall) {
        var section = $(selector);
        section.removeClass('disabled');
        section.find(':input').not('[type="hidden"]').attr('disabled', false);
        if (enable_anyall)
          section.find('.any_or_all').show();
        else
          section.find('.any_or_all').attr('disabled', true)
      };
      
      /* Enable the appropriate sections */
      var enabled_sections = type_sections[query_option.html()];
      disable_section('.section');
      enabled_sections.each(function(section) {
        enable_section('.section#' + section.name, section.anyall)
      });
      
      /* Set the form action */
      query_option.closest('form').attr('action', query_option.val());
    };
    
    /* Set up Query for select box */
    var query_select = $('#related_query_links');
    query_select.attr('onchange', ''); // Remove the onchange event that's used for other queries
    query_select.change(function() {select_query($(this).find(':selected'))}); // .find(':selected') is the selected <option>
    select_query(query_select.find(':selected'));
  };
  
  
  function setup_extensions() {
    jQuery.fn.are = function(selector) {
      return !!selector && this.filter(selector).length == this.length;
    };
    
    function equals(xx, yy) {
      if (xx === undefined || xx === null || yy === undefined || yy === null) {return false;}
      
      for (p in xx) {
        if(typeof(yy[p])=='undefined') {return false;}
      }

      for (p in xx) {
        if (xx[p]) {
          switch(typeof(xx[p])) {
            case 'object':
              if (!equals(xx[p], yy[p])) { return false }; break;
            case 'function':
              if (typeof(yy[p])=='undefined' || (p != 'equals' && xx[p].toString() != yy[p].toString())) { return false; }; break;
            default:
              if (xx[p] != yy[p]) { return false; }
          }
        } else {
          if (yy[p]) {
            return false;
          }
        }
      }

      for (p in yy) {
        if (typeof(xx[p])=='undefined') {return false;}
      }

      return true;
    };

    Array.prototype.has = function(obj) {
      var i = this.length;
      while (i--) {
        if (equals(this[i], obj)) {
          return true;
        }
      }
      return false;
    };
  };
})(jQuery);
