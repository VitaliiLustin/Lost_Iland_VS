package ui
{
	import api.ExternalApi;
	import buttons.ImageButton;
	import core.IsoConvert;
	import core.Load;
	import core.Log;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import units.Butterfly;
	import units.Resource;
	import units.Unit;
	import units.Whispa;
	
	public class SystemPanel extends Sprite
	{
		public static var scaleMode:uint = 0;
		public static var scaleValue:Number = 1;
		public static var animate:Boolean = true;
		
		public var bttnSystemCont:MenuContainer;
		public var bttnSystemFullscreen:ImageButton;
		public var bttnSystemScreenshot:ImageButton;
		public var bttnSystemSound:ImageButton;
		//public var bttnSystemMusic:ImageButton;
		public var bttnSystemPlus:ImageButton;
		public var bttnSystemMinus:ImageButton;
		public var bttnSystemAnimation:ImageButton;
		
		public static const PANEL_STATE:uint = 0;
		public static const SOUND:uint = 1;
		public static const MUSIC:uint = 2;
		
		public function resize():void {
			const INDENT:int = 63;
			
			this.x = App.self.stage.stageWidth - INDENT;
			this.y = App.ui.upPanel.energySprite.y + App.ui.upPanel.energySprite.height + 1;this.y = App.ui.upPanel.energySprite.y + App.ui.upPanel.energySprite.height + 1;
		}
		
		public static function updateScaleMode():void
		{
			if (scaleValue > 0.83) {
				scaleMode = 0;
			}else if (scaleValue > 0.66) {
				scaleMode = 1;
			}else if (scaleValue > 0.49) {
				scaleMode = 2;
			}else {
				scaleMode = 3;
			}
		}
		
		public static function getSystemCookie(type:uint = 0):String {
			var array:Array = App.user.storageRead('ui', '011').split('');
			return array[type];
		}
		public static function setSystemCookie(type:uint, value:String):void {
			var array:Array = App.user.settings.ui.split('');
			array[type] = value;
			App.user.storageStore('ui', array.join(''));
		}
		
		public function SystemPanel() 
		{
			bttnSystemFullscreen = new ImageButton(UserInterface.textures.systemFullscreen);
			bttnSystemScreenshot = new ImageButton(UserInterface.textures.systemScreenshot);
			bttnSystemSound = new ImageButton(UserInterface.textures.systemSound);
			//bttnSystemMusic = new ImageButton(UserInterface.textures.settingsMusic);
			bttnSystemPlus = new ImageButton(UserInterface.textures.systemPlus);
			bttnSystemPlus.alpha = 0.5;
			bttnSystemMinus = new ImageButton(UserInterface.textures.systemMinus);
			bttnSystemAnimation = new ImageButton(UserInterface.textures.systemAnimate);
			
			bttnSystemFullscreen.tip =  function():Object { return { title:Locale.__e("flash:1382952379807") }; }
			bttnSystemScreenshot.tip =  function():Object { return { title:Locale.__e("flash:1382952379808") }; }
			bttnSystemSound.tip =  function():Object { return { title:Locale.__e("flash:1382952379809") }; }
			//bttnSystemMusic.tip =  function():Object { return { title:Locale.__e("flash:1396250234796") }; }
			bttnSystemPlus.tip =  function():Object { return { title:Locale.__e("flash:1382952379810") }; }
			bttnSystemMinus.tip =  function():Object { return { title:Locale.__e("flash:1382952379811") }; }
			bttnSystemAnimation.tip =  function():Object { return { title:Locale.__e("flash:1382952379812") }; }
			
			var bttns:Array = [
				bttnSystemFullscreen,
				bttnSystemPlus,
				bttnSystemMinus,
				bttnSystemSound,
				//bttnSystemMusic,
				bttnSystemAnimation,
				bttnSystemScreenshot
			];
			
			if (['ML','PL','FB'].indexOf(App.self.flashVars.social) != -1)
			{
				bttns = [
					bttnSystemFullscreen,
					bttnSystemPlus,
					bttnSystemMinus,
					bttnSystemSound,
					//bttnSystemMusic,
					bttnSystemAnimation
				];
			}
			
			bttnSystemCont = new MenuContainer();
			bttnSystemCont.addButtons(bttns);
			addChild(bttnSystemCont);
			bttns = [];
			
			bttnSystemFullscreen.addEventListener(MouseEvent.CLICK, onFullscreenEvent);
			bttnSystemScreenshot.addEventListener(MouseEvent.CLICK, onScreenshotEvent);
			bttnSystemSound.addEventListener(MouseEvent.CLICK, onSoundEvent);
			//bttnSystemMusic.addEventListener(MouseEvent.CLICK, onMusicEvent);
			bttnSystemPlus.addEventListener(MouseEvent.CLICK, onPlusEvent);
			bttnSystemMinus.addEventListener(MouseEvent.CLICK, onMinusEvent);
			bttnSystemAnimation.addEventListener(MouseEvent.CLICK, onAnimateEvent);
			
			ExternalApi.apiNormalScreenEvent();
		}
		
		public function updateScaleBttns():void
		{
			if (scaleValue <= 0.6)
			{
				bttnSystemMinus.alpha = 0.5;
			}else {
				bttnSystemMinus.alpha = 1;
			}
			if (scaleValue >= 0.9)
			{
				bttnSystemPlus.alpha = 0.5;
			}else {
				bttnSystemPlus.alpha = 1;
			}
		}
		
		public function onFullscreenEvent(e:MouseEvent):void {
			if(App.self.stage.displayState != StageDisplayState.NORMAL){
				ExternalApi.apiNormalScreenEvent();
				App.self.stage.displayState = StageDisplayState.NORMAL;
				App.map.center();
				TipsPanel.resize();
			}else {
				App.self.stage.displayState = StageDisplayState.FULL_SCREEN;
				App.map.center();
				//TipsPanel.tipsPanel.visible = false;
				TipsPanel.resize();
			}
		}
		
		private function onScreenshotEvent(e:MouseEvent):void {
			ExternalApi.apiScreenshotEvent();
		}
		
		private function onSoundEvent(e:MouseEvent):void {
			if (SoundsManager.instance.allowSFX) {
				e.currentTarget.alpha = 0.5;
				SoundsManager._instance.setSound(false);
			}else {
				e.currentTarget.alpha = 1;
				SoundsManager._instance.setSound(true);
			}
		}
		//private function onMusicEvent(e:MouseEvent):void {
			//if (SoundsManager.instance.allowSounds) {
				//e.currentTarget.alpha = 0.5;
				//SoundsManager._instance.setMusic(false);
			//}else {
				//e.currentTarget.alpha = 1;
				//SoundsManager._instance.setMusic(true);
			//}
		//}
		
		private function onPlusEvent(e:MouseEvent):void {
			
			if (!App.map.assetZones)
				return;
			
			bttnSystemMinus.alpha = 1;
			
			if (App.map.scaleX <= 0.83)
			{
				scaleMode --;
				scaleValue += 0.17;
				scaleValue = Math.round(scaleValue * 100) / 100;
				App.map.scale = scaleValue;
				
				
				
				//var map_mouse_X:int = App.map.mouseX;
				//var map_mouse_Y:int = App.map.mouseY;
					//
				//var mouse_X:int = App.self.mouseX;
				//var mouse_Y:int = App.self.mouseY;
			//
				//App.map.x =  -map_mouse_X*App.map.scaleX + App.self.stage.stageWidth/2;
				//App.map.y =  -map_mouse_Y * App.map.scaleY;
				if (App.map.scaleX >= 0.9)
				{
					bttnSystemPlus.alpha = 0.5;
				}
				Nature.removeButterfly();
			}else {
				scaleMode = 0;
				scaleValue = 1;
				
				App.map.scale = scaleValue;
			}
		}
		
		private function onAnimateEvent(e:MouseEvent):void {
			animate = !animate;
			var fly:Butterfly;
			var whispa:Whispa;
			if (animate) 
			{
				bttnSystemAnimation.alpha = 1;
				for each(fly in App.map.butterflies)
				{
					fly.visible = true;
				}
				for each(whispa in App.map.whispas)
				{
					whispa.visible = true;
				}
				
			}else{
				bttnSystemAnimation.alpha = 0.5;
				for each(fly in App.map.butterflies)
				{
					fly.visible = false;
				}
				for each(whispa in App.map.whispas)
				{
					whispa.visible = false;
				}
			}
		}
		
		private function onMinusEvent(e:MouseEvent):void {
			
			if (!App.map.assetZones)
				return;
			
			bttnSystemPlus.alpha = 1;
			if (App.map.scaleX >= 0.55)
			{ 	
				scaleMode ++;
				scaleValue -= 0.17;
				scaleValue = Math.round(scaleValue * 100) / 100;
				App.map.scale = scaleValue;
				
				//var map_mouse_X:int = App.map.mSort.mouseX;
				//var map_mouse_Y:int = App.map.mSort.mouseY;
				//
				//var mouse_X:int = App.self.stage.stageWidth / 2;
				//var mouse_Y:int = App.self.stage.stageHeight / 2;
				//
				//App.map.x =  -map_mouse_X *App.map.scaleX - mouse_X;
				//App.map.y =  -map_mouse_Y*App.map.scaleY - mouse_Y;
				
				Nature.addButterfly();
				Nature.addButterfly();
				if (App.map.scaleX <= 0.6)
				{
					bttnSystemMinus.alpha = 0.5;
				}
			}
		}
		
		public function onMouseWheel(e:MouseEvent):void {
			/*if (e.delta > 0) {
				bttnSystemPlus.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}else {
				bttnSystemMinus.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}*/
			centerOnCursor(e.delta)
		}
		
		public function centerOnCursor(delta:int):void 
		{
			if (App.self.stage.displayState == StageDisplayState.NORMAL)
				return;
			
			var map_mouse_X:int = App.map.mSort.mouseX;
			var map_mouse_Y:int = App.map.mSort.mouseY;
			
			if (delta < 0) {
				if (App.map.scaleX >= 0.55) {
					
					App.map.scale = App.map.scaleX - 0.17;
					//App.map.scaleX -= 0.17;
					//App.map.scaleY -= 0.17;
					scaleMode ++;
				}	
			}else {
				if (App.map.scaleX <= 0.83) {
					App.map.scale = App.map.scaleX + 0.17;
					//App.map.scaleX += 0.17;
					//App.map.scaleY += 0.17;
					scaleMode --;
				}
			}
			scaleValue = App.map.scaleX;
			
			var mouse_X:int = App.self.mouseX;
			var mouse_Y:int = App.self.mouseY;
			
			App.map.x =  -map_mouse_X*App.map.scaleX + mouse_X;
			App.map.y =  -map_mouse_Y * App.map.scaleY + mouse_Y;
			
			updateScaleBttns();
		}
	}
}



