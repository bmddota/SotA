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
// handle entity aiming better
// change the skull shot to something more pistoly
// make sf particles less messy?

/*
-Fixed the camera height getting offset randomly on respawn
-Fixed the flag sometime confusing the aiming system when carried
-Adjusted the camera/aiming system to function better
-Shadow Fiend Raze explosion radius increased from 350 to 400
*/


GameUI.SetRenderBottomInsetOverride( 0 );
GameUI.SetRenderTopInsetOverride( 0 );

var lookatOff = 0;
var offset = {"npc_dota_hero_nevermore":260,
              "npc_dota_hero_juggernaut":265}

function CamHeight(){
    var ent = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
    if (Entities.IsAlive(ent)){
      var name = Entities.GetUnitName(ent); 
      var off = 310;
      if (offset[name]) 
        off = offset[name];

      var height = Entities.GetAbsOrigin(ent)[2];
      //$.Msg(height, ' -- ', lookatOff, ' -- ', height - off + lookatOff);
      GameUI.SetCameraLookAtPositionHeightOffset( height - off + lookatOff);
    }

    $.Schedule(1/120, CamHeight);
}; 

function Score(){
  var radScore = CustomNetTables.GetTableValue( "sotaui", "radiant_score" );
  var direScore = CustomNetTables.GetTableValue( "sotaui", "dire_score" );

  if (radScore && direScore){
    $("#RadiantScore").text = radScore.value;
    $("#DireScore").text = direScore.value;
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

  if (targetIndex !== -1){
    var org = Entities.GetAbsOrigin(targetIndex)
    GameEvents.SendCustomGameEventToServer( "Sota_Aim", {"index":targetIndex});
  }
  else{
    var spos = GameUI.GetScreenWorldPosition(crossPos);
    //$.Msg(spos);
    if (spos == null){
      GameEvents.SendCustomGameEventToServer( "Sota_Aim", {});
    }else{
      GameEvents.SendCustomGameEventToServer( "Sota_Aim", {"x":spos[0], "y":spos[1], "z":spos[2]});
    }
  }
  $.Schedule(1/30, Aim);
}

function MouseHandler(ev, direction){
  if (ev == "pressed" && direction == 2){
    return true;
  }
  else if (ev == "wheeled"){
    lookatOff = Math.min(400, Math.max(-400, lookatOff + direction * 5));
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