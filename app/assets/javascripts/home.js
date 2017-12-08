//code that execute on load of page is required to write in assetInintPage so that both event either ready or page:change can access it.

//calling on page change or load of turbolinks
$(document).on('page:change', function() {
  homeInitPage();
});

//calling on complete load of a page or document ready
$(function() {
  homeInitPage();
});

function homeInitPage(){
  //to focus on barcode field
  $('input#barcode').focus();

  //to search on keyup function for barcode
  $('input#barcode').keyup (function () {
    if ($('input#barcode').val().length >= 10){
      $('#searchFormButton').parents('form:first').submit();
    }
  });

  //serach button for serach page
  $('#searchFormButton').click( function() {
    if(!$('#asset').val() && !$('#category').val() && !$('#status').val() && !$('#employee').val() && !$('#barcode').val() && !$('#tag').val() && !$('#to').val() && !$('#from').val()) {
      alert("Please select/fill atleast one field");
      return false;
    }
    if ($('input#barcode').val()){
      $('#searchFormButton').parents('form:first').submit();
    }
  });

  //pagination for ajax result, there is two clicks on pagination link is required if we use this code here
  // $(document).on("click",".serachResultPagination a", function(event) {
  //   event.preventDefault();
  //   $('.serachResultPagination a').attr('data-remote', 'true');
  // });

  //its for swtiching the color on click for home page
  $('.TagSpan').live('click', function(){
    $(this).removeClass('TagSpan').siblings().addClass('TagSpan');
    $(this).addClass('active').siblings().removeClass('active');
  });  
}
function showTag(tag_id) {
  $.ajax({
    url: $('#url_for_show_tag').val(), 
    dataType: 'script',
    type: 'get', 
    beforeSend: function() { showProgress() },
    complete: function() { endProgress() },
    data: 'tag_id='+tag_id
  });
}