import buttons.Button;
import buttons.ImageButton;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import ui.UserInterface;
import com.greensock.TweenLite;
import com.greensock.easing.*;
import ui.SystemPanel;

internal class MenuContainer extends LayerX
{
	private var bttnCont:Sprite = new Sprite();
	private var controllBttn:ImageButton;
	private var controllBmp:Bitmap;
	private var bgLeftBmp:Bitmap;
	private var bgCenterBmp:Bitmap;
	private var bgRightBmp:Bitmap;
	private var background:Sprite;
	
	public static const CLOSE:String = "close";
	public static const OPEN:String = "open";
	
	public var state:String = OPEN;
	private var CLOSE_WIDTH:Number = 60;
	private var MASK_HEIGHT:Number = 28;
	private var BTTN_WIDTH:Number = 0;
	private const SYSTEM_ARROW_X:int = 6;
	private const BG_INDENT_X:Number = -2;		// оступ background'a от центра, x
	private const BG_INDENT_Y:Number = -4;		// оступ background'a от центра, y
	private const TIME_OF_MOVE:Number = 0.5;	// время выезжания, сек
	
	public function MenuContainer():void {
		checkCookie();
		drawBody();
	}
	
	private function checkCookie():void {
		if (SystemPanel.getSystemCookie(SystemPanel.PANEL_STATE) == '1'){
			state = OPEN;
		}else{
			state = CLOSE;
		}
	}
	
