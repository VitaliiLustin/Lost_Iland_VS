package ui 
{
	import buttons.ContextBttn;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.adobe.protocols.dict.events.MatchStrategiesEvent;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import units.Animal;
	import units.AnimationItem;
	import units.Bear;
	import units.Factory;
	import units.Field;
	import units.Mining;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class CloudsMenu extends LayerX 
	{
		public var settings:Object = {
			scaleIcon:0.42
			};
		public var target:*;
		
		private var onEvent:Function;
		
		public var iconBttn:ImagesButton;
		
		public var sID:int;
		
		//public var nameBtmData:String;
		
		public var progressContainer:Sprite = new Sprite();
		public var slider:Sprite = new Sprite();
		
		protected var underBtmData:BitmapData;
		
		private var checkStock:Boolean = false;
		
		public var isBttnOff:Boolean = false;
		
		public function CloudsMenu(onEvent:Function, target:*, sID:int, settings:Object = null)// , _scaleIcon:Number = 0.42, _parentClose:Function = null, _dellOnClick:Boolean = false, _checkStock:Boolean = false) 
		{
			if (settings != null) {
				for (var obj:* in settings) {
					if(settings[obj] != null)
						this.settings[obj] = settings[obj];
				}
			}
			
			this.target = target;
			this.onEvent = onEvent;
			this.sID = sID;
			
			if (sID != 2 && !this.settings.scaleIcon)
			{
				settings.scaleIcon = 0.6;
			};
			
			//nameBtmData = 'productBacking2';
			//addEnergy();
		}
		
		private function addEnergy():void {
			var aime:AnimationItem = new AnimationItem();
			addChild(aime);
			aime.scaleX = aime.scaleY = 8;
		}
	
		private var icon_dY:int = -3;
		public function create(nameBtmData:String):void
		{
			if (nameBtmData == 'productBacking')
				icon_dY	= -6;
				
			underBtmData = Window.textures[nameBtmData];
			addProgressBar();
			
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoadIcon);
		}
		
		public function addProgressBar():void
		{
			var bgProgress:Bitmap = new Bitmap(Window.textures.productionProgressBarBacking);
			progressContainer.addChild(bgProgress);
			bgProgress.x = 0; bgProgress.y = 0;       // обратить внимание на то, что у живнотных значительно выше чем у зданий, найти причину
			progressContainer.addChild(slider);
			slider.x = 4; slider.y = 2;
			
			addChild(progressContainer);
			progressContainer.visible = false;
		}
		
		public function onLoadIcon(obj:Object):void 
		{
			if (isDispose) return;
			
			iconBttn = new ImagesButton( underBtmData, obj.bitmapData, { 
					description		:"Облачко",
					params			:{ }
				}, settings.scaleIcon);
				
			iconBttn.name = 'iconMenu';
			iconBttn.iconBmp.y += icon_dY;
			iconBttn.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			
			if (settings.scaleBttn){
				iconBttn.bitmap.scaleX = iconBttn.bitmap.scaleY = settings.scaleBttn;
				iconBttn.iconBmp.x = (iconBttn.bitmap.width - iconBttn.iconBmp.width) / 2;
				iconBttn.iconBmp.y = 3;
			}
			
			if (stopedProgress) {
				doIconEff();
			}
			
			addChild(iconBttn);
			
			if (settings.offIcon)
				iconBttn.visible = false
			
			progressContainer.x = iconBttn.x  - 10;
			progressContainer.y = iconBttn.y + iconBttn.height + 3;
		}
		
		public function changeUnderBitmapData(nameBtmData:String, isOff:Boolean):void
		{
			isBttnOff = isOff;
			underBtmData = Window.textures[nameBtmData];
			if (iconBttn) {
				iconBttn.bitmap.bitmapData = underBtmData;
			}
		}
		
		public var startTime:int;
		public var endTime:int;
		protected var isProgress:Boolean = false;
		protected var stopedProgress:Boolean = false;
		public function setProgress(_startTime:int, _endTime:int):void
		{
			startTime = _startTime;
			endTime = _endTime;
			App.self.setOnTimer(progress);
			progressContainer.visible = true;
			isProgress = true;
			if (iconBttn)
				iconBttn.buttonMode = iconBttn.mouseEnabled = false;
		}
		
		public function stopProgress():void
		{
			App.self.setOffTimer(progress);
			if (!progressContainer)
				return;
			isProgress = false;
			stopedProgress = true;
			progressContainer.visible = false;
			if (iconBttn) 
				iconBttn.buttonMode = iconBttn.mouseEnabled = true;
			doIconEff();
		}
		
		private var isEff:Boolean = false;
		public function doIconEff():void
		{
			if(iconBttn)
				iconBttn.visible = true;
				
			if (settings.offIcon)
				settings.offIcon = false;
			
			var _scale:Number = 0.7;
			var _effScale:Number = 0.7;
			if (target is Field){
				_scale = 0.5;
				_effScale = 0.6;
			}
			if (target is Animal){
				_scale = 0.5;
				_effScale = 0.6;
			}
			
			if (sID == Stock.COINS) {
				_scale = 0.5;
			}
			
			if (settings.scaleIcon)
				_scale = settings.scaleIcon;
				
			if (settings.scaleDone)
				_scale = settings.scaleDone;
			
			if (iconBttn && !isEff) {
				isEff = true;
				addGlow(Window.textures.iconEff, 0, _effScale);
				iconBttn.iconScale = _scale;
				iconBttn.bitmap.visible = false;
			}
		}
		
		private var container:Sprite = new Sprite();
		public function addGlow(bmd:BitmapData, layer:int, scale:Number = 1):void
		{
			var btm:Bitmap = new Bitmap(bmd);
			container = new Sprite();
			container.addChild(btm);
			btm.scaleX = btm.scaleY = scale;
			btm.smoothing = true;
			btm.x = -btm.width / 2;
			btm.y = -btm.height / 2;
			
			addChildAt(container, layer);
			
			isEff = true;
			container.mouseChildren = false;
			container.mouseEnabled = false;
			
			container.x = iconBttn.x +iconBttn.width / 2;
			container.y = iconBttn.y +iconBttn.height / 2;
			
			App.self.setOnEnterFrame(rotateBtm);
			this.startGlowing();
			
			var that:* = this;
			startInterval = setInterval(function():void {
				clearInterval(startInterval);
				interval = setInterval(function():void {
					that.pluck();
				}, 10000);
			}, int(Math.random() * 3000));
		}
		
		private var interval:int = 0;
		private var startInterval:int = 0;
		
		private function rotateBtm(e:Event):void 
		{
			container.rotation += 1;
		}
		
		protected function progress():void 
		{
			var totalTime:int = endTime-startTime;
			var curTime:int = endTime - App.time;
			var timeForSlider:int = totalTime - curTime;
			
			if (timeForSlider < 0) timeForSlider = 0;
			
			UserInterface.slider(slider, timeForSlider, totalTime, "productionProgressBar", true);
			if (timeForSlider >= totalTime) {
				stopProgress();
			}
		}
		
		public function onClick(e:MouseEvent):void
		{
			if (App.user.quests.tutorial) {
				if (App.user.quests.currentTarget == target) {
					target.click();
					App.tutorial.hide();
					target.hideGlowing();
				}
				return;
			}
				
			if (onEvent != null && !target.ordered) {
				onEvent(target.id);
			}
		}
		
		public function show():void
		{
			target.addChild(this);
		}
		
		private var isDispose:Boolean = false;
		public function dispose():void
		{
			if (isEff) {
				App.self.setOffEnterFrame(rotateBtm);
				isEff = false;
			}
			
			clearInterval(interval);
			clearInterval(startInterval);
			
			isDispose = true;
			if (iconBttn){
				iconBttn.removeEventListener(MouseEvent.MOUSE_DOWN, onClick);
				iconBttn.dispose();
				iconBttn = null;
			}
			
			App.self.setOffTimer(progress);
			
			if (slider && slider.parent && slider.parent.contains(slider)) slider.parent.removeChild(slider);
			slider = null;
			underBtmData = null;
			
			if(progressContainer && contains(progressContainer))removeChild(progressContainer);
				progressContainer = null;
			
			onEvent = null;
			
			//if(target && target.contains(this))target.removeChild(this);
			if (this && this.parent) this.parent.removeChild(this);
			target = null;
			
		}
	}
}