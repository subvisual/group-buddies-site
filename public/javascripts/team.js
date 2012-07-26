jQuery.noConflict();

jQuery(document).ready(function($) {

  var team = {
    current_member: window.location.search.slice(8) || "andre",

    set_current_class: function(name){
      $("a.current").each(function(){
        $(this).removeClass("current");
      });

      $("#nav-"+name).addClass("current");
      team.current_member = name;
    },

    pop_state: function(){
      $(window).bind('popstate', function(event){
        if(event.originalEvent.state)
        {
          $('#' + team.current_member).fadeOut(600);
          $('#' + event.originalEvent.state.previous).fadeIn(600);
          team.set_current_class(event.originalEvent.state.previous);
        }
      });
    },

    nav_click: function(){
      $("nav").on("click","a",function(event){
        var section_id = $(this).attr("id").replace("nav-","");

        if(section_id != 'home') {
          $("#"+team.current_member).fadeOut(600);
          $("#"+section_id).fadeIn(600);
          window.history.pushState({previous: section_id},"","/team?member="+section_id);
        }
        else { window.location("/"); }

        team.set_current_class(section_id);
        event.preventDefault();
      });
    },

    arrow_click: function() {
      $(".arrow").on("click",function(event){
        var section_id = null;
        if($(this).hasClass("left")) {
          section_id = $(this).parent().parent().prev().attr("id");
        }
        else if($(this).hasClass("right")) {
          section_id = $(this).parent().parent().next().attr("id");
        }

        $("#"+team.current_member).fadeOut(600);
        $("#"+section_id).stop().fadeIn(600);

        team.set_current_class(section_id);
        event.preventDefault();
      });
    },

    init: function(){
      team.set_current_class(team.current_member);
      team.nav_click();
      team.arrow_click();
      team.pop_state();
    }
  };

  team.init();
});