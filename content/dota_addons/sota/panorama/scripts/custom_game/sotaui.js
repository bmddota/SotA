// Hero ability mouseover
// check game ending control fix
// UI updates
//   Right click-reposition clarity
// check charge shots and death
// announcer sounds http://dota2.gamepedia.com/Announcer_responses
// options panel

// camera library?  

/*
-Sacred arrow reload time reduced to 1.0
-Changed default camera height for Mirana to allow for better long distance aiming
-Reduced the likelihood of Sacred Arrow errantly hitting the ground
-Fixed Sacred Arrow pushing heroes fully through the ground
-Powershot push force reduced from 2400 to 2200
-Added stats collection via getdotastats.com
*/


GameUI.SetRenderBottomInsetOverride( 0 );
GameUI.SetRenderTopInsetOverride( 0 ); 

var lookatOff = 0;
var offset = CustomNetTables.GetTableValue( "sotaui", "offsets" );
$.Msg("offset")
$.Msg(offset);


var pitch = 67;
var yaw = 90;
var distance = 350;
var xSensitivity = 1/3;
var ySensitivity = 1/5;
var camActivate = false;
var prevCursorPos = null;

function CameraActivate(msg)
{
  var activate = msg.activate;
  camActivate = (activate === 1);
  if (!camActivate)
    prevCursorPos = null;
}

function CameraDistance(msg)
{
  var dist = msg.dist;
  distance = dist;
}

