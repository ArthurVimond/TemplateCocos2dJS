require("jsb.js");
require("src/resource.js");
require("src/MainLayer.js");

var director = cc.Director.getInstance();
var winSize = director.getWinSize();
var screenWidth = winSize.width;
var screenHeight = winSize.height;
var centerPos = cc.p(screenWidth/2, screenHeight/2);
var mouse;
var mouseX = 0;
var mouseY = 0;

//------------------------------------------------------------------
//
// Main entry point
//
//------------------------------------------------------------------
function run()
{
    director.runWithScene( MainLayer.scene() );
}

run();