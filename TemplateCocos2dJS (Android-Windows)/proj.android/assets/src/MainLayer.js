var audioEngine = cc.AudioEngine.getInstance();

var MainLayer = cc.LayerColor.extend({

    ctor:function() {

        this._super();

        cc.associateWithNative( this, cc.LayerColor );
    },

    onEnter:function () {
        this._super();

        if( 'touches' in sys.capabilities ) {
            this.setTouchEnabled(true);
        }
        if( 'mouse' in sys.capabilities ) {
            this.setMouseEnabled(true);
        }
        if( 'keyboard' in sys.capabilities ) {
            this.setKeyboardEnabled(true);
        }

        var helloLabel = cc.LabelTTF.create("Hello World !", "Arial", 30);
        helloLabel.setPosition(new cc.p(screenWidth/2, screenHeight*0.9));
        helloLabel.setColor(cc.c4b(255, 255, 255, 255));
        this.addChild(helloLabel);
    },

    onKeyDown:function(event) {

    },

    onKeyUp:function(event) {

    },

    onMouseDown: function(event){
        mouse = event.getLocation();
        mouseX = mouse.x;
        mouseY = mouse.y;
    },

    onMouseMove:function(x, y) {
        mouseX = x;
        mouseY = y;
        mouse = cc.p(mouseX, mouseY);
    },

    onMouseUp:function(event) {
        mouse = event.getLocation();
        mouseX = mouse.x;
        mouseY = mouse.y;
        //cc.log("mouseX: "+mouseX+" - mouseY: "+mouseY);
    },

    onTouchesBegan:function(touch, event){
        var pos = touch[0].getLocation();
        cc.log("touch begin: " + touch[0].getLocation().x + " - " + touch[0].getLocation().y);
    },

    onTouchesMoved:function(touch, event){
        cc.log("touch move: " + touch[0].getLocation().x + " - " + touch[0].getLocation().y);
    },
    
    onTouchesEnded:function(touch, event){
        cc.log("touch end!");
    },

    onTouchesCancelled:function(touch, event){
        cc.log("touch cancel!");
    }

});

var MyScene = cc.Scene.extend({
    ctor:function() {
        this._super();
        cc.associateWithNative( this, cc.Scene );
    },

    onEnter:function () {
        this._super();
        var layer = new MainLayer();
        this.addChild(layer);
        layer.init();
    }
});