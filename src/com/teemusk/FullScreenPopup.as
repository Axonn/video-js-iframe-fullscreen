package com.teemusk {
	import flash.utils.setTimeout;
	import flash.display.StageDisplayState;
	import flash.geom.ColorTransform;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.display.Sprite;

	/**
	 * @author tanelteemusk
	 */
	public class FullScreenPopup extends Sprite {
		
		private var container:Sprite;
		private var bg:PopupBg;
		private var fsbtn:Sprite;
		private var cancelbtn:Sprite;
		
		public function FullScreenPopup() {
			container = new Sprite();
			bg = new PopupBg();
			container.addChild(bg);
			fsbtn = createButton("EXPAND","FS");
			fsbtn.x = 5;
			fsbtn.y = 10;
			cancelbtn = createButton("CANCEL","CANCEL");
			cancelbtn.x = fsbtn.x+fsbtn.width+5;
			cancelbtn.y = 10;
			container.addChild(fsbtn);
			container.addChild(cancelbtn);
			bg.width = fsbtn.width+10+cancelbtn.width+5;
			bg.height = fsbtn.height+10;
			addChild(container);
			addEventListener(Event.ADDED_TO_STAGE, added);
			}
		
		public function added(e:Event):void{
			this.alpha = 1;
			resize();
			
			stage.addEventListener(Event.RESIZE, resize);
		}
		
		private function resize(e:Event = null):void{
			container.x = Math.round(stage.stageWidth/2-container.width/2);
			container.y = Math.round(stage.stageHeight/2-container.height/2);
		}

		
		private function createButton(txt:String,action:String):Sprite{
			var cont:Sprite = new Sprite();
			var mc:PopupButton = new PopupButton();
			cont.name = action;
			var icn:*;
			if(action == "FS"){
				icn = new IconFs();
			}else{
				icn = new IconCancel();
			}
			cont.addChild(icn);
			cont.addChild(mc);
			mc.txt.htmlText = ""+txt;
			mc.txt.autoSize = TextFieldAutoSize.LEFT;
			if(mc.width > icn.width)icn.x = Math.round(mc.width/2-icn.width/2);
			else{mc.x = Math.round(icn.width/2-mc.width/2);}
			mc.y = 35;
			cont.buttonMode = true;
			cont.mouseChildren = false;
			cont.addEventListener(MouseEvent.ROLL_OVER, btnRoll);
			cont.addEventListener(MouseEvent.ROLL_OUT, btnOut);
			cont.addEventListener(MouseEvent.CLICK, btnClick);
			var dummy:PopupBg = new PopupBg();
			dummy.alpha = 0;
			dummy.width = cont.width;
			dummy.height = cont.height;
			cont.addChild(dummy);
			return cont;
		}

		private function btnClick(e : MouseEvent) : void {
			this.alpha = 0;
			stage.removeEventListener(Event.RESIZE, resize);
			if(e.target.name == "FS")stage.displayState=StageDisplayState.FULL_SCREEN;
			setTimeout(this.parent.removeChild, 200, this);
			
			
			
		}

		private function btnOut(e : MouseEvent) : void {
			var colorTransform:ColorTransform = new ColorTransform();
			e.target.transform.colorTransform = colorTransform;
		}

		private function btnRoll(e : MouseEvent) : void {
			var colorTransform:ColorTransform = e.target.transform.colorTransform;
			colorTransform.color = 0xFFFFFF;
			e.target.transform.colorTransform = colorTransform;
		}
		
		//END
	}
}
