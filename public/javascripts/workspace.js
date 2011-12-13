/* add.png and accept.png icons under CCA license. credit: http://famfamfam.com/lab/icons/silk/ */
var categories = ['taxa', 'genes', 'entities', 'qualities', 'publications', 'phenotypes'];
var terms = SESSION_WORKSPACE_TERMS;
var parent_categories = ['phenotypes', 'annotations'];
var phenotype_component_types = ['entity', 'quality', 'related_entity'];
var component_map = {
    'entity': 'entities',
    'related_entity': 'entities',
    'quality': 'qualities',
    'gene': 'genes',
    'taxon': 'taxa'
};
var category_map = {
    'entities': 'entity',
    'qualities': 'quality',
    'genes': 'gene',
    'taxa': 'taxon'
};
var type_sections = {
    'Phenotypic profile tree':
    [{
        name: 'phenotypes'
    },
    {
        name: 'entities'
    },
    {
        name: 'qualities'
    }],
    'Phenotypes':
    [{
        name: 'taxa',
        anyall: true
    },
    {
        name: 'genes',
        anyall: true
    },
    {
        name: 'entities'
    },
    {
        name: 'qualities'
    },
    {
        name: 'publications',
        anyall: true
    },
    {
        name: 'phenotypes',
        anyall: false
    }],
    'Phenotype annotations to taxa':
    [{
        name: 'taxa',
        anyall: false
    },
    {
        name: 'entities'
    },
    {
        name: 'qualities'
    },
    {
        name: 'publications',
        anyall: false
    },
    {
        name: 'phenotypes',
        anyall: false
    },
    {
        name: 'inferred_annotations',
        anyall: true
    }],
    'Taxa':
    [{
        name: 'taxa',
        anyall: false
    },
    {
        name: 'entities'
    },
    {
        name: 'qualities'
    },
    {
        name: 'publications',
        anyall: true
    },
    {
        name: 'phenotypes',
        anyall: true
    },
    {
        name: 'inferred_annotations',
        anyall: true
    }],
    'Phenotype annotations to genes':
    [{
        name: 'genes',
        anyall: false
    },
    {
        name: 'entities'
    },
    {
        name: 'qualities'
    },
    {
        name: 'phenotypes',
        anyall: false
    }],
    'Genes':
    [{
        name: 'entities'
    },
    {
        name: 'qualities'
    },
    {
        name: 'phenotypes',
        anyall: true
    }],
    'Comparative publications':
    [{
        name: 'taxa',
        anyall: true
    },
    {
        name: 'entities'
    },
    {
        name: 'qualities'
    },
    {
        name: 'phenotypes',
        anyall: true
    }],
    'Faceted browsing':
    [{
        name: 'taxa',
        anyall: false
    },
    {
        name: 'genes',
        anyall: false
    },
    {
        name: 'entities'
    },
    {
        name: 'qualities'
    }]
};