	private function drawBody():void 
	{
		if (numChildren > 0) {
			if(controllBttn.hasEventListener(MouseEvent.CLICK)) controllBttn.removeEventListener(MouseEvent.CLICK, controllBttnHandler);
			
			while (this.numChildren > 0)
				this.removeChildAt(0);
		}
		
		background = new Sprite();
		background.alpha = 0.8;
		drawBackground();
		
		controllBmp = new Bitmap(UserInterface.textures.systemArrow, 'auto', true);
		controllBttn = new ImageButton(controllBmp.bitmapData);
		
		var bttnBmd:BitmapData = new BitmapData(controllBmp.width, MASK_HEIGHT, true, 0x00000000);
		bttnBmd.draw(controllBmp, new Matrix(1, 0, 0, 1, (bttnBmd.width - controllBmp.width) / 2, (bttnBmd.height - controllBmp.height) / 2));
		
		controllBttn = new ImageButton(bttnBmd);
		controllBttn.x = SYSTEM_ARROW_X;
		controllBttn.y = 2;
		
		
		addChild(background);
		addChild(bttnCont);
		addChild(controllBttn);
		
		controllBttn.addEventListener(MouseEvent.CLICK, controllBttnHandler);
	}
	
	public function addButtons(bttns:Array):void {
		bttns.unshift(controllBttn);
		
		var X:int = controllBttn.x;
		var Y:int = controllBttn.y;
		
		var count:int = 0;
		
		for each(var bttn:ImageButton in bttns)
		{
			bttnCont.addChild(bttn);
			bttn.x = X;
			bttn.y = -Y;
			if (count > 0) bttn.y = Math.floor((MASK_HEIGHT - bttn.height - 4) / 2);
			X += bttn.width + getX();
			
			count ++;
			if (count == 2) {
				BTTN_WIDTH = bttn.width;
				CLOSE_WIDTH = bttnCont.width;
				MASK_HEIGHT = bttnCont.height;
			}
		}
		
		if (state == OPEN) {
			bttnCont.x = CLOSE_WIDTH - bttnCont.width;
		}else {
			bttnCont.x = 0;
		}
		
		function getX():Number {
			switch(count) {
				case 0:
					return 8;
					break;
				case 1:
					return 6;
					break;
			}
			return 4;
		}
		
		redraw();
		endMotion();
	}
	
