/* Save to Workspace scripts */
(function($){
  $(document).ready(function() {
    $('.save').click(function(event) { // Save the row to the session via AJAX
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
  });
})(jQuery);