/* Save to Workspace scripts */
 (function($) {
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

    // Initialize add_buttons that were previously checked by the user
    save_boxes.each(function(i, element) {
        var add_button = $(element);
        add_button.hide();
        var row = add_button.closest('tr');
        row.hover(
        function() {
            add_button.show();
        },
        function() {
            add_button.hide();
        }
        );
    });

    var ajax_error_handler = function() {
        alert("There was a problem saving to the workspace. Check your internet connection or report this problem in feedback. Reload the page to try again.")
    };
    var added_confirmation = '<img src="/images/accept.png" title="Added to workspace">';

    // Save add_button click event
    save_boxes.click(function(event) {
        // Save the row to the session via AJAX
        var add_button = $(event.target).closest('a');
        var data = add_button.attr('rel');
        $.ajax({
            url: '/workspace',
            type: 'post',
            data: {
                _method: 'put',
                data: data,
                authenticitiy_token: AUTH_TOKEN
            },
            error: ajax_error_handler
        });

        // Replace the icon with a confirmation
        add_button.replaceWith(added_confirmation);

        // Don't follow the # link
        return false;
    });

    // Save-all add_button click event
    save_all.click(function(event) {
        var boxes = $('.save');

        // Collect data from all add_buttones
        var page_type;
        var terms = save_boxes.map(function(i, element) {
            var hash = JSON.decode($(element).attr('rel'));

            // hash is of the form: {"type": [{...}]}; the hash value array only contains one element.
            for (type in hash) {
                // Iterate over the one type, because this is the only way I know to pull it out without knowing its name
                page_type = type;
                return hash[type][0];
            }
        }).get();
        var data = {};
        data[page_type] = terms;
        data = JSON.encode(data);

        // Send it in one request
        $.ajax({
            url: '/workspace',
            type: 'post',
            data: {
                _method: 'put',
                data: data,
                authenticitiy_token: AUTH_TOKEN
            },
            error: ajax_error_handler
        });

        // Replace the icon with a confirmation
        save_boxes.replaceWith(added_confirmation);
        save_all.remove();

        // Don't follow the # link
        return false;
    });
};

/* Define callbacks for terms */
function delete_term() {
   var delete_button = $(this);
   var term_container = delete_button.closest('.term');

   /* Remove the term from the workspace */
   var full_term_json = delete_button.attr('rel');
   $.ajax({
       url: '/workspace',
       type: 'post',
       data: {
           _method: 'delete',
           data: full_term_json,
           authenticitiy_token: AUTH_TOKEN
       },
       success: undefined
   });

   /* Remove term visibly from the page */
   term_container.remove();

   return false;
   // Don't follow the # link
}

/* Enable and disable appropriate categories according to the Query for select */
  function select_query(query_option) {
      insert_terms_in_categories(query_option);

      function disable_sections() {
          var section = $('.section,.section_options').not('.enabled');
          $('.section_options').hide();
          section.find(':input').not('[type="hidden"]').attr('disabled', true);
          section.addClass('disabled');
      };

      function enable_section(section_name, enable_anyall) {
          var section = $('.section#' + section_name + ',.section_options#' + section_name + '_options');
          section.removeClass('disabled');
          section.find(':input').not('[type="hidden"]').attr('disabled', false);
          if (enable_anyall)
          $('.section_options#' + section_name + '_options').show();
          else
          $('.section_options#' + section_name + '_options').hide().find('input').attr('disabled', true)
      };

      /* Enable the appropriate sections */
      var enabled_sections = type_sections[query_option.html()];
      disable_sections();
      enabled_sections.each(function(section) {
          enable_section(section.name, section.anyall)
      });

      /* Set the form action */
      query_option.closest('form').attr('action', query_option.val());
  };
  
  
function clear_categories() {
    categories.each(function(category) {
        var container = $('#' + category + " .filter");
        container.empty();
    });
}

function set_up_checkbox(checkbox, category, term) {
     /* Keep a counter to make unique params */
     if (!this.counter) {
         this.counter = 0;
     }
     this.counter++;

     if (['phenotypes', 'entities', 'qualities'].include(category)) {
         /* For phenotypes, we need to send params for each phenotype component */

         /* Create and insert hidden fields into the DOM */
         var hidden_fields = phenotype_component_types.map(function(component_type) {
             if (term[component_type] || category == component_type.sub('entity', 'entities').sub('quality', 'qualities')) {
                 var insertion_term = term;
                 /* If term is not a phenotype, then it's a component. Wrap it in a phenotype */
                 if (category != 'phenotypes') {
                     insertion_term = {};
                     insertion_term[component_type] = term;
                 }
                 var name = 'filter[phenotypes][' + counter + '][' + component_type + ']';
                 return $('<input type="hidden" name="' + name + '" value="' + insertion_term[component_type]['id'] + '" />').insertAfter(checkbox);
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
         checkbox.attr('name', name).val(term['id']);
     }
 }
 
function set_up_radio_button(radio_button, category, term) {
    var name = 'facet_paths[' + category_map[category] + ']';
    radio_button.attr('name', name);
    if (term) {
        radio_button.val(term['id']);
    } else {
        radio_button.val('');
    }
}
 
function create_checkbox_input(category, term) {
    var input_container = $('<span></span>');
    var use_checkbox = $('<input type="checkbox" class="left"/>');
    input_container.append(use_checkbox);
    set_up_checkbox(use_checkbox, category, term);
    return input_container;
}

function create_radio_input(category, term) {
    var radio_button = $('<input type="radio" class="left"/>');
    set_up_radio_button(radio_button, category, term);
    return radio_button;
}

function insert_terms_in_categories(query_option) {
    clear_categories();
    /* Insert terms from each category into the DOM */
    radio = (query_option.html() == "Faceted browsing");
    categories.each(function(category) {
        var container = $('#' + category + " .filter");
        if (radio) {
            var term_container = $('<div class="term rounded-large"></div>');
            var any_button = create_radio_input(category, null);
            any_button.attr('checked', true);
            term_container.append(any_button);
            term_container.append('<span>Any</span>');
            container.append(term_container);
        }
        if (terms[category]) {
            // Uniq the JSON, because uniq removes duplicate objects or strings, not objects with duplicate contents
            var unique_json_array = terms[category].map(function(term) { return JSON.encode(term) }).uniq();
            unique_json_array.each(function(term_json) {
                var term = JSON.decode(term_json);
                var term_container = $('<div class="term rounded-large"></div>');
                if (radio) {
                    var input_container = create_radio_input(category, term);
                } else {
                    var input_container = create_checkbox_input(category, term);
                }
                
                var term_name_container = $('<div class="term_name">' + SESSION_WORKSPACE_LINKS[term_json] + '</div>');
                var delete_button = $('<a href="#"><img src="/images/remove.png" alt="remove" title="remove" /></a>');
                var term_with_category = {};
                var query_category = category.gsub(/entities|qualities/, 'phenotypes')
                term_with_category[category] = [term];
                delete_button.attr('rel', JSON.encode(term_with_category));
                delete_button.click(delete_term).hide();
                var delete_container = $('<div class="right"></div>').append(delete_button);
                container.append(term_container);
                term_container.append(input_container);
                term_container.append(delete_container);
                term_container.append(term_name_container);
                term_container.hover(
                function() {
                    delete_button.show()
                },
                function() {
                    delete_button.hide()
                }
                );

                /* When clicking on the row, toggle the checkbox. Don't toggle if a term name link was clicked */
                // term_name_container.click(function(event) {
                //                     if (!use_checkbox.attr('disabled') && $(event.target).hasClass('term_name')) {
                //                         use_checkbox.click();
                //                     }
                //                 });
            });
        }
    });
}

function setup_workspace() {

    /* ensure each category is defined in terms */
    function ensure_terms_defines(category) {
        if (!terms[category])
        terms[category] = [];
    }
    categories.each(ensure_terms_defines);
    parent_categories.each(ensure_terms_defines);



  

    /* Set up Query for select box */
    var query_select = $('#related_query_links');
    if (query_select.length) {
        query_select.attr('onchange', '');
        // Remove the onchange event that's used for other queries
        query_select.change(function() {
            select_query($(this).find(':selected'))
        });
        // .find(':selected') is the selected <option>
        select_query(query_select.find(':selected'));
    }
};


function setup_extensions() {
    jQuery.fn.are = function(selector) {
        return !! selector && this.filter(selector).length == this.length;
    };

    function equals(xx, yy) {
        if (xx === undefined || xx === null || yy === undefined || yy === null) {
            return false;
        }

        for (p in xx) {
            if (typeof(yy[p]) == 'undefined') {
                return false;
            }
        }

        for (p in xx) {
            if (xx[p]) {
                switch (typeof(xx[p])) {
                case 'object':
                    if (!equals(xx[p], yy[p])) {
                        return false
                    };
                    break;
                case 'function':
                    if (typeof(yy[p]) == 'undefined' || (p != 'equals' && xx[p].toString() != yy[p].toString())) {
                        return false;
                    };
                    break;
                default:
                    if (xx[p] != yy[p]) {
                        return false;
                    }
                }
            } else {
                if (yy[p]) {
                    return false;
                }
            }
        }

        for (p in yy) {
            if (typeof(xx[p]) == 'undefined') {
                return false;
            }
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
