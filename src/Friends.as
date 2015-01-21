package  
{
	import api.ExternalApi;
	import api.VKApi;
	import astar.AStarNodeVO;
	import com.google.analytics.API;
	import core.Log;
	import core.Post;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import units.Field;
	import units.Guest;
	import units.Hero;
	import units.Personage;
	import units.Treasure;
	import units.Unit;
	import wins.RewardWindow;
	import wins.SimpleWindow;
	import wins.WindowEvent;
	public class Friends
	{
		public var bragFriends:Array = [];
		
		public var data:Object;
		public var keys:Array = [];
		
		public function Friends(friends:Object, emptyIDs:Array = null)
		{
			data = friends;
			var bear:Object = { };
			for each(var item:Object in data) {
				if(item.uid != "1"){
					keys.push( { uid:item.uid, level:item.level } );
				}else {
					item.first_name = Locale.__e('flash:1382952379733');//'Хранитель'
					bear = { uid:item.uid, level:item.level };
				}
				if (App.time <= item.gift) Gifts.takedFreeGift.push(item.uid);
			}
			keys.sortOn("level", Array.NUMERIC | Array.DESCENDING);
			//keys.unshift(bear);
			
			/*if (App.social == 'VK' && ExternalInterface.available) {
				new VKApi(App.self.flashVars, {
					appFriends:App.network.appFriends,
					otherFriends:App.network.otherFriends
					}, 
				function(data:Object):void { });
			}*/
			if (App.social == 'YB') {				
				var emptyIDs:Array = [];
				for(var fID:String in data) {
					if (App.network.appFriends.indexOf(fID) == -1) {
						if (fID == '1') continue;
						emptyIDs.push(fID);
					}
				}
				
				ExternalApi.getUsersProfile(emptyIDs, function(response:Object):void {				
					for (var fID:String in response) {
						if (data[fID] != undefined) {
							for (var p:String in response[fID]) {
								data[fID][p] = response[fID][p];
							}
						}
					}
					if (App.ui != null && App.ui.bottomPanel != null) {
						App.ui.bottomPanel.friendsPanel.searchFriends();
					}
				});
			}
		}
		
		public function showHelpedFriends():void {
			var helpersCount:int =  App.data.options['MaxHelpers'] || 10;
			
			for each(var item:Object in data)
			{
				if (helpersCount > 0 && item['helped'] != undefined && item.helped > 0) {
					helpersCount--;
					installHelpedFriend(item);
				}
			}
		}
		
		public function checkOnLoad():Boolean {
			if (data[keys[keys.length - 1].uid].hasOwnProperty('first_name'))
				return true;
			return false;
		}
		
		public function installHelpedFriend(friend:Object):void {
			return;
			var tries:int = 100;
			//Делаем не больше 100 попыток найти свободное место
			while(tries>0){
				var randX:int = 10 + Math.random() * 30;
				var randZ:int = 10 + Math.random() * 30;
				var node:AStarNodeVO = App.map._aStarNodes[randX][randZ];
				
				if (node.b == 0 && node.p == 0) {
					new Guest(friend, {sid:Personage.HERO,x:randX,z:randZ});
					return;
				}
				tries--;
			}
		}
		
		public function get count():uint {
			var i:int = 0;
			for (var item:* in data) {
				i++;
			}
			return i;
		}
		
		public function uid(uid:String):Object {
			return data[uid];
		}
		
		public var showAttention:Boolean = true;
		public var paidEnergy:Boolean = false;
		public function takeGuestEnergy(uid:String):Boolean {
			paidEnergy = false;
			if (energyLimit <= 0) {
				
				if(App.user.stock.count(Stock.GUESTFANTASY)<=0 && showAttention){
			new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						title:Locale.__e("flash:1382952379725"),
						text:Locale.__e("flash:1382952379734")
					}).show();
					
					showAttention = false;
				}
				
				if(App.user.stock.take(Stock.GUESTFANTASY, 1)){
					paidEnergy = true;
					return true;
				}
				
				return false;
			}
			
			if (data[uid]['energy'] > 0 && data[uid]['energy'] < 6) {
				data[uid]['energy']--;
				if (data[uid]['fill'] == undefined || data[uid]['fill'] == 0) {
					data[uid]['fill'] = App.midnight + 24 * 3600;
				}
				App.ui.leftPanel.showGuestEnergy();
				
				return true;
			}else {
				
				if(App.user.stock.take(Stock.GUESTFANTASY, 1)){
					paidEnergy = true;
					return true;
				}
				
			}
			
			return false;
		}
		
		public function giveGuestBonus(uid:String):void {
			if (data[uid]['energy'] == 0 && !paidEnergy) {
				
				//data[uid]['energy'] = -1;
				App.user.onStopEvent();
				
				Post.send( {
					ctr:'user',
					act:'guest',
					uID:App.user.id,
					fID:uid
				}, onGuestBonusEvent, { uid:uid } );
				
				App.ui.bottomPanel.bttnMainHome.showGlowing();
			}
		}
		
		private function onGuestBonusEvent(error:*, result:*, params:Object):void {
			
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (!error && result) {
				
				if (!result.hasOwnProperty('guestBonus')) 
					return;
				
				/*if(result.bonusType == 'Treasure'){
					
					var freeNodes:Array = [];
					var radius:int = 5;
					//Берем N клеток вверх-влево и вверх-вправо если они заняты, 
					for (var z:int = -radius; z < radius; z++ ) {
						for (var x:int = -radius; x < radius; x++ ) {
							
							if (x == 0 || z == 0) continue;
							
							var newX:int = (App.user.hero.coords.x - x) > 3?(App.user.hero.coords.x - x):3;
							var newZ:int = (App.user.hero.coords.z - z) > 3?(App.user.hero.coords.z - z):3;
							
							newZ = newZ > Map.rows-3?Map.cells-3:newZ;
							newX = newX > Map.cells-3?Map.rows-3:newX;
							
							var node:AStarNodeVO = App.map._aStarNodes[newX][newZ]; 
							
							if(node.object){
								
								//if (node.object is _Field && node.object['plant'] != null) {
									//node.object['plant'].alpha = 0.3;
								//}else {
									node.object.alpha = 0.3;
								//}
							}
							
							if (node.isWall != true) {
								freeNodes.push(node);
							}
						}
					}
					var point:Object = { x:App.user.hero.coords.x+1, z:App.user.hero.coords.z+1 };
					if (freeNodes.length > 0) {
						var i:int = int(Math.random() * freeNodes.length);
						point.x = freeNodes[i].position.x;
						point.z = freeNodes[i].position.y;
						
						for (z = -radius; z < radius; z++ ) {
							for (x = -radius; x < radius; x++ ) {
								
								if (x == 0 || z == 0) continue;
								
								newX = (point.x - x) > 0?(point.x - x):0;
								newZ = (point.z - z) > 0?(point.z - z):0;
								
								newZ = newZ > Map.rows-3?Map.cells-3:newZ;
								newX = newX > Map.cells-3?Map.rows-3:newX;
								
								node = App.map._aStarNodes[newX][newZ]; 
								
								if(node.object){
									
									//if (node.object is _Field){
										//if(node.object['plant'] != null) {
											//node.object['plant'].alpha = 0.3;
										//}
									//}else {
										node.object.alpha = 0.3;
									//}
								}
							}
						}
					}
					
					var unit:* = new Treasure( point );
					Unit.sorting(unit);
					
					var window:SimpleWindow = new SimpleWindow( {
						label:SimpleWindow.TREASURE,
						title:Locale.__e("flash:1382952379735"),
						text:Locale.__e("flash:1382952379736"),
						buttonText:Locale.__e("flash:1382952379737")
						
					});
					window.params = result;
					window.params['unit'] = unit;
					window.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAddTargetEvent);
					window.show();
				}else {*/
					var bonus:Object = {};
					for (var sID:* in result.guestBonus) {
						var item:Object = result.guestBonus[sID];
						for(var count:* in item)
						bonus[sID] = count * item[count];
					}
					
					App.user.stock.addAll(bonus);
					
					new RewardWindow( { bonus:bonus} ).show();
				//}
			}
			else
			{
				Errors.show(error, data);
			}
			
		}
		
		private function onAddTargetEvent(e:WindowEvent):void {
			e.target.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onAddTargetEvent);
			var result:Object = e.target.params;
			
			Treasures.bonus(result.guestBonus, new Point(result.unit.x, result.unit.y));
			
			/*
			App.user.hero.addTarget( {
				target:result.unit,
				callback:function():void {
					Treasures.bonus(result.guestBonus, new Point(result.unit.x, result.unit.y));
					result.unit.uninstall();
					result = null;
				},
				event:Hero.HARVEST,
				jobPosition: { x: 0, y: -2},
				freeEnergy:true
			});
			*/
		}
		
		public function addGuestEnergy(uid:String):void {
			if (data[uid]['energy'] > 0 && data[uid]['energy'] < 6) {
				data[uid]['energy']++;
				App.ui.leftPanel.showGuestEnergy();
			}else {
				data[uid]['energy'] = 1;
				App.ui.leftPanel.showGuestEnergy();
			}
		}
		
		public function updateOne(uid:String, field:String, value:*):void {
			if (data[uid]) {
				data[uid][field] = value;
			}
		}
		
		public function get energyLimit():int {
			var limit:int = App.data.options['VisitLimit'] || 100;
			
			for each(var item:Object in data) {
				limit -= 5 - (item.energy > 0?item.energy:0);
			}
			
			if (limit <= 0) {
				for each(item in data) {
					item.energy = 0;
				}
			}
			return limit;
		}
	}

}