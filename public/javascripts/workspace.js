/* Save to Workspace scripts */
(function($){
  $(document).ready(function() {
    setup_extensions();

    var save_boxes = $('.save');
    
    // Initialize checkboxes that were previously checked by the user
    save_boxes.each(function(i, element) {
      element = $(element);
      var category = element.attr('category');
      var data = JSON.decode(element.attr('rel'))[category][0];
      var was_checked = (SESSION_WORKSPACE_ITEMS[category] || []).has(data);
      element.attr('checked', was_checked);
    });
    
    // Save checkbox click event
    save_boxes.click(function(event) { // Save the row to the session via AJAX
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
    });
    
    // Save-all checkbox click event
    $('#save-all').click(function(event) {
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
    Object.prototype.equals = function(x) {
      if (x === undefined) {return false;}
      
      for (p in this) {
        if(typeof(x[p])=='undefined') {return false;}
      }

      for (p in this) {
        if (this[p]) {
          switch(typeof(this[p])) {
            case 'object':
              if (!this[p].equals(x[p])) { return false }; break;
            case 'function':
              if (typeof(x[p])=='undefined' || (p != 'equals' && this[p].toString() != x[p].toString())) { return false; }; break;
            default:
              if (this[p] != x[p]) { return false; }
          }
        } else {
          if (x[p]) {
            return false;
          }
        }
      }

      for (p in x) {
        if (typeof(this[p])=='undefined') {return false;}
      }

      return true;
    };

    Array.prototype.has = function(obj) {
      var i = this.length;
      while (i--) {
        if (this[i].equals(obj)) {
          return true;
        }
      }
      return false;
    };
  };
})(jQuery);