package com.LiveRail {
	import flash.external.ExternalInterface;
	import com.videojs.structs.ExternalEventName;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.system.Security;
	import com.videojs.VideoJSModel;
	import flash.geom.Rectangle;
	import flash.display.Sprite;

	/**
	 * @author Tanel Teemusk
	 * http://teemusk.com
	 */
	 
	 
	public class LiveRailView extends Sprite {
		//VIDEOJS VARS
		public var _model:VideoJSModel;
		
		public var liverail_exists:Boolean = false;
		//LIVERAIL VARS
		private var prerollState : Boolean;
		private var postrollState : Boolean;
		private var loader : Loader;
		private var adManager : Object = null;
		private var adManager_inited:Boolean = false;
		public var this_inited:Boolean = false;
		public var prerollFinished:Boolean = false;
		private var publisher_id:String;// = "1331";
		
		private var playhead_update_time:Number = 100;
		private var update_time_timeout:Number;
		
		public function LiveRailView(model:VideoJSModel) {
			_model = model;
			this.addEventListener(Event.ADDED_TO_STAGE, added,false,0,true);
		}
		private function added(e:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, added);
			//Check if we have liverail variables
			for(var attr : String in loaderInfo.parameters){
				var attrUP : String = attr.toUpperCase();
				trace(attrUP);
				if(attrUP == "LR_PUBLISHER_ID"){
					
					liverail_exists = true;
					_model.have_liverail = liverail_exists;
					//if(loaderInfo.parameters[attr] == "" || !loaderInfo.parameters[attr])liverail_exists=false;
					break;
				}	
			}
			if(!liverail_exists)return; //If we don't have liverail flashvars then we do not initialize liverail
			stage.addEventListener(Event.RESIZE, resizeLiveRailAdManager,false,0,true);
		}
		

		//********************************************
		//************* INITIALIZE *******************
		//********************************************
		public function init():void{ //THIS IS CALLED FROM DOCUMENT CLASS, AND WILL INITIALIZE THE WHOLE PROCESS
			if(this_inited)return; //don't let us init liverail twice
			this_inited = true;
			loadLiveRailAdManager();
		}
		private function loadLiveRailAdManager() : void {
			Security.allowDomain("*");
			var admanagerURL : String = "http://vox-static.liverail.com/swf/v4/admanager.swf";
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLiveRailLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLiveRailLoadError);
			loader.load(new URLRequest(admanagerURL));
			addChild(loader);
		}
		//INITIALIZATION LISTENERS
		private function onLiveRailLoadError(event : IOErrorEvent) : void {
			trace(' ------ ERROR LOADING LIVERAIL:  ------');
			onLiveRailPrerollComplete(new Object());
		}
		private function onLiveRailLoadComplete(event : Event) : void {
			initLiveRailAdManager();
		}
		private function initLiveRailAdManager() : void {

			adManager = loader.content; 
			adManager.addEventListener("initComplete", onLiveRailInitComplete);
			adManager.addEventListener("initError", onLiveRailInitError);
			adManager.addEventListener("prerollComplete", onLiveRailPrerollComplete);
			adManager.addEventListener("postrollComplete", onLiveRailPostrollComplete);
			adManager.addEventListener("adStart", onLiveRailAdStart);
			adManager.addEventListener("adEnd", onLiveRailAdEnd);
			adManager.addEventListener("adProgress", onLiveRailAdProgress);
			adManager.addEventListener("overlayAdStart", onLiveRailOverlayAdStart);
			adManager.addEventListener("overlayAdEnd", onLiveRailOverlayAdEnd);
			adManager.addEventListener("overlayAdMinimize", onLiveRailOverlayAdMinimize);
			adManager.addEventListener("overlayAdMaximize", onLiveRailOverlayAdMaximize);
			adManager.addEventListener("clickThru", onLiveRailClickThru);	
			adManager.addEventListener("adProgress",onLiveRailProgress);
			requestAds();
		}
		private function requestAds() : void {
			//Let's set these in case they won't be in flashvars
			var config : Object = new Object();
			config["LR_PUBLISHER_ID"] = publisher_id;
			config["LR_VIDEO_ID"] = "video-id-1"; 
			config["LR_TITLE"] = "My Video Title";
			config["LR_DESCRIPTION"] = "My Video Description"; 
			config["LR_TAGS"] = "video_tag, demo";
			config["LR_ADMAP"] = "in::0;ov::2,50%;ov::50%,100%"; 
			config["LR_LAYOUT_SKIN_ID"] = "1";
			config["LR_LAYOUT_SKIN_MESSAGE"] = "Advertisement: Video will resume in {COUNTDOWN} seconds.";

			for(var attr : String in loaderInfo.parameters){
				var attrUP : String = attr.toUpperCase();
				if(attrUP.substr(0,3) == "LR_"){
					config[attrUP] = loaderInfo.parameters[attr];
				}	
			}
			adManager.initAds(config);			
		}
		
		
		//********************************************
		//************* USER ACTIONS *****************
		//********************************************
		//Javascript callbacks. received from document class
		public function setProperty(propname:String,val:*=null):void{
			trace("PROPERTY CHANGE "+propname+" = "+val);
			if(!adManager_inited){
				trace("SKIPPING PROPERTY CHANGE AS adManager is not inited yet.");
				return;
			}
			switch(propname){
					case "loop":
						//_app.model.loop = _app.model.humanToBoolean(pValue);
					case "background":
						//_app.model.backgroundColor = _app.model.hexToNumber(String(pValue));
						break;
					case "eventProxyFunction":
						//_app.model.jsEventProxyName = String(pValue);
						break;
					case "errorEventProxyFunction":
						//_app.model.jsErrorEventProxyName = String(pValue);
						break;
					case "preload":
						//_app.model.preload = _app.model.humanToBoolean(pValue);
						break;
					case "poster":
						//_app.model.poster = String(pValue);
						break;
					case "src":
						//_app.model.src = String(pValue);
						break;
					case "currentTime":
						//_app.model.seekBySeconds(Number(pValue));
						break;
					case "currentPercent":
						//_app.model.seekByPercent(Number(pValue));
						break;
					case "muted":
					case "volume":
						adManager.setVolume(_model.volume,_model.muted);
						break;
	                case "RTMPConnection":
	                    //_app.model.rtmpConnectionURL = String(pValue);
	                    break;
	                case "RTMPStream":
	                    //_app.model.rtmpStream = String(pValue);
	                    break;
					default:
						trace("RailView got a property that it cannot handle: "+propname+ " = "+val);
						break;
				}
		}
	
		//user action on player controls
		public function userAction(s:String):void{
			trace("User Action in lr "+s);
			if(!prerollFinished){
					if(!this_inited){
						init();
						return;
					}
				}
			if(!adManager_inited)return;
			switch(s){
				case "play":
				case "resume": 
					adManager.resumeAd();
				break;
				case "pause": 
					adManager.pauseAd(); 
				break;
	
				default:
					trace("LIVERAIL CAN NOT UNDERSTAND USER ACTION: "+s);
				break;
			
			}
		}
		
		
		
		//********************************************
		//************* HELPERS **********************
		//********************************************
		private function onLiveRailProgress(e:Object):void{
			//trace("Liverail progress "+e.data.time); //THIS WORKS. Probably should tell it to javascript as well to update playhead
		}
		private function updateVideoTime() : void {
			clearTimeout(update_time_timeout);
			if(adManager == null)return;
			update_time_timeout = setTimeout(updateVideoTime,playhead_update_time);
			
			if(_model.metadata==null)return;
			if(!_model.metadata.duration)return;
			adManager.onContentUpdate(_model.time, _model.metadata.duration);
		}
		
		//********************************************
		//************* LiveRail Listeners ***********
		//********************************************
		private function resizeLiveRailAdManager(e:Event = null) : void {
			if(!adManager_inited)return; //disable this if ad manager is not inited, as resize might happen before we have loaded LiveRail swf.
			if(adManager == null) return; // if stage is resized, but the admanager is not loaded yet, we need to ignore the resize method call
			// this is the video area + control bar height
			var takeoverArea : Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);// + PLAYER_CONTROL_HEIGHT);
			// video area where the overlays are rendered
			var videoArea : Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			// scale can be set to 1.5 or 2 when entering fullscreen.
			var scale : Number = 1;
			adManager.setSize(videoArea, takeoverArea, scale);
		}
		private function onLiveRailInitComplete(ev : Object) : void {
			adManager_inited = true;
			setProperty("volume");
			resizeLiveRailAdManager();
			prerollState = true;
			adManager.onContentStart();	
			_model.broadcastEventExternally(ExternalEventName.ON_START);
		}
		private function onLiveRailInitError(ev : Object) : void {
			trace(ev);
			onLiveRailPrerollComplete(new Object());
			//player.visible = true;
		}
		private function onLiveRailPrerollComplete(ev : Object) : void {
			prerollState = false;
			prerollFinished = true;
			_model.play();
			update_time_timeout = setTimeout(updateVideoTime,playhead_update_time);
			//var resumeContent : Boolean = ev.data.resume;		
			//if(resumeContent){
				//PLAYER PLAY
			//}			
		}
		private function onLiveRailPostrollComplete(ev : Object) : void {
			trace(ev);
			postrollState = false;	
		}
		private function onLiveRailAdStart(ev : Object) : void {
			_model.broadcastEventExternally(ExternalEventName.ON_RESUME);
			_model.broadcastEventExternally(ExternalEventName.ON_START);	
			ExternalInterface.call("function() { VideoJS.addClass(VideoJS('vid').el, 'ad-playing') }");
		}

		/**
		 *  Ad ends. Resume main video
		 */
		private function onLiveRailAdEnd(ev : Object) : void {
			ExternalInterface.call("function() { VideoJS.removeClass(VideoJS('vid').el, 'ad-playing') }");	
			clearTimeout(update_time_timeout);
			if(prerollState || postrollState){
			}else{			
				var resumeContent : Boolean = ev.data.resume;		
				//PLAYER PLAY
			}				
		}
		private function onLiveRailAdProgress(ev : Object) : void {
//			trace(ev);
//			var ad : Object = ev.data.ad;
//			var adDuration : Number = ev.data.duration;
//			var adProgress : Number = ev.data.time;			
		}
		private function onLiveRailOverlayAdStart(ev : Object) : void {
			trace(ev);
			// var ad : Object = ev.data.ad;
		}
		private function onLiveRailOverlayAdEnd(ev : Object) : void {
			trace(ev);
			// var ad : Object = ev.data.ad;			
		}
		private function onLiveRailOverlayAdMaximize(ev : Object) : void {
			trace(ev);
			// var ad : Object = ev.data.ad;
			// here subtitles can be moved to the top of the video area so that they don't overlap with the ad 
		}	 
		private function onLiveRailOverlayAdMinimize(ev : Object) : void {
			trace(ev);
			// var ad : Object = ev.data.ad;
			// subtitles can be moved back to their original position
		}
		private function onLiveRailClickThru(ev : Object) : void {
			trace(ev);
			//player.pause();
		}
		
	//END
	}
}
