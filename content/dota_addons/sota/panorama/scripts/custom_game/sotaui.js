// Hero ability mouseover
// check game ending control fix
// UI updates
//   Show team clearly
//   MOve SF UI to panorama
//   Move SF camera to panorama
//   Right click-reposition clarity
// check charge shots and death
// announcer sounds http://dota2.gamepedia.com/Announcer_responses
// options panel
// score settings

/*
-Removed the unnecessary selected hero projection particles
-Adjusted the camera/aiming system to function better in many scenarios
-SMG and Pistol projectiles changed to be more bullet like and less "flying skull"
-Added the ability for the host to set the total Points to Win for each match
-Shadow Fiend Raze explosion radius increased from 350 to 400
-Shadow Fiend arcana particle toned down for visibility
-Shadow Fiend flame colors made more prominent to show Blue/Red allegiance
-Fixed the camera height getting offset randomly on respawn
-Fixed the flag sometime confusing the aiming system when carried 
-Fixed an issue where the UI sometimes didn't initialize properly and showed 999 for all fields.
*/


GameUI.SetRenderBottomInsetOverride( 0 );
GameUI.SetRenderTopInsetOverride( 0 );

var lookatOff = 0;
var offset = {"npc_dota_hero_nevermore":390,
              "npc_dota_hero_juggernaut":400}

function CamHeight(){
    var ent = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
    if (Entities.IsAlive(ent)){
      var name = Entities.GetUnitName(ent); 
      var off = 430;
      if (offset[name]) 
        off = offset[name];

      var height = Entities.GetAbsOrigin(ent)[2];
      //$.Msg(height, ' -- ', lookatOff, ' -- ', height - off + lookatOff);
      //$.Msg(last - (height - off + lookatOff));
      //last = height - off + lookatOff;
      //count++;
      GameUI.SetCameraLookAtPositionHeightOffset( height - off + lookatOff);
    }

    $.Schedule(1/200, CamHeight);
}; 

function Score(){
  var radScore = CustomNetTables.GetTableValue( "sotaui", "radiant_score" );
  var direScore = CustomNetTables.GetTableValue( "sotaui", "dire_score" );

  if (radScore && direScore){
    $("#RadiantScore").text = radScore.value;
    $("#DireScore").text = direScore.value;

    var ent = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
    if (Entities.GetTeamNumber(ent) == DOTATeam_t.DOTA_TEAM_GOODGUYS){
      $("#RadiantScore").style.textDecoration = "underline";
    }
    else{
      $("#DireScore").style.textDecoration = "underline";
    }
  }
  $.Schedule(1/10, Score);
}

function CheckMouseBounds()
{
  var sw = GameUI.CustomUIConfig().screenwidth;
  var sh = GameUI.CustomUIConfig().screenheight;
  var pos = GameUI.GetCursorPosition();

  var perX = pos[0] / sw;
  var perY = pos[1] / sh;

  $("#RightBound").SetHasClass("ShowBound", false);
  $("#LeftBound").SetHasClass("ShowBound", false);
  $("#TopBound").SetHasClass("ShowBound", false);
  $("#BottomBound").SetHasClass("ShowBound", false);

  if (perX > .95){
    $("#RightBound").SetHasClass("ShowBound", true);
  }
  if (perX < .05){
    $("#LeftBound").SetHasClass("ShowBound", true);
  }
  if (perY > .95){
    $("#BottomBound").SetHasClass("ShowBound", true);
  }
  if (perY < .05){
    $("#TopBound").SetHasClass("ShowBound", true);
  }

  $.Schedule(1/60, CheckMouseBounds);
}

function ScreenHeightWidth()
{
  var panel = $.GetContextPanel();

  GameUI.CustomUIConfig().screenwidth = panel.actuallayoutwidth;
  GameUI.CustomUIConfig().screenheight = panel.actuallayoutheight;

  $.Schedule(1/4, ScreenHeightWidth);
}

function Aim()
{
  var cross = $("#CrossHair");
  var crossPos = [cross.actualxoffset + cross.actuallayoutwidth/2, cross.actualyoffset + cross.actuallayoutheight/2];

  //$.Msg(cross.actualxoffset + cross.actuallayoutwidth/2);
  //$.Msg(cross.actualyoffset + cross.actuallayoutheight/2);

  var mouseEntities = GameUI.FindScreenEntities( crossPos );
  var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
  var targetIndex = -1;

  mouseEntities = mouseEntities.filter( function(e) { return e.entityIndex !== localHeroIndex; } );
  for ( var e of mouseEntities )
  {
    if ( !e.accurateCollision || !Entities.IsRealHero(e.entityIndex))
      continue;

    targetIndex = e.entityIndex;
    break;
  }

  var spos = GameUI.GetScreenWorldPosition(crossPos);

  if (targetIndex !== -1){
    var org = Entities.GetAbsOrigin(targetIndex)
    if (spos == null){
      GameEvents.SendCustomGameEventToServer( "Sota_Aim", {"index":targetIndex});
    }else{
      GameEvents.SendCustomGameEventToServer( "Sota_Aim", {"index":targetIndex, "x":spos[0], "y":spos[1], "z":spos[2]});
    }
  }
  else{
    //$.Msg(spos);
    if (spos == null){
      GameEvents.SendCustomGameEventToServer( "Sota_Aim", {});
    }else{
      GameEvents.SendCustomGameEventToServer( "Sota_Aim", {"x":spos[0], "y":spos[1], "z":spos[2]});
    }
  }
  $.Schedule(1/30, Aim);
}


var wid = 100;
var move = -1;
function Bar(){
  var lefts = [$("#ManaBarLeft"), $("#HPBarLeft")];
  for (var left in lefts){
    left = lefts[left];
    left.style.width = wid + "%";
    if (left == $("#HPBarLeft")){
      $("#HPBarOverlay").style.width = wid + "%"; 
      var alpha = (Math.max(0,Math.min(255,(200 - Math.round(wid * 2.55))))).toString(16);
      if (alpha.length == 1) { alpha = "0" + alpha;}
      $("#HPBarOverlay").style.backgroundColor = "#FF0000" + alpha;
      $("#HPBarOverlay").style.boxShadow = "#FF0000" + alpha + " 1px 1px 6px 0px";
    }

    wid += move;
    if (wid < 0){
      wid = 0;
      move = 1;
    }
    else if (wid > 100){
      wid = 100;
      move = -1;
    }
  }

  $.Schedule(1/50, Bar);
}

function MouseHandler(ev, direction){
  if (ev == "pressed" && direction == 2){
    return true;
  }
  else if (ev == "wheeled"){
    lookatOff = Math.min(400, Math.max(-400, lookatOff + direction * 5));
    $.Msg(lookatOff);
    return true;
  }
  return false;
}


(function(){
  CamHeight();
  Score();
  ScreenHeightWidth();
  CheckMouseBounds();
  Aim();

  GameUI.SetMouseCallback(MouseHandler);
})(); 