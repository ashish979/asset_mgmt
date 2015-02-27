//code that execute on load of page is required to write in assetInintPage so that both event either ready or page:change can access it.

//calling on page change or load of turbolinks
$(document).on('page:change', function() {
  assetInitPage();
});

//calling on complete load of a page or document ready
$(function() {
  assetInitPage();
});

//this function will contain the code of piece which needed to ready or page change
//function which will be called in turbolink and ready even both
function assetInitPage() {
  //to scroll up when clicking on add more option on asset edit page
  $("a.tab").on('click', function(){
    $("div#showFlashMsg").html("");
  });

  $(".add_nested_fields").on("click", function(){
    $('html, body').animate({ scrollTop: $('#multipleUploadForm').offset().top }, 'slow');
  })

  $('.field_with_errors').parent().addClass('error');

  $("span#commentCreatedTime").hover(function(){
  $(this).tooltip("show");
    },function(){
      $(this).tooltip("hide"); 
  }); 

  //to show loading icon on ajax request through remote true
  $(document).on("click",'.remote-true-ajax-call', function() {
    showProgress();
  });

  $(".fields:empty").remove();
  $(".fields:first").find("a.remove_nested_fields").hide();

  //to focus on barcode field on assign asset page
  $('input#asset_barcode').focus();

  //to search on keyup function for barcode and fill asset and asset type on assign asset page
  $('input#asset_barcode').on('keyup',function() {
    $('#paramsAssetBarcode').val($('input#asset_barcode').val());
    if ($('input#asset_barcode').val().length > 9){
      $.ajax({
        type: "GET",
        dataType: 'script',
        url: $('#url_for_change_aem_form').val(),
        beforeSend: function() { showProgress() },
        complete: function() { endProgress() },
        data: 'barcode='+$('#asset_barcode').val()
      });
    }
  });

  //datepicker for purchase date field at asset new page 
  $("#asset_purchase_date").datepicker({ maxDate: new Date, dateFormat: "dd/mm/yy" });
  $("#from").datepicker({ maxDate: "-1D", dateFormat: "dd M yy",changeMonth: true, changeYear: true });
  $("#to").datepicker({ maxDate: new Date, dateFormat: "dd M yy",changeMonth: true, changeYear: true });
  //js for assignments
  $("#assignment_date_issued").datepicker({ maxDate: new Date, dateFormat: "dd M yy" });
  $('#assignment_date_returned').datepicker({maxDate: new Date, dateFormat: "dd M yy" });
  if(($("input[name='assignment[assignment_type]']:checked").attr("value")) == "false") {
    $("#assignment_expected_return_date").attr( "disabled", false );
    $('#toreqiuredField').removeClass('hidden');
    $("#assignment_expected_return_date").datepicker({ minDate: "+1D", dateFormat: "dd M yy" });
  }
}

//method wihch were called by another functions or had a event handler need not required to write in page change or ready event section 
//to print the report
/*$(document).on("click","#printDateReport", function(event) {
  event.preventDefault();
  $('#printTableDiv').printThis();
});
*/

//click event for asset repair history button
$(document).on("click","#assetCommentLink", function(event) {
  event.preventDefault(); 
  $('div#error_explanation').html('');
  $('div#showFlashMsg').html("");
  var elem = $('#assetCommentDiv')
  if (elem.hasClass('hidden')){
    elem.removeClass('hidden');
    $(this).addClass('highlighted')
  }else{
    elem.addClass('hidden');
    $(this).removeClass('highlighted')
  }
});

//click function for submit button of repair comment
$(document).on("click","#repairCommentButton", function(event) {  
  $('#repairCommentButton').off("click");
   submitComments($(this),event); 
});

//to open a print window for print the barcode
$(document).on("click","#canvas, #barcodeLinkDiv, #printBarcode", function(event) {
  event.preventDefault(); 
  $('#barcodeImage').printThis();
});

//to open a print window for instruction to print the barcode
$(document).on("click","#printBarcodeInstructions", function(event) {
  event.preventDefault();
  $('#printInstructionLink').modal('toggle');
});

//submit the asset comment
function submitComments(elem, event){
  event.preventDefault();
  var form = elem.parents("form").first();
  $.ajax({
    type: "POST",
    url: form.attr( 'action' ),
    beforeSend: function() { showProgress() },
    complete: function() { endProgress() },
    data: form.serialize()
  });
}

//js for asset assignments
//on change of asset type it will show assets only for that asset type
$(document).on("click","input[name='assignment[assignment_type]']", function(event) {
  var returned = $("#assignment_expected_return_date");
  if(this.value == "false") {
    returned.attr("disabled", false);
    $('#toreqiuredField').removeClass('hidden');
    returned.datepicker({"disabled": false, minDate: "+1D", dateFormat: "dd M yy" });
  }
  else {
    returned.attr("disabled", true);
    returned.attr("value", "");
    $('#toreqiuredField').addClass('hidden');
    returned.datepicker({"disabled":true});
  } 
});

//to populate asset according to asset type
function populateAsset(url) {
  $.ajax({
    url: url, 
    dataType: 'script',
    type: 'get', 
    beforeSend: function() { showProgress() },
    complete: function() { endProgress() },
    data: 'category='+$("#category").attr("value")
  });
}

//fill asset type field if asset selected
function fillAssetType(url){
  $.ajax({
    url: url, 
    type: 'get', 
    beforeSend: function() { showProgress() },
    complete: function() { endProgress() },
    data: 'asset='+$("#assignment_asset_id").val()
  });
}

//disable enter key on asset edit page
$('#assetPropertyForm input.assetPropertyValue').live("keypress",function (event) {
  return disableEnterKey(event);
});
//to update the value of property
$('#assetPropertyForm input.assetPropertyValue').live("change",function () {
  var form = $(this).parent("form");
  $.ajax({
    type: "PUT",
    url: form.attr( 'action' ),
    beforeSend: function() { showProgress() },
    complete: function() { endProgress() },
    dataType: "script",
    data: form.serialize()
  });
});

//to remove the strong line and disable enter on property edit page
function removeLineAndDisableEnterKey(){
  $("div.strongLine").last().remove();
  // return disableEnterKey(event);
};

disableEnterKey = function(e) {
  var code = (e.keyCode ? e.keyCode : e.which);
  if(code == 13) { 
    return false;
  }
};

//sorting the asset table
$(document).on("click","table.tablesorter thead tr .header", function() {
  var header_id = $(this).attr('id');
  var sort = $(this).data('sort'); 
  $.ajax({
    type: 'GET',
    url: $('span#getUrlForSorting').data('url'),
    dataType: 'script',
    beforeSend: function() { showProgress() },
    data: { 
      'sort': $(this).data('sort'), 
      'type': $(this).data('type'), 
      'page': $(this).data('page')
    }
  }).done(function( msg ) {
    endProgress();
    if (/asc/i.test(sort)){
      $('#' + header_id).addClass('headerSortDown');
    }
    else{
      $('#' + header_id).addClass('headerSortUp');
    }
  }); 
});