function Camera()
{
    var ent = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
    var name = Entities.GetUnitName(ent); 
    var off = 210;
    if (offset[name]) 
      off = offset[name];

    //off = 6400;
    var height = Entities.GetAbsOrigin(ent)[2];
    var lookAtHeight = height - off + lookatOff;

    var offHeight = 0;
    var offDist = 0;
    var pit = pitch;

    if (camActivate){
      var cursorPos = GameUI.GetCursorPosition();

      if (prevCursorPos == null){
        prevCursorPos = cursorPos;
      }
      
      var deltaX = cursorPos[0] - prevCursorPos[0];
      var deltaY = cursorPos[1] - prevCursorPos[1];

      prevCursorPos = cursorPos;
      
      yaw -= deltaX * xSensitivity;
      while (yaw <= 0)
        yaw += 360;
      while (yaw >= 360)
        yaw -= 360;
        
      pitch += deltaY * ySensitivity;
      if (pitch <= -88){
        pitch = -88;
      }
      if (pitch >= 88)
        pitch = 88;

      if (pitch > 0)
        GameUI.SetCameraPitchMax(pitch);
      else{
        GameUI.SetCameraPitchMax(pitch+360);
      }
      GameUI.SetCameraYaw(yaw);
    }

    if (pitch < 0){
      //$.Msg(Math.sin(pitch * Math.PI / 180) * distance * -1, ',', lookAtHeight);
      offHeight = Math.max(0,Math.sin(pitch * Math.PI / 180) * distance * -1 - (off + lookatOff) + 10);
    }

    GameUI.SetCameraDistance(distance);

    if (Entities.IsAlive(ent)){
      GameUI.SetCameraLookAtPositionHeightOffset( lookAtHeight + offHeight );
    }

    $.Schedule(1/200, Camera);
}

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
var lastHp = -1;
function Bar(){
  var hero = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
  var hp = Entities.GetHealth(hero);
  if (lastHp == -1)
    lastHp = hp;
  var hpMax = Entities.GetMaxHealth(hero);
  var hpPer = (hp * 100 / hpMax).toFixed(1);
  var mana = Entities.GetMana(hero);
  var manaMax = Entities.GetMaxMana(hero);
  var manaPer = (mana * 100 / manaMax).toFixed(1);

  var delta = Math.abs(hp - lastHp);
  if (delta <= 1)
    $("#HPBarLeft").style.transition = "width 0.5s linear 0.0s;"
  else
    $("#HPBarLeft").style.transition = "width 0.2s linear 0.0s;"

  $("#HPText").text = hp;
  lastHp = hp;
  $("#ManaText").text = mana;

  $("#HPBarLeft").style.width = hpPer * 5 + "px";
  $("#ManaBarLeft").style.width = manaPer * 5 + "px";

  $("#HPBarLeft").SetHasClass("NoBorder", hpPer == 100);
  $("#ManaBarLeft").SetHasClass("NoBorder", manaPer == 100);

  $.Schedule(1/10, Bar);
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

function KDA(){
  var pid = Players.GetLocalPlayer();

  var kills = Players.GetKills(pid);
  var deaths = Players.GetDeaths(pid);
  var assists = Players.GetAssists(pid);

  $("#KDA").text = kills + "/" + deaths + "/" + assists;
  $.Schedule(1/10, KDA);
}


function ChangeWeapon(wep)
{
  for (var i=1; i<=3; i++){
    $("#WeaponBar" + i).SetHasClass("WeaponActive", i == wep);
  }
}

function SetAmmo(ammo)
{
  if (ammo !== -1){
    $("#AmmoCurrent").text = ammo;
  }else{
    $("#AmmoCurrent").text = "--";
  }
}

function SetReserve(reserve)
{
  if (reserve !== -1){
    $("#AmmoReserve").text = reserve;
  }else{
    $("#AmmoReserve").text = "--";
  }
}


function StateChange(tableName, changes, del)
{
  var panel = $.GetContextPanel();
  //$.Msg('StateChange -- ', tableName, ' -- ', changes, ' -- ', del); 
  if (!changes)
    return;

  //if ("headerText" in del)
    //SetHeaderText("");

  var pt = changes;


  if ("ammo" in changes)
    SetAmmo(pt.ammo);

  if ("reserve" in changes)
    SetReserve(pt.reserve);

  if ("weapon" in changes)
    ChangeWeapon(pt.weapon);

  if ("weapon1" in changes)
    $("#WeaponBar1").GetChild(0).text = pt.weapon1;

  if ("weapon2" in changes)
    $("#WeaponBar2").GetChild(0).text = pt.weapon2;

  if ("weapon3" in changes)
    $("#WeaponBar3").GetChild(0).text = pt.weapon3;
}

var tbClass = "TimePurple";
var tbName = "Reload";
var tbActive = true;
var tbStart = 0.0;
var tbEnd = 1.0;
var tbInvert = true;

function TimeBar()
{
  var left = $("#TimeBarLeft");
  left.SetHasClass("TimePurple", false);
  left.SetHasClass("TimeYellow", false);
  left.SetHasClass("TimeRed", false);
  left.SetHasClass(tbClass, true);

  $("#TimeBar").visible = tbActive;

  if (tbActive){
    left.style.transition = "width 0.1s linear 0.0s;"
    var curTime = Math.max(0, Game.GetGameTime() - tbStart);
    var end = tbEnd - tbStart;
    var per = 0;
    if (end !== 0)
      per = Math.min(100, (curTime * 100/ end).toFixed(2));

    if (tbInvert){
      per = 100 - per;
      curTime = end - curTime;
    }

    curTime = Math.max(0,Math.min(end, curTime)).toFixed(1);

    if (curTime == "0.0" && tbInvert){
      tbActive = false;
    }
    //$.Msg(Game.GetGameTime(), ' ', tbStart, ' ', tbEnd, ' ', curTime, ' ', end, ' ', per);
    left.style.width = per * 2.4 + "px";
    $("#TimeText").text = curTime;
    $("#TimeName").text = tbName;
  }
  $.Schedule(1/10, TimeBar);
}

function WeaponChange(msg)
{
  $.Msg("WeaponChange");
  $.Msg(msg);

  tbClass = "TimeYellow";
  tbName = "Switch";
  tbStart = Game.GetGameTime();
  tbEnd = tbStart + msg.time;
  tbInvert = true;
  tbActive = true;

  $("#TimeBarLeft").style.transition = "width 0.0s linear 0.0s;"
  $("#TimeBarLeft").style.width = "100%";
}

function SotaCharge(msg)
{
  $.Msg("SotaCharge");
  $.Msg(msg); 

  tbClass = "TimeRed";
  tbName = "Charge";
  tbStart = Game.GetGameTime();
  tbEnd = tbStart + msg.time;
  tbInvert = false;
  tbActive = true;

  if (msg.time <= 0)
    tbActive = false;

  $("#TimeBarLeft").style.transition = "width 0.0s linear 0.0s;"
  $("#TimeBarLeft").style.width = "0%";
}

function WeaponReload(msg)
{
  $.Msg("WeaponReload");
  $.Msg(msg);

  tbClass = "TimePurple";
  tbName = "Reload";
  tbStart = Game.GetGameTime();
  tbEnd = tbStart + msg.time;
  tbInvert = true;
  tbActive = true;

  $("#TimeBarLeft").style.transition = "width 0.0s linear 0.0s;"
  $("#TimeBarLeft").style.width = "100%";
}


(function(){
  Camera();
  Score();
  ScreenHeightWidth();
  CheckMouseBounds();
  Aim();
  Bar();
  KDA();
  TimeBar();

  GameUI.SetMouseCallback(MouseHandler);

  GameEvents.Subscribe("weapon_change", WeaponChange);
  GameEvents.Subscribe("sota_charge", SotaCharge);
  GameEvents.Subscribe("weapon_reload", WeaponReload);

  GameEvents.Subscribe("camera_activate", CameraActivate);
  GameEvents.Subscribe("camera_distance", CameraDistance);

  var idString = "p" + Players.GetLocalPlayer();

  if ($.GetContextPanel().subscription){
    PlayerTables.UnsubscribeNetTableListener($.GetContextPanel().subscription);
  }
  $.GetContextPanel().subscription = PlayerTables.SubscribeNetTableListener(idString, StateChange);

  var pt = PlayerTables.GetAllTableValues(idString);
  ChangeWeapon(pt.weapon);
  SetAmmo(pt.ammo);
  SetReserve(pt.reserve);
  $("#WeaponBar1").GetChild(0).text = pt.weapon1;
  $("#WeaponBar2").GetChild(0).text = pt.weapon2;
  $("#WeaponBar3").GetChild(0).text = pt.weapon3;

  //GameEvents.SendEventClientSide("control_override_cvar", {"pid":-1, "cvar":"dota_hide_cursor", "value":""} );

})(); 