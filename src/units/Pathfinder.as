package units 
{
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import ui.CloudsMenu;
	import wins.CollectionWindow;
	import wins.SpeedWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Pathfinder extends WorkerUnit
	{
		public var finished:int;
		
		public var opened:Object;
		
		public var isWork:Boolean = false;
		public var hasProduct:Boolean = false;
		
		private var findSid:int = 0;
		
		public function Pathfinder(object:Object) 
		{	
			super(object);
			
			opened = App.data.storage[sid].targets;
			
			for (var key:* in object.opened) {
				opened[key] = object.opened[key];
			}
			
			findSid = object.find;
			finished = object.finished;
			
			if (finished > 0) {
				App.self.setOnTimer(working);
			}else if (findSid != 0) {
				workDone();
			}
			
			removable = false;
			moveable = true;
			
			info['area'] = {w:1, h:1};
			cells = rows = 1;
			velocities = [0.1];
			
			tip = function():Object {
				
				if (finished > App.time) {
					return {
						title:info.title,
						text:Locale.__e('flash:1393581955601') + ' ' + TimeConverter.timeToStr(finished - App.time),
						timer:true
					}
				}
				
				return {
					title:info.title,
					text:info.description
				}
			}
		}
		
		override public function click():Boolean
		{
			if (hasProduct) {
				storage();
				return true;
			}
			
			if (isWork) {
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:finished,
					totalTime:App.data.storage[sid].time,
					doBoost:boost,
					btmdIconType:App.data.storage[sid].type,
					btmdIcon:App.data.storage[sid].preview
				}).show();
			}else{
				new CollectionWindow( {opened:opened, target:this, mode:CollectionWindow.PATHFINDER } ).show();
			}
			return true;
		}
		
		public function work(mid:int):void
		{
			findSid = mid;
			
			Post.send({
				ctr:type,
				act:'work',
				uID:App.user.id,
				id:id,
				wID:App.user.worldID,
				sID:sid,
				mID:mid
			}, onWork);
		}
		
		private function onWork(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				findSid = 0;
				return;
			}
			finished = data.finished;
			isWork = true;
			
			App.self.setOnTimer(working);
		}
		
		public function openEvent(cid:int):void
		{
			Post.send({
				ctr:type,
				act:'open',
				uID:App.user.id,
				id:id,
				wID:App.user.worldID,
				sID:sid,
				cID:cid
			}, onOpenEvent);
		}
		
		private function onOpenEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
		}
		
		public function boost(price:int = 0):void
		{
			if (!App.user.stock.check(Stock.FANT, price)) return;
			
			Post.send({
				ctr:type,
				act:'boost',
				uID:App.user.id,
				id:id,
				wID:App.user.worldID,
				sID:sid
			}, onBoost);
		}
		
		private function onBoost(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			workDone();
		}
		
		public function storage(value:int = 0):void
		{
			Post.send({
				ctr:type,
				act:'storage',
				uID:App.user.id,
				id:id,
				wID:App.user.worldID,
				sID:sid
			}, onStorage);
		}
		
		private function onStorage(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			var bonus:Object = { };
			bonus[findSid] = 1;
			Treasures.bonus(Treasures.convert(bonus), new Point(this.x, this.y));
			
			
			if (_cloud)
				_cloud.dispose();
			_cloud = null;
			
			isWork = false;
			hasProduct = false;
			findSid = 0;
			finished = 0;
		}
		
		private function working():void
		{
			if (finished <= App.time) {
				workDone();
			}
		}
		
		private function workDone():void 
		{
			App.self.setOffTimer(working);
			hasProduct = true;
			isWork = false;
			finished = 0;
			cloudResource(true, findSid, storage);
		}
		
		private var _cloud:CloudsMenu;
		public function cloudResource(flag:Boolean, sid:int, callBack:Function, btm:String = 'productBacking2', scaleIcon:*=null, isStartProgress:Boolean = false, start:int = 0, end:int = 0, offIcon:Boolean = false):void
		{
			if (_cloud)
				_cloud.dispose();
			
			_cloud = null;
			
			if (App.user.mode == User.GUEST)
				return;
				
			if (flag)
			{
				_cloud = new CloudsMenu(callBack, this, sid, {offIcon:offIcon, scaleIcon:scaleIcon } );
				_cloud.create(btm);
				_cloud.show();
				
				_cloud.x = -30;
				_cloud.y = -150;
				
				if (rotate) {
					_cloud.scaleX = -_cloud.scaleX;
				}
			}
		}
		
	}

}