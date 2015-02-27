//code that execute on load of page is required to write in assetInintPage so that both event either ready or page:change can access it.

//calling on page change or load of turbolinks
$(document).on('page:change', function() {
  employeeInitPage();
});

//calling on complete load of a page or document ready
$(function() {
  employeeInitPage();
});

//this function will contain the code of piece which needed to ready or page change
//function which will be called in turbolink and ready even both
function employeeInitPage() {
  $('a[disabled=disabled]').click(function(event){
    return false;
  });
}

//to mark or unmark as admin
$('#adminStatusForm input[type=checkbox]').live("click",function () {
  var form = $(this).parent("form");
  var check = $(this).attr('checked');
  var name = $(this).next().val();
  var mark_admin = "Click Ok to make  '" +  name + "'  as admin."
  var unmark_admin = "'" + name + "'  will no longer be admin. Click Ok to continue."
  var msg = check ? mark_admin : unmark_admin
  if (confirm(msg)) {
    $.ajax({
      type: "PUT",
      url: form.attr( 'action' ),
      beforeSend: function() { showProgress() },
      complete: function() { endProgress() },
      data: form.serialize()
    });
  }else{
    if (check == 'checked'){
      $(this).attr('checked','checked');
    }
    return false;
  }
});