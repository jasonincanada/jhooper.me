$(document).ready(function() {

  // Show/hide the report card rows
  $('#show-reports').change(function() {
    if ($('#show-reports').prop('checked')) {
      $('tr.report-card-row').show();
    } else {
      $('tr.report-card-row').hide();
    }
  });

});
