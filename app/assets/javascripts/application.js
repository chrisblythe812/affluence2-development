// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap-tooltip
//= require_tree .
function getActivities(type_object, get_more){
  last_activity = $('#latest_activities tr:last-child').attr('class');
  params = {
    "get_more"       : get_more,
    "last_activity"  : last_activity
  }
  $.extend(params, type_object);


  $.ajax({
    type: "GET",
    url:"/activities/latest",
    data: params,
    beforeSend: function ( xhr ) {
      if(!get_more) {
        $("#latest_activities").html("<tr>" +
          "<td class='span1'>" +
          "<div id='spinner' style='width:40px'>" +
          "<img src='/assets/ajax-loader.gif' class='ajax-loader' alt='Ajax-loader'>" +
          "<p>Loading....</p>" +
          "</div>" +
          "</td>" +
          "</tr>"  );
      }
      else if(get_more) {
        $('.more-activities').attr("disabled", true);
      }
    },
    success: function(data) {
      if(get_more) {
        $("#latest_activities").append(data);
        if ($('#latest_activities tr:last-child').attr('class') == last_activity) {
          $('.more-activities').text("no more activities");
        }
        else {
          $('.more-activities').attr("disabled", false); 
        }
      }
      else {
        $("#latest_activities").html(data);
      }
    }
  });
}
  