	private function drawBackground():void {
		bgLeftBmp = new Bitmap(UserInterface.textures.systemBackground);
		//bgRightBmp = new Bitmap(UserInterface.textures.systemBackground);
		
		var bmd:BitmapData = new BitmapData(1, bgLeftBmp.height);
		bmd.copyPixels(bgLeftBmp.bitmapData, new Rectangle(bgLeftBmp.width - 1, 0, bgLeftBmp.width, bgLeftBmp.height), new Point());

		bgCenterBmp = new Bitmap(bmd);
		
		bgLeftBmp.x = BG_INDENT_X;
		bgLeftBmp.y = BG_INDENT_Y;
		bgCenterBmp.x = bgLeftBmp.x + bgLeftBmp.width;
		bgCenterBmp.y = BG_INDENT_Y;
		//bgRightBmp.x = bgLeftBmp.x + bgLeftBmp.width;
		//bgRightBmp.y = BG_INDENT_Y;
		
		background.addChild(bgLeftBmp);
		background.addChild(bgCenterBmp);
		//background.addChild(bgRightBmp);
	}
	
	private function redraw():void {
		
		bgLeftBmp.x = bttnCont.x + BG_INDENT_X;
		bgCenterBmp.x = bgLeftBmp.x + bgLeftBmp.width;
		bgCenterBmp.width =  - bgLeftBmp.x + 1;
	}
	private function beginMotion():void {
		if (state == OPEN) {
			TweenLite.to(bttnCont, TIME_OF_MOVE, {x:CLOSE_WIDTH-bttnCont.width, ease:Back.easeOut, onComplete:endMotion, onUpdate:redraw} );
		}else {
			TweenLite.to(bttnCont, TIME_OF_MOVE, {x:0, ease:Strong.easeOut, onComplete:endMotion, onUpdate:redraw} );
		}
	}
	private function endMotion():void {
		switch(state) {
			case OPEN:
				if (controllBttn.x != SYSTEM_ARROW_X + controllBttn.width) {
					controllBttn.scaleX = -controllBttn.scaleX;
					controllBttn.x = SYSTEM_ARROW_X + controllBttn.width;
				}
				break;
			default:
				if (controllBttn.x != SYSTEM_ARROW_X) {
					controllBttn.scaleX = -controllBttn.scaleX;
					controllBttn.x = SYSTEM_ARROW_X;
				}
				break;
		}
		controllBttn.state = Button.NORMAL;
	}
	
	public function setState(state:String = ""):void {
		switch(state) {
			case OPEN:
				this.state = OPEN;
				break;
			default:
				this.state = CLOSE;
		}
		beginMotion();
		
		if (state == OPEN) {
			SystemPanel.setSystemCookie(SystemPanel.PANEL_STATE, '1');
		} else {
			SystemPanel.setSystemCookie(SystemPanel.PANEL_STATE, '0');
		}
	}
	
	public function changeStateToNext():void {
		var stateList:Array = [CLOSE, OPEN];
		var index:int = stateList.indexOf(state)+1;
		
		if (index == stateList.length) index = 0;
			
		var findedState:String = stateList[index];
		setState(findedState);
	}
	
	// Handlers
	private function controllBttnHandler(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		e.currentTarget.state = Button.DISABLED;
		changeStateToNext();
	}
}