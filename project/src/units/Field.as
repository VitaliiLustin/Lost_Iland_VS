package units 
{
	import api.com.adobe.json.JSONToken;
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.google.analytics.utils.Timespan;
	import core.Load;
	import core.Log;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ui.Cloud;
	import ui.ContextMenu;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import wins.ConstructWindow;
	import wins.ProductionFieldWindow;
	//import wins.FieldProductionWindow;
	import wins.ItemsWindow;
	import wins.PlantationWindow;
	import wins.PlantProgressWindow;
	import wins.ProductionWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import com.greensock.TweenLite;
	import wins.SimpleWindow;
	import wins.SpeedWindow;
	import wins.Window;
	import wins.WindowEvent;
	
	public class Field extends Building 
	{
		public static var exists:Boolean = false;
		public static var boost:int = 0;
		
		public var nearest:Array = [];
		
		public static const DIG:uint 	= 0;
		public static const UNDIG:uint 	= 1;
		
		public var status:uint = DIG;
		public var plant:Plant = null;
		
		public var pID:uint = 0;
		private var craftedCont:Sprite;
		private var frontBitmap:Bitmap = new Bitmap();
		private var plantContainer:LayerX = new LayerX();
		
		public function Field(object:Object)
		{
			object['fID'] = object.pID;
			
			pID = object.pID;
			
			super(object);
			
			plantContainer.mouseChildren = plantContainer.mouseEnabled = false;
			bitmapContainer.addChildAt(plantContainer, 1);
			bitmapContainer.addChildAt(frontBitmap, 2);
			
			if (App.user.mode == User.GUEST) {
				flag = false;
				if(sid == 159)
					setFlag(Cloud.EFIR, guestClick );
				else
					setFlag(Cloud.TRIBUTE, guestClick );
					
				startAnimation();
			}
			init();
		}
		
		override public function initProduction(object:Object):void {
			if (level >= totalLevels - craftLevels && object.crafted > 0)
				beginCraft(object.fID, object.crafted);
		}		
		
		//override public function build():void {
			//updateProgress(created - info.devel.req[level+1].t, created);
			//if (isBuilded()){
				//App.self.setOffTimer(build);
				//if (App.user.mode != User.GUEST) {
					//setFlag("hand", isPresent, { target:this, roundBg:true, addGlow:true } );
					//if(sid != 159)
						//cloud.y -= 40;
				//}
				//hasPresent = true;
				//moveable = true;
				//updateLevel();
				//fireTechno(1);
				//removeProgress();
				//hasUpgraded = true;
				//onBuildComplete();
			//}
		//}
		
		private function init():void 
		{
			//setCloudPosition(-300, -400);
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void 
		{
			super.updateLevel(checkRotate);
			
			if(this.level > 0)
				frontBitmap.visible = true;
		}
		
		override public function onLoad(data:*):void
		{
			super.onLoad(data);
			//setCloudPosition(0, 125);
			if (textures.sprites[3] != null) {
				var front:Object = textures.sprites[3];
				frontBitmap.x = front.dx;
				frontBitmap.y = front.dy;
				frontBitmap.bitmapData = front.bmp;
				
				if (this.level == 0)
					frontBitmap.visible = false;
			}
		}
		
		override public function click():Boolean {
				
			if (this.id == 0) {
				spit(function():void{}, craftedCont);
				return false;
			}
			
			if (__hasPointing) {
				hidePointing();
			}
			
			super.click();
			
			return true;
		}
		
		override public function isProduct(value:int = 0):Boolean
		{
			if (hasProduct)
			{
				for (var _id:* in App.data.storage[pID].outs) {
					break;
				}
				var takeObj:Object = { };
				takeObj[_id] = App.data.storage[pID].outs[_id];
				if (_id == Stock.FANTASY) {
					if (!App.user.stock.canTakeEfir(App.data.storage[pID].outs[_id]))
						return true;
				}else if (!App.user.stock.canTake(takeObj))
					return true;
				//Отправляем персонажа на сбор
				/*App.user.hero.addTarget( {
					target:this,
					callback:storageEvent,
					event:Personage.HARVEST,
					jobPosition: findJobPosition(),
					shortcut:true
				});*/
				
				storageEvent();
				
				ordered = false;
				
				return true; 
			}
			return false;
		}
		
		override public function openProductionWindow():void {
			
			if (crafting) {
				new PlantProgressWindow({
					title:info.title,
					target:this,
					info:info,
					endTime:crafted,
					pid:pID
				}).show();
			}else if (level >= 1){
				new ProductionFieldWindow( {
					title:			info.title,
					crafting:		info.devel.open,
					target:			this,
					onCraftAction:	onCraftAction,
					hasPaginator:	true,
					hasButtons:		true,
					find:helpTarget//157
				}).focusAndShow();
			}
		}
		
		override public function onCraftAction(pID:uint):void
		{
			var formula:Object = App.data.storage[pID];
			if (!App.user.stock.takeAll(formula.price))
				return;
			
			this.pID = pID;
			beginCraft(pID, App.time + formula.duration);
			startSmoke();
			if (textures.hasOwnProperty('animation')){
				beginAnimation();
			}
			
			//Делаем push в _6e
			//if (App.social == 'FB') {
				//for (var key:* in formula.outs)
					//break;
				//var out:String = App.data.storage[key].view;
				//ExternalApi._6epush([ "_event", { "event": "gain", "item":out } ]);
			//}
		
			Post.send({
				ctr:this.type,
				act:'crafting',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				pID:pID
			}, onCraftEvent);
		}
		
		override protected function onCraftEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				//TODO Отменяем проflash:1382952379993влодство
				return;
			}
			this.crafted = data.crafted;
		}

		override protected function beginCraft(pID:uint, crafted:uint):void
		{id
			this.pID = pID;
			//this.fID = pID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			
			for (var _id:* in App.data.storage[pID].outs)
				break
				
			var scaleIcon:Number = 0.7;
			var offIcon:Boolean = false;
			if (sid == 159) {
				offIcon = true;
				scaleIcon = 0.6;
			}
				
			cloudResource(true, _id, isProduct, 'productBacking2', scaleIcon, true, crafted - App.data.storage[pID].duration, crafted, offIcon);
			
			App.self.setOnTimer(production);
			production();
			
			craftedCont = new Sprite();
			plantContainer.addChild(craftedCont);
			
			Load.loading(Config.getSwf(App.data.storage[pID].type, App.data.storage[pID].view), onSetImageLoad);
			Load.loading(Config.getIcon(App.data.storage[pID].type, App.data.storage[pID].view), onOutLoad);
		}
		
		
		override public function storageEvent(value:int = 0):void
		{
			//if (!App.user.stock.canTakeEfir(App.data.storage[pID].outs[Stock.FANTASY])){
				//ordered = false;
				//return;
			//}		
			
			hasProduct = false;
			crafting = false;
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				pID:pID
			}, onStorageEvent);			
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (/*!App.user.stock.take(Stock.FANT, info.skip)  || */!App.user.stock.take(Stock.FANT, count)) return;
				
				var that:Building = this;
			
				App.self.setOffTimer(production);
				onProductionComplete();
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					pID:pID
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (!error && data) 
					{
						App.ui.flashGlowing(that);
						crafted = data.crafted;
						if (_cloud)_cloud.stopProgress();
						
						var minusFant:int = App.user.stock.count(Stock.FANT) - data[String(Stock.FANT)];
						var price:Object = { }
						price[Stock.FANT] = minusFant;
						
						if (!App.user.stock.takeAll(price))	return;
						//Hints.minus(134, minusFant, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
					}
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		override public function get progress():Boolean {
			
			if (crafted <= App.time)
			{
				onProductionComplete();
				return true;
			}
			
			if(countLabel != null){
				countLabel.text = TimeConverter.timeToStr(crafted - App.time);
			}
			
			return false;
		}
		
		override public function onProductionComplete():void
		{
			//super.onProductionComplete();
			
			if(_cloud)
				_cloud.stopProgress();
			
			hasProduct = true;
			crafting = false;
			crafted = 0;
			
			finishAnimation();
			fireTechno(1);
			
			updatePlant();
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (craftedCont) {
				//stopSwing();
				plantContainer.removeChild(craftedCont);
				craftedCont = null;
			}	
			
			ordered = false;
			
			if (_cloud)_cloud.dispose();
			
			var that:* = this;
		
			Treasures.bonus(Treasures.convert(App.data.storage[pID].outs), new Point(that.x, that.y));
			pID = 0;
		
			plantLevel = 0;	
			crafted = 0;
			hasProduct = false;
			
			flag = false;
		}
		
		public var plant_textures:Object;
		private function onSetImageLoad(data:*):void 
		{
			plant_textures = data;
			drawPlant();
			/*startSwing();*/
		}
		
		override public function setFlag(value:*, callBack:Function = null, settings:Object = null):void {
			
			super.setFlag(value, callBack, settings);
			
			//if (cloud && (sid == 160 || sid == 178) && cloud.y < -63)
				//cloud.y = -63;
				//cloud.x;
		}
		
		override protected function onOutLoad(data:*):void {
			super.onOutLoad(data);
			icon.visible = false;
		}
		
		public function startSwing(random:Boolean = true, getType:Boolean = true):void {
			stopSwing();
			a = 0;
			dda = -1;
			amp = 0.05;
			da = 0.05;
			
			if (random)
				a = int(Math.random() * 360);
				
			App.self.setOnEnterFrame(swinging);
		}
		
		public function stopSwing():void {
			App.self.setOffEnterFrame(swinging);
			a = 0;
			da = 0;
			dda = 0;
			amp = 0;
		}
		
		private var a:Number = 0;
		private var da:Number = 0;
		private var dda:Number = 0;
		private var amp:Number = 0;
		private var plantLevel:uint;
		
		private function swinging(e:Event):void {
			a += da;//2
			if (a >= 360) a -= 360;
			
			if (da > 0)
				da += dda;
			var c:Number = amp * Math.sin(a * Math.PI / 180);//0.025
			var matrix:Matrix = new Matrix();
			matrix.c = c;
			matrix.ty = 40;
			
			plantContainer.transform.matrix = matrix;
		}
		
		override public function onBuildComplete():void {
			if (App.user.quests.tutorial) {
				QuestsRules.onFieldComplete();
				/*setTimeout(function():void {
					
				}, 200);*/
			}
		}
		
		private function updatePlant():void 
		{
			if (!App.data.storage[pID])
				return;
			
			var totalTime:int = App.data.storage[pID].duration;
			var curTime:int = crafted - App.time;
			var timeForSlider:int = totalTime - curTime;
			
			if (timeForSlider < 0) timeForSlider = 0;
			var percent:Number = timeForSlider > totalTime ? 1: timeForSlider / totalTime;
			
			var _plantLevel:int = Math.floor(percent);// * 2);
			if (_plantLevel != plantLevel){
				plantLevel = _plantLevel;
				drawPlant();
			}
		}

		private function drawPlant():void {
			if (plant_textures == null)
				return;
				
			var levelData:Object;
			
			
			levelData = plant_textures.sprites[plantLevel];
			
			if (!levelData) {
				plantLevel = 0;
				levelData = plant_textures.sprites[plantLevel];
			}
			
			createPlants(levelData);
			craftedCont.alpha = 0;
			TweenLite.to(craftedCont, 0.5, { alpha:1 } )
			App.ui.flashGlowing(craftedCont);
		}
		
		private var coordsPlants:Object = { 
			1:{num:2, 1:{x:-55,y:65}, 2:{x:5,y:39} },
			2:{num:1, 1:{x:35,y:38}}
		};
		
		private function createPlants(levelData:Object):void 
		{
			while (craftedCont.numChildren) {
				craftedCont.removeChildAt(0);
			}
			if(sid != 160 && sid != 178)
				bitmapContainer.addChild(plantContainer);
			//plantContainer.addChild(craftedCont);
			
			var coordsData:Object = getCoords();
			for (var i:int = 1; i <= coordsData.num; i++ ) {
				var iconPlant:Bitmap = new Bitmap(levelData.bmp);
				
				iconPlant.x = coordsData[i].x + plant_textures.sprites[plantLevel].dx;
				iconPlant.y = coordsData[i].y + plant_textures.sprites[plantLevel].dy;
				
				craftedCont.addChild(iconPlant);
			}
		}
		
		override public function showPointing(position:String="top", deltaX:int = 0, deltaY:int = 0, container:* = null, text:String = '', textSettings:Object = null, isQuest:Boolean = false):void
		{
			super.showPointing(position, deltaX, deltaY, container, text, textSettings, isQuest);
		}
		
		private function getCoords():Object
		{
			var coordsPlant:Object;
			
			switch(sid) {
				case 160:
				case 178:
					coordsPlant = coordsPlants[1];
				break;
				case 159:
					coordsPlant = coordsPlants[2];
				break;
				default:
					coordsPlant = coordsPlants[1];
			}
			
			return coordsPlant;
		}
		
		override public function setCraftLevels():void
		{
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('craft')) {
				for each(var obj:* in info.devel.craft) {
					craftLevels++;
				}
			}else if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('open')) {
				for each(obj in info.devel.open) {
					craftLevels++;
				}
			}
		}
		
		//override protected function production():void
		//{
			//if (progress) {
				//if (textures)
				//{
					//finishAnimation();
				//}
				//App.self.setOffTimer(production);
			//}
			//updatePlant();
		//}
	}
}
