package com.teemusk {
	import flash.geom.ColorTransform;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;

	/**
	 * @author tanelteemusk
	 */
	public class FullscreenPlayButton extends Sprite {
		private var container:Sprite;
		private var icon:IconPlayBig;
		private var bg:PopupBg;
		public function FullscreenPlayButton() {
			container = new Sprite();
			bg = new PopupBg();
			container.addChild(bg);
			icon = new IconPlayBig();
			icon.x = 40;
			icon.y = 30;
			container.addChild(icon);
			bg.width = icon.width+80;
			bg.height = icon.height+60;
			
			container.buttonMode = true;
			container.mouseChildren = false;
			container.addEventListener(MouseEvent.ROLL_OVER, btnRoll);
			container.addEventListener(MouseEvent.ROLL_OUT, btnOut);
			addChild(container);
			addEventListener(Event.ADDED_TO_STAGE, added);
			addEventListener(Event.REMOVED_FROM_STAGE, removed);
		}

		

		private function added(e : Event) : void {
			stage.addEventListener(Event.RESIZE, resize);
			resize();
		}
		private function removed(e : Event) : void {
			stage.removeEventListener(Event.RESIZE, resize);
		}
		private function resize(e : Event = null) : void {
			trace("------ FullscreenPlayButton.as - resize ------");
			if(stage.displayState == "fullScreen"){
			container.x = Math.round(stage.stageWidth/2-container.width/2);
			container.y = Math.round(stage.stageHeight/2-container.height/2);
			}else{ 
				this.parent.removeChild(this);
			}
		}
		
		
		
		private function btnOut(e : MouseEvent) : void {
			var colorTransform:ColorTransform = new ColorTransform();
			icon.transform.colorTransform = colorTransform;
		}

		private function btnRoll(e : MouseEvent) : void {
			var colorTransform:ColorTransform = icon.transform.colorTransform;
			colorTransform.color = 0xFFFFFF;
			icon.transform.colorTransform = colorTransform;
		}
		
		
		//END
	}
}
