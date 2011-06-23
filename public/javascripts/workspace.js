/* Save to Workspace scripts */
(function($){
  $(document).ready(function() {
    setup_extensions();

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
  });
  
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