package units 
{
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import wins.CollectorFWindow;
	import wins.FurryWindow;
	import wins.MoneyHouseWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Moneyhouse extends Building
	{
		public static var waitForTarget:Boolean = false;
		public static var collector:Collector = null;
		
		public var countOfFriends:int = 1;
		public var friends:Object = { };
		
		public var furry:Techno;
		
		public var canCollector:Boolean = false;
		
		public var colector:Collector;
		
		public var isConcierge:Boolean = false;
		public var concierge:FakeWorkerUnit;
		
		private var dataObj:Object;
		
		public function Moneyhouse(object:Object) 
		{
			super(object);
			
			friends = object.friends;
			
			for (var fr:* in friends) {
				countOfFriends++;
			}
			
			if (object.hasOwnProperty('hire') && object.hire != 0) {
				concierge = new FakeWorkerUnit( { target:this, sid:FakeWorkerUnit.CONCIERGE, id:id} );
				isConcierge = true;
			}
		}
		
		public function resetStart(started:int):void
		{
			//crafted = started + App.data.storage[sid].devel.req[level].t;
			
			App.self.setOffTimer(production);
			beginCraft(0, crafted);
			
			if (_cloud) {
				_cloud.dispose();
				_cloud = null;
			}
		}
		
		override public function click():Boolean {
			//if (!super.click()) return false;	
			
			//if (furry) {
				//App.map.focusedOnCenter(furry, true);
				//return true;
			//}
			
			//if (furry && furry.collecterBonus)
				//return true;
			
			if (Moneyhouse.waitForTarget && canCollector) {
				waitForTarget = false;
				//new FurryWindow({
					//title:info.title,
					//info:info,
					//mode:FurryWindow.RESOURCE,
					//target:this
				//}).show();
				
				new CollectorFWindow({
					title:info.title,
					info:info,
					//mode:FurryWindow.COLLECTOR,
					target:this
				}).show();
				
				ordered = false;
				return true;
			}
			
			if (!super.click()) return false;	
			
			return false;
		}
		
		override public function checkOnAnimationInit():void {
			if (level > 0) {
				initAnimation();
				beginAnimation();
			}	
			if (crafted == 0) {
				finishAnimation();
			}
			
			if (_cloud) setCloudCoords();
		}
		
		private var count:int = 0;
		public function showCloud():void
		{
			cloudResource(true, Stock.COINS, isProduct, 'productBacking2', null, true, (crafted - info.devel.req[level].tm), crafted);
		}
		
		override public function initProduction(object:Object):void {
			if (level >= totalLevels - craftLevels && object.crafted > 0)
				beginCraft(object.fID, object.crafted);
		}
		
		override protected function beginCraft(fID:uint, crafted:uint):void
		{
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			
			App.self.setOnTimer(production);
			production();
			
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
		
		override public function onBoostEvent(count:int = 0):void {
			if (!App.user.stock.take(Stock.FANT, count)) return;
				
				var that:Building = this;
			
				App.self.setOffTimer(production);
				onProductionComplete();
				fireTechno(1);
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (!error && data) {
						
						App.ui.flashGlowing(that);
						
						if (furry) {
							beginCraft(0, App.time + info.devel.req[level].tm);
							furry.setMoneyDone();
							return;
						}
						
						crafted = data.crafted;
						
						if (_cloud)
							_cloud.stopProgress();
						
						var minusFant:int = App.user.stock.count(Stock.FANT) - data[Stock.FANT];
						var price:Object = { }
						price[Stock.FANT] = minusFant;
						
						if (!App.user.stock.takeAll(price))	return;
						
						if (furry) {
							colector.doSync(furry.id, onSync);
						}
					}
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		private function onSync(data:*):void 
		{
			if (data == false)
				return;
			
			friends = data.house.friends;
		}
		
		override public function onProductionComplete():void
		{
			if (furry) {
				beginCraft(0, App.time + info.devel.req[level].tm);
				
				setTimeout(function():void{
				if(colector && furry){
					colector.doSync(furry.id, onSync); 
					furry.setMoneyDone(); 
				}
				}, 1000);
				//furry.setMoneyDone();
				friends = { };
				return;
			}
			
			crafting = false;
			//crafted = 0;
			
			if (level > totalLevels - craftLevels) {
				hasProduct = true;
				showCloud();
			}
			if(_cloud)
				_cloud.stopProgress();
		}
		
		override public function isProduct(value:int = 0):Boolean
		{
			if (hasProduct && !furry)
			{
				storageEvent();
				
				return true; 
			}
			return false;
		}
		
		override public function storageEvent(value:int = 0):void
		{	
			haloEffect(0xFFFF00, this.parent);
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fID:fID
			}, onStorageEvent);			
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			//for (var fid:* in App.user.friends.data) {
				//if (App.user.friends.data[fid].settle) App.user.friends.data[fid].settle = 0;
			//}
			
			hasProduct = false;
			crafting = true;
			
			fID = 0;
			
			crafted = info.devel.req[level].tm + App.time;
			beginCraft(fID, crafted);
			if (textures && textures.hasOwnProperty('animation')){
				beginAnimation();
			}
			
			friends = { };
			friends = data.friends;
			
			countOfFriends = 1;
			for (var key:* in friends) {
				countOfFriends++;
			}
			
			//showCloud();
			
			var that:* = this;
			
			var bonus:Object = { };
			bonus[Stock.COINS] = info.devel.open[level][Stock.COINS];
			
			bonus[Stock.COINS] *= countOfFriends;
			
			Treasures.bonus(Treasures.convert(bonus), new Point(that.x, that.y));
			//
			if (data.bonus) {
				Treasures.bonus(data.bonus, new Point(that.x, that.y));
			}
			
			if (_cloud)_cloud.dispose();
			_cloud = null;
			flag = false;
			
			countOfFriends = 1;
		}
		
		public function hireConcierge():void
		{
			for (var key:* in App.data.storage[sid].require) {
				break;
			}
			
			if (!App.user.stock.take(key, App.data.storage[sid].require[key]))
				return;
			
			Post.send({
				ctr:type,
				act:'hire',
				uID:App.user.id,
				id:id,
				wID:App.user.worldID,
				sID:sid
			}, onHireConcierge);
		}
		
		private function onHireConcierge(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			concierge = new FakeWorkerUnit( { target:this, sid:FakeWorkerUnit.CONCIERGE, id:id} );
			isConcierge = true;
			
			friends = data.friends;
			isConcierge = true;
		}
		
		//override protected function production():void
		//{
			//if (progress) {
				//if (textures)
				//{
					//finishAnimation();
				//}
				//App.self.setOffTimer(production);
				//beginCraft();
			//}
		//}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			super.onBonusEvent(error, data, params);
			
			crafted = info.devel.req[level].tm + App.time;
			
			if (data.hasOwnProperty('friends'))
				friends = data.friends;
			
			if(level > totalLevels - craftLevels)
				beginCraft(fID, crafted);
				
			if (textures && textures.hasOwnProperty('animation')){
				beginAnimation();
			}
		}
		
		override public function upgradeEvent(params:Object, fast:int = 0):void {
			
			super.upgradeEvent(params, fast);
			App.self.setOffTimer(production);
			crafting = false;
			crafted = 0;
			finishAnimation();
			if (_cloud)_cloud.dispose();
			_cloud = null;
		}
		
		override public function finishAnimation():void
		{
			super.finishAnimation();
			clearAnimation();
		}
		
		override public function beginAnimation():void
		{
			super.beginAnimation();
			for (var _name:String in multipleAnime) {
				bitmapContainer.addChild(multipleAnime[_name].bitmap);
			}
		}
		
		override public function openProductionWindow():void {
			// Открываем окно продукции
			var canBoost:Boolean = true;
			if (furry)
				canBoost = false;
			new MoneyHouseWindow( {
				title:			info.title,
				crafting:		info.devel.craft,
				target:			this,
				onCraftAction:	onCraftAction,
				info:info,
				canBoost:canBoost
			}).show();
		}
		
		override public function uninstall():void
		{
			if (concierge) {
				concierge.uninstall();
				concierge = null;
			}
			
			super.uninstall();
		}
		
		//override public function setCraftLevels():void
		//{
			//if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('obj')) {
				//for each(var obj:* in info.devel.obj) {
					//craftLevels++;
				//}
			//}
		//}
	}
}