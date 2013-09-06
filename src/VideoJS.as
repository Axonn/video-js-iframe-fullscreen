package{
	import com.teemusk.FullscreenPlayButton;
	import flash.events.MouseEvent;
	import com.teemusk.FullScreenPopup;
    
	//	VidCaster edit
	import com.LiveRail.LiveRailView;
	//	End VidCaster edit
    import com.videojs.VideoJSApp;
    import com.videojs.VideoJSModel;
    import com.videojs.VideoJSView;
    import com.videojs.events.VideoJSEvent;
    import com.videojs.structs.ExternalErrorEventName;
    
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.geom.Rectangle;
    import flash.media.Video;
    import flash.system.Security;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.utils.Timer;
    import flash.utils.setTimeout;
    
    [SWF(backgroundColor="#000000", frameRate="60", width="480", height="270")]
    public class VideoJS extends Sprite{
        
        private var _app:VideoJSApp;
        private var _stageSizeTimer:Timer;

		//	VidCaster edit
		private var _liverail:LiveRailView = null;
		private var liverail_added:Boolean =false;
		private var inited:Boolean = false;
		private var fsPopup:FullScreenPopup = new FullScreenPopup();
		private var playIcon:FullscreenPlayButton;
		//	End VidCaster edit
        
        public function VideoJS(){
            _stageSizeTimer = new Timer(250);
            _stageSizeTimer.addEventListener(TimerEvent.TIMER, onStageSizeTimerTick);
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        private function init():void{
            // Allow JS calls from other domains
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");

			//	VidCaster edit
			if(inited)return;
			inited = true;
			//	End VidCaster edit

            if(loaderInfo.hasOwnProperty("uncaughtErrorEvents")){
                // we'll want to suppress ANY uncaught debug errors in production (for the sake of ux)
                // IEventDispatcher(loaderInfo["uncaughtErrorEvents"]).addEventListener("uncaughtError", onUncaughtError);
            }
            
            if(ExternalInterface.available){
                registerExternalMethods();
            }
            
            _app = new VideoJSApp();
            addChild(_app);

            _app.model.stageRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);

            // add content-menu version info
            var _ctxVersion:ContextMenuItem = new ContextMenuItem("VideoJS Flash Component v3.0.1", false, false);
            var _ctxAbout:ContextMenuItem = new ContextMenuItem("Copyright © 2012 Zencoder, Inc.", false, false);
            var _ctxMenu:ContextMenu = new ContextMenu();
            _ctxMenu.hideBuiltInItems();
            _ctxMenu.customItems.push(_ctxVersion, _ctxAbout);
            this.contextMenu = _ctxMenu;

			//	VidCaster edit
			if(!liverail_added)addLiveRail();
			this.addEventListener(MouseEvent.CLICK, stageClick);
			//	End VidCaster edit

		}

		

		//	VidCaster edit
		private function addLiveRail():void{
			//After we have added liverail then we can check _liverail.liverail_exists any time we need to know if it's activated or not.
			_liverail = new LiveRailView(_app.model);
			addChild(_liverail);
			
			liverail_added = true;
			
		}
		
		private function showFsPopup():void{
			if(_liverail.liverail_exists && !_liverail.prerollFinished)return;
			addChild(fsPopup);
			if(!playIcon)playIcon = new FullscreenPlayButton();
		}
		private function stageClick(e : MouseEvent) : void {
			if(stage.displayState == "fullScreen"){ //WHEN GOING FULLSCREEN
				if(this.contains(fsPopup)){ //Popup is still there when we just went to fullscreen. This will happen initially
					if(_app.model.paused)addChild(playIcon); //Check if we're paused. in this case we gotta add the big play icon
				}else{ //When we'rea already fullscreen for some time (over 200ms), then this code will execute upon stage click
					if(!_app.model.paused){
						addChild(playIcon);
						onPauseCalled();
					}else{
						if(playIcon && this.contains(playIcon))removeChild(playIcon);
						onResumeCalled();
					}
				
					
				}
			}
		}
		//	End VidCaster edit
        
        private function registerExternalMethods():void{
            
            try{
                ExternalInterface.addCallback("vjs_echo", onEchoCalled);
                ExternalInterface.addCallback("vjs_getProperty", onGetPropertyCalled);
                ExternalInterface.addCallback("vjs_setProperty", onSetPropertyCalled);
                ExternalInterface.addCallback("vjs_autoplay", onAutoplayCalled);
                ExternalInterface.addCallback("vjs_src", onSrcCalled);
                ExternalInterface.addCallback("vjs_load", onLoadCalled);
                ExternalInterface.addCallback("vjs_play", onPlayCalled);
                ExternalInterface.addCallback("vjs_pause", onPauseCalled);
                ExternalInterface.addCallback("vjs_resume", onResumeCalled);
                ExternalInterface.addCallback("vjs_stop", onStopCalled);
				ExternalInterface.addCallback("vjs_fullscreen", showFsPopup);
            }
            catch(e:SecurityError){
                if (loaderInfo.parameters.debug != undefined && loaderInfo.parameters.debug == "true") {
                    throw new SecurityError(e.message);
                }
            }
            catch(e:Error){
                if (loaderInfo.parameters.debug != undefined && loaderInfo.parameters.debug == "true") {
                    throw new Error(e.message);
                }
            }
            finally{}
            
            
            
            setTimeout(finish, 50);

        }
        
        private function finish():void{
            
            if(loaderInfo.parameters.mode != undefined){
                _app.model.mode = loaderInfo.parameters.mode;
            }
            
            if(loaderInfo.parameters.eventProxyFunction != undefined){
                _app.model.jsEventProxyName = loaderInfo.parameters.eventProxyFunction;
            }
            
            if(loaderInfo.parameters.errorEventProxyFunction != undefined){
                _app.model.jsErrorEventProxyName = loaderInfo.parameters.errorEventProxyFunction;
            }
            
            if(loaderInfo.parameters.autoplay != undefined && loaderInfo.parameters.autoplay == "true"){
                _app.model.autoplay = true;
            }
            
            if(loaderInfo.parameters.preload != undefined && loaderInfo.parameters.preload == "true"){
                _app.model.preload = true;
            }
            
            if(loaderInfo.parameters.poster != undefined && loaderInfo.parameters.poster != ""){
                _app.model.poster = String(loaderInfo.parameters.poster);
            }
            
            if(loaderInfo.parameters.src != undefined && loaderInfo.parameters.src != ""){
                _app.model.srcFromFlashvars = String(loaderInfo.parameters.src);
            }
            else{
                if(loaderInfo.parameters.RTMPConnection != undefined && loaderInfo.parameters.RTMPConnection != ""){
                    _app.model.rtmpConnectionURL = loaderInfo.parameters.RTMPConnection;
                }
                if(loaderInfo.parameters.RTMPStream != undefined && loaderInfo.parameters.RTMPStream != ""){
                    _app.model.rtmpStream = loaderInfo.parameters.rtmpStream;
                }
            }
            
            if(loaderInfo.parameters.readyFunction != undefined){
                try{
                    ExternalInterface.call(loaderInfo.parameters.readyFunction, ExternalInterface.objectID);
                }
                catch(e:Error){
                    if (loaderInfo.parameters.debug != undefined && loaderInfo.parameters.debug == "true") {
                        throw new Error(e.message);
                    }
                }
            }

			//	VidCaster edit
			if(_app.model.autoplay){
				
				onPlayCalled();
			}
			//	End VidCaster edit
        }
        
        private function onAddedToStage(e:Event):void{
            stage.addEventListener(Event.RESIZE, onStageResize);
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            _stageSizeTimer.start();
			//	VidCaster edit
			init();
			//	End VidCaster edit
        }

        private function onStageSizeTimerTick(e:TimerEvent = null):void{
            if(stage.stageWidth > 0 && stage.stageHeight > 0){
                _stageSizeTimer.stop();
                _stageSizeTimer.removeEventListener(TimerEvent.TIMER, onStageSizeTimerTick);

            }
        }
        
        private function onStageResize(e:Event):void{
            if(_app != null){
                _app.model.stageRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
                _app.model.broadcastEvent(new VideoJSEvent(VideoJSEvent.STAGE_RESIZE, {}));
            }
        }
        
        private function onEchoCalled(pResponse:* = null):*{
            return pResponse;
        }
        
        private function onGetPropertyCalled(pPropertyName:String = ""):*{

            switch(pPropertyName){
                case "mode":
                    return _app.model.mode;
                case "autoplay":
                    return _app.model.autoplay;
                case "loop":
                    return _app.model.loop;
                case "preload":
                    return _app.model.preload;    
                    break;
                case "metadata":
                    return _app.model.metadata;
                    break;
                case "duration":
                    return _app.model.duration;
                    break;
                case "eventProxyFunction":
                    return _app.model.jsEventProxyName;
                    break;
                case "errorEventProxyFunction":
                    return _app.model.jsErrorEventProxyName;
                    break;
                case "currentSrc":
                    return _app.model.src;
                    break;
                case "currentTime":
                    return _app.model.time;
                    break;
                case "time":
                    return _app.model.time;
                    break;
                case "initialTime":
                    return 0;
                    break;
                case "defaultPlaybackRate":
                    return 1;
                    break;
                case "ended":
                    return _app.model.hasEnded;
                    break;
                case "volume":
                    return _app.model.volume;
                    break;
                case "muted":
                    return _app.model.muted;
                    break;
                case "paused":
                    return _app.model.paused;
                    break;
                case "seeking":
                    return _app.model.seeking;
                    break;
                case "networkState":
                    return _app.model.networkState;
                    break;
                case "readyState":
                    return _app.model.readyState;
                    break;
                case "buffered":
                    return _app.model.buffered;
                    break;
                case "bufferedBytesStart":
                    return 0;
                    break;
                case "bufferedBytesEnd":
                    return _app.model.bufferedBytesEnd;
                    break;
                case "bytesTotal":
                    return _app.model.bytesTotal;
                    break;
                case "videoWidth":
                    return _app.model.videoWidth;
                    break;
                case "videoHeight":
                    return _app.model.videoHeight;
                    break;
            }
            return null;
        }
        
        private function onSetPropertyCalled(pPropertyName:String = "", pValue:* = null):void{

            switch(pPropertyName){
                case "mode":
                    _app.model.mode = String(pValue);
                    break;
                case "loop":
                    _app.model.loop = _app.model.humanToBoolean(pValue);
                    break;
                case "background":
                    _app.model.backgroundColor = _app.model.hexToNumber(String(pValue));
                    _app.model.backgroundAlpha = 1;
                    break;
                case "eventProxyFunction":
                    _app.model.jsEventProxyName = String(pValue);
                    break;
                case "errorEventProxyFunction":
                    _app.model.jsErrorEventProxyName = String(pValue);
                    break;
                case "preload":
                    _app.model.preload = _app.model.humanToBoolean(pValue);
                    break;
                case "poster":
                    _app.model.poster = String(pValue);
                    break;
                case "src":
                    _app.model.src = String(pValue);
                    break;
                case "currentTime":
                    _app.model.seekBySeconds(Number(pValue));
                    break;
                case "currentPercent":
                    _app.model.seekByPercent(Number(pValue));
                    break;
                case "muted":
                    _app.model.muted = _app.model.humanToBoolean(pValue);
                    break;
                case "volume":
                    _app.model.volume = Number(pValue);
                    break;
                case "RTMPConnection":
                    _app.model.rtmpConnectionURL = String(pValue);
                    break;
                case "RTMPStream":
                    _app.model.rtmpStream = String(pValue);
                    break;
                default:
                    _app.model.broadcastErrorEventExternally(ExternalErrorEventName.PROPERTY_NOT_FOUND, pPropertyName);
                    break;
            }
			//	VidCaster edit
			if(_liverail.liverail_exists)_liverail.setProperty(pPropertyName,pValue);
			//	End VidCaster edit
        }
        
        private function onAutoplayCalled(pAutoplay:* = false):void{
            _app.model.autoplay = _app.model.humanToBoolean(pAutoplay);
        }
        
        private function onSrcCalled(pSrc:* = ""):void{
			trace(' ------ VideoJS.onSrcCalled:  ------');
            _app.model.src = String(pSrc);
        }
        
        private function onLoadCalled():void{
            _app.model.load();
        }
        
        private function onPlayCalled():void{
			trace(' ------ VideoJS.onPlayCalled:  ------');
			//	VidCaster edit
			if(_liverail.liverail_exists && !_liverail.prerollFinished){
				setChildIndex(_liverail,numChildren-1);
				_liverail.userAction("play");
				return;
			}
			//	End VidCaster edit
            _app.model.play();
			//	VidCaster edit
			_app.model.resume();
			//	End VidCaster edit
			
        }
        
        private function onPauseCalled():void{
			//	VidCaster edit
			if(_liverail.liverail_exists)_liverail.userAction("pause");
			//	End VidCaster edit
            _app.model.pause();
        }
        
        private function onResumeCalled():void{
			//	VidCaster edit
			if(_liverail.liverail_exists)_liverail.userAction("resume");
			//	End VidCaster edit
            _app.model.resume();
        }
        
        private function onStopCalled():void{
			//	VidCaster edit
			if(_liverail.liverail_exists)_liverail.userAction("stop");
			//	End VidCaster edit
            _app.model.stop();
        }
        
        private function onUncaughtError(e:Event):void{
            e.preventDefault();
        }
        
    }
}
