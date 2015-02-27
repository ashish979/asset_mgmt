$(document).on('page:change', function() {
  ticketInitPage();
});

//calling on complete load of a page or document ready
$(function() {
  ticketInitPage();
});

function ticketInitPage(){
  $('#ticket_ticket_type_id').on('change',function() {
    var tkt_typ = $("#ticket_ticket_type_id option:selected").text();
    if(tkt_typ != "New Hardware" && tkt_typ != "- Select -"){
      $("#showAssetsForTicket").removeClass("hidden");
      $("#ticket_asset_id").attr("disabled", false)
    }
    else{
      $("#showAssetsForTicket").addClass("hidden");
      $("#ticket_asset_id").attr("disabled", true)
    }
  });

  showTicketTimeToolTip();

  $(document).on("click","#ticketSearchFormButton", function() {
    if(!$('#search_query').val()) {
      $("span#ticketSearchErrorSpan").html("Please fill text to search");
      return false;
    }else{
      $("span#ticketSearchErrorSpan").html("");
    }
  });    
  
}

function showTicketTimeToolTip(){
  $("span#ticketCreatedTime").hover(function(){
    $(this).tooltip("show");
      },function(){
        $(this).tooltip("hide"); 
  });
}

function resetSearchForm(){
  $("#category").val("Select");
  $("#search_query").val("")
}