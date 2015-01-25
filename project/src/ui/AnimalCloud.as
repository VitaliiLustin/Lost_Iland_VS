package ui 
{
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import units.Animal;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class AnimalCloud extends CloudsMenu
	{
		public static const MODE_NEED:int = 1;
		public static const MODE_DONE:int = 2;
		public static const MODE_CRAFTING:int = 3;
		public static const MODE_HUNGRY:int = 4;

		private var mode:int;
		
		private var countTxt:TextField;
		
		private var dellOnClick:Boolean = false;
		
		private var countItems:int;
		private var enough:Boolean = false;
		
		public var speedUp:MoneyButton;
		
		private var fID:int;
		
		private var closeInterval:int;
		
		public function AnimalCloud(onEvent:Function, target:*, sID:int, _mode:int, _settings:Object = null) 
		{
			fID = sID;
			mode = _mode;
			
			switch(mode) {
				case MODE_DONE:
					for (var sd:* in App.data.storage[sID].outs) {
						sID = sd;
						break;
					}
				break;
				case MODE_NEED:
					for (var sd2:* in App.data.storage[sID].require) {
						sID = sd2;
						break;
					}
				break;
			}
			super(onEvent, target, sID, _settings);
			
			if (target.type == 'Fplant' && mode == MODE_NEED || mode == MODE_CRAFTING) {
				App.self.addEventListener(AppEvent.ON_MAP_CLICK, onEventClose);
				App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			}
			if (mode == MODE_CRAFTING)
			{
				drawBttn();
				progressContainer.x = -6; // убрать хардкод
				progressContainer.y = 43; //
			}
			

			//settings['timeDelay'] = settings.timeDelay || 4000;
			//if (mode != MODE_DONE) {
				//closeInterval = setInterval(onEventClose, settings.timeDelay);
			//}
		}
		
		private function onChangeStock(e:AppEvent):void {
			drawCount();
		}
		
		private function onEventClose(e:AppEvent = null):void 
		{
			clearInterval(closeInterval);
			pluckDispose();
			
			TweenLite.to(this, 0.5, {alpha:0, onComplete:function():void{if(target && target.cloudAnimal)target.cloudAnimal = null; dispose();}});
			
			//target.cloudAnimal = null;
			//dispose();
		}
		
		override public function create(nameBtmData:String):void
		{
			super.create(nameBtmData);
		}
		
		//public function onMouseUp(e:MouseEvent):void
		//{
			//if ((e.target.parent is CloudsMenu) || (e.target.parent is Animal) || (e.target is Animal) || (e.currentTarget is Animal) || (e.currentTarget is AnimalCloud)){
			//}else {
				//target.cloudAnimal = null;
				//pluckDispose();
				//dispose();
			//}
		//}
		
		override public function onLoadIcon(obj:Object):void 
		{
			if (target == null) return;
			
			if (mode == MODE_HUNGRY) {
				var objHungry:Object = { };
				//objHungry['bitmapData'] = Window.textures.hungryIco;
				settings.scaleIcon = 1;
				super.onLoadIcon(objHungry);
				iconBttn.iconBmp.y -= 8;
			}else{
			
				super.onLoadIcon(obj);
				drawCount();
				if (mode == MODE_DONE)
					doIconEff();
				if (mode == MODE_CRAFTING) {
					iconBttn.visible = false;
					progressContainer.y -= 16;
					speedUp.x = progressContainer.x + (progressContainer.width - speedUp.width)/2 + 4;
					speedUp.y = progressContainer.y - speedUp.height - 3;
				}
			}
		}
		
		private function drawBttn():void 
		{
			speedUp = new MoneyButton( {
				title:'',
				countText:'',
				width:88,
				height:44,
				shadow:true,
				fontCountSize:30,
				fontSize:16,
				type:"green",
				radius:14,
				bgColor:[0xa8f84a, 0x74bc17],
				bevelColor:[0xcdfb97, 0x5f9c11],
				fontBorderColor:0x4d7d0e,
				fontCountBorder:0x40680b,
				iconScale:0.7
			});
			addChild(speedUp);
			speedUp.textLabel.visible = false;
			
			speedUp.coinsIcon.x = 0;
			speedUp.countLabel.x = speedUp.coinsIcon.x + speedUp.coinsIcon.width + 1;
			speedUp.countLabel.y += 1;
			
			speedUp.addEventListener(MouseEvent.CLICK, onAcselereatEvent);
		}
		
		private function onAcselereatEvent(e:MouseEvent):void 
		{
			target.onBoostEvent(priceBttn);
		}
		
		public function drawCount():void
		{
			if (!iconBttn)
				return;
			if (mode == MODE_NEED) {
				
				if (countTxt && contains(countTxt)) 
					removeChild(countTxt);
				countTxt = null;
				
				var count:int;
				for (var out:* in App.data.storage[fID].require) { 
					count = App.data.storage[fID].require[out]
					break;
				}
				var settings:Object = {
					color:0xffffff,
					borderColor:0x1d2740,
					textAlign:"center",
					autoSize:"left",
					fontSize:24
				}
				if (!App.user.stock.checkAll(App.data.storage[fID].require)) {
					settings['color'] = 0xef7563;
					settings['borderColor'] = 0x623126;
				}
				
				countTxt = Window.drawText('x' + String(count), settings);
				countTxt.x = iconBttn.width - countTxt.textWidth - 9;
				countTxt.y = iconBttn.height - countTxt.textHeight - 10;
				addChild(countTxt);
			}
			
			iconBttn.tip = function():Object { return { title:App.data.storage[sID].title, text:App.data.storage[sID].description }; }
			
		}
		
		override public function setProgress(_startTime:int, _endTime:int):void
		{
			if (App.user.mode == User.GUEST)
				return;
			
			super.setProgress(_startTime, _endTime);
			
			priceSpeed = Math.ceil((endTime - App.time) / App.data.options['SpeedUpPrice']);
			speedUp.count = String(priceSpeed);
		}
		
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		override protected function progress():void 
		{
			super.progress();
			
			priceSpeed = Math.ceil((endTime - App.time) / App.data.options['SpeedUpPrice']);
				
			if (speedUp && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				speedUp.count = String(priceSpeed);
			}
		}
		
		override public function stopProgress():void
		{
			super.stopProgress();
			if (speedUp) {
				removeBttn();
			}
		}
		
		private function removeBttn():void 
		{
			speedUp.removeEventListener(MouseEvent.CLICK, onAcselereatEvent);
			speedUp.dispose();
			speedUp = null;
		}
		
		override public function dispose():void
		{
			clearInterval(closeInterval);
			if (mode == MODE_NEED || mode == MODE_CRAFTING) {
				//App.self.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseUp);
				App.self.removeEventListener(AppEvent.ON_MAP_CLICK, onEventClose);
				App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			}
			if (speedUp) {
				removeBttn();
			}
			super.dispose();
			if (countTxt && contains(countTxt)) removeChild(countTxt);
			countTxt = null;
		}
		
		public function getMode():int
		{
			return mode;
		}
		
	}

}