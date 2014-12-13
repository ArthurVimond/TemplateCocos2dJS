(function () {
    var d = document;
    var c = {

        menuType:'canvas',
        COCOS2D_DEBUG:2,
        box2d:false,
        chipmunk:false,
        showFPS:false,
        frameRate:60,
        loadExtension:true,
        tag:'gameCanvas',

        // RELEASE
        //SingleEngineFile:'Cocos2DSimpleGame-v0.1.js',

        // DEBUG
        
        engineDir:'./Platform/HTML5/cocos2d/',
        appFiles:[
            './src/resource.js',
            './src/MainLayer.js',
            './src/main.js'
        ]
    };

    // Rest of file...

    window.addEventListener('DOMContentLoaded', function () {
        var s = d.createElement('script');

        if (c.SingleEngineFile && !c.engineDir) {
            s.src = c.SingleEngineFile;
        }
        else if (c.engineDir && !c.SingleEngineFile) {
            s.src = c.engineDir + 'platform/jsloader.js';
        }
        else {
            alert('You must specify either the single engine file OR the engine directory in "cocos2d.js"');
        }

        document.ccConfig = c;
        s.id = 'cocos2d-html5';
        d.body.appendChild(s);
    });
})();