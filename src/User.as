package  
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Debug;
	import core.IsoConvert;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import units.AnimationItem;
	import units.Character;
	import units.Guide;
	import units.Resource;
	import units.Unit;
	import units.Hero;
	import units.Personage;
	import units.WUnit;
	import wins.DialogWindow;
	import wins.FurryWindow;
	import wins.InviteBestFriendWindow;
	import wins.ReferalRewardWindow;
	import wins.ShopWindow;

	public class User extends Sprite
	{
		
		[Embed(source="boat.png")]
		public var boat:Class;
		
		public static const GUEST:Boolean = true;
		public static const OWNER:Boolean = false;
		
		public static const VIEW:Boolean = true;
		
		public static const BOY_BODY:uint 	= 6;
		public static const BOY_HEAD:uint 	= 7;
		
		public static const GIRL_BODY:uint 	= 8;
		public static const GIRL_HEAD:uint 	= 9;
		
		public static const START_WORLD:uint = 196;
		public static const HOME_WORLD:uint = 81;
		public static const HOME_ALIEN_WORLD:uint = 196;
		
		public static const  PRINCE:int = 162;
		public static const  PRINCESS:int = 163;
		
		public static const  HECK:int = 1;
		public static const  TRICK:int = 1;
		public static const  LEA:int = 1;
		public static const  SPARK:int = 1;
		
		public static var checkBoxState:int = 1;
		
		public var id:String = '0'; 
		public var worldID:int = 1; 
		public var aka:String = ""; 
		public var sex:String = "m"; 
		public var first_name:String; 
		public var last_name:String; 
		public var photo:String; 
		public var year:int; 
		public var city:String;
		public var country:String;
		public var level:uint = 1; 
		public var exp:int = 1; 
		public var world:World;
		public var worlds:Object = {};
		public var maps:Object;
		public var friends:Friends;
		public var quests:Quests;
		public var orders:Orders;
		public var stock:Stock = null;
		public var units:Object;
		public var shop:Object = { };
		public var lastvisit:uint = 0;
		public var createtime:uint = 0;
		public var energy:uint = 0;
		public var freebie:Object = null;
		public var presents:Object = {};
		public var restore:int;
		public var promos:Array = [];
		public var promo:Object = { };
		public var oncePromos:Array = [];
		public var onceOfferShow:uint = 0;
		public var premiumPromos:Array = []; 
		public var money:int = 0; 
		public var pay:int = 0;
		public var bestFriends:Object;
		public var bestFriendsInvites:Object;
		public var blinks:Object = {};
		
		public var wishlist:Array = [];
		public var gifts:Array = [];
		public var requests:Array = [];
		public var head:uint = 0;
		public var body:uint = 0;
		public var day:uint = 0;
		public var bonus:uint = 0;
		public var _6wbonus:Object = {};
		public var trialpay:Object = {};
		
		public var personages:Array = [];
		public var characters:Array = [];
		public var techno:Array = [];
		public var animals:Array = [];
		public var mode:Boolean = OWNER;
		public var view:Boolean = false;
		public var trades:Object;
		public var tradeshop:Object;
		private var _settings:String = '';
		public var settings:Object = {ui:"111", f:"0"};
		
		public var ach:Object = { };
		public var socInvitesFrs:Object = {}
		
		public var rooms:Object = {};
		//public var restoredUnits:Object; 
		public var wl:Object;
		
		public var giftsLimit:int;
		
		public var cowboys:Array = [];
		
		public var charactersData:Array = [];
		
		public var ref:String = ""; 
		public var keepers:Object = {
			79:0,
			80:0,
			81:0
		}
		
		public function User(id:String){
			Log.alert('uID: '+id);
			this.id = id;
			
			first_name 	= App.network.profile.first_name || "Name";
			last_name 	= App.network.profile.last_name || "Lastname";
			sex 		= App.network.profile.sex || "m";
			photo		= App.network.profile.photo;
			year		= App.network.profile.year || 0;
			city		= App.network.profile.city || '';
			country		= App.network.profile.country || '';
			
			//sex = 'f';
			
			for (var sID:* in App.data.storage) {
				var item:Object = App.data.storage[sID];
				if (item.type == 'Lands' && item.started) {
					worldID = sID;
					break;
				}
			}
			
			//worldID = 174;
			
			Log.alert('App.network.appFriends');
			Log.alert(App.network.appFriends);
			
			/*if(id == '16714529153308014848'){
				App.network.appFriends = ["1", "1130853760782766616", "11352596833988027906", "11993754624323296048", "13739143726124259035", "13835422367315314653", "15107644907939120236", "15447938121742998636", "15487589328544034164", "17305358035241311485", "18092499925705070008", "3251118508851607375", "3387740679774292172", "4159199956701446074", "4431804378575209825", "5473192020642285239", "6291448507415344", "6641641004535918516", "6835118161565974189", "7046358229587152926", "748581498004218450", "7928262650666195726", "8912092564120063956"];
			}*/
			
			var social:String = App.social;
			if (social == 'DM')
				social = 'VK';
				
			Console.addLoadProgress('App.network.appFriends.length: ' + App.network.appFriends.length);
			
			var postObject:Object = {
				'ctr':'user',
				'act':'state',
				'uID':id,
				'year':year,
				'sex':sex,
				'friends':JSON.stringify(App.network.appFriends),
				'social':social,
				'city':city,
				'country':country
			}
			
			if (id == '1')	
				postObject['wID'] = HOME_ALIEN_WORLD;
			else
				postObject['wID'] = HOME_WORLD;
			
			Post.send(postObject, onLoad);
			//onLoad(0, {}, null);
		}
		
		public static function findWorldId(userID:String):int {
			if (userID == "1")
				return HOME_ALIEN_WORLD;
				
			return HOME_WORLD;
		}
		
		public var arrHeroesInRoom:Array = [];
		
		public function onLoad(error:int, data:Object, params:Object):void {
			
			Console.addLoadProgress("User: onLoad");
			if (error) {
				Errors.show(error, data);
				//Обрабатываем ошибку
				return;
			}
			
			ach = data.ach || {};
			if (!ach) ach = { };
			for (var ac:* in App.data.ach) {
				if (!ach[ac]) {
					ach[ac] = { };
					//ach[ac][1] = 0;
					//ach[ac][2] = 0;
					//ach[ac][3] = 0;
				}
			}
			
			if (data.user && data.user.invite)
				socInvitesFrs = data.user.invite;
			else {									//emulate responce
				data['stock'] = { };
				data['stock']['capacity'] = 100;
				data['user'] = { };
				data['world'] = { };
				data['quests'] = { };
			}
			
			App.ref = data.user['ref'] || "";
			App.ref_link = data.ref_link || "";
			for (var properties:* in data.user)
			{
				if (properties == 'friends') 
					continue;
				if (properties == 'wID') {
					worldID = data.user[properties];
					continue;
				}	
				
				if (properties == 'settings') {
					try{
						_settings = data.user[properties];
						settings = JSON.parse(_settings);
					}catch (e:*) {}
					if (!settings['ui']) settings['ui'] = '111';
					if (!settings['f']) settings['f'] = '0';
					continue;
				}
				
				if(this.hasOwnProperty(properties))
					this[properties] = data.user[properties];
			}
			
			
			if (data.hasOwnProperty('ships'))
				tradeshop = data.ships
				
				
			for each(var wID:* in data.user.worlds) {
				worlds[wID] = wID;
			}
			
			Console.addLoadProgress("User: 1");
			units = data.units;
			stock = new Stock(data.stock);
			if (App.network['friends'] != undefined) {
				for (var _i:* in App.network.friends) {
					var fID:String = App.network.friends[_i].uid;
					if (data.friends[fID] != undefined) {
						for (var key:* in App.network.friends[_i]) {
							Log.alert(App.network.friends[_i][key]);
							data.friends[fID][key] = App.network.friends[_i][key];
						}
					}
				}
			}
			
			for each(var room:* in rooms) 
			{
				if (!room.hasOwnProperty('times')) room['times'] = 0;
				if (!room.hasOwnProperty('drop')) room['drop'] = 0;
				
				for (var hr:* in room.pers) {
					arrHeroesInRoom.push(room.pers[hr]);
				}
			}
			
			//if (!ExternalInterface.available) {
				var networkDefoult:Object = { };
				networkDefoult['1'] = {
					//"uid"           : 151695597,//friend["uid"],
					"uid"           : 9490649,//friend["uid"],
					"first_name"    : 'User',//friend["first_name"],
					"last_name"     : 'Real_user',
					"photo"	        : '',
					"url"  			: "http://vk.com/id" + 159185922,
					"sex"           : 'm',//friend["sex"] == 2 ? "m" : "f",
					"exp"           : 1600
				}
				for (var _j:* in data.friends) {
					var fID2:int = data.friends[_j].uid;
					if (data.friends[fID2] != undefined) {
						for (var key2:* in networkDefoult[1]) {
							if (!data.friends[fID2].hasOwnProperty(key2)) {
								if (key2 == 'photo')
									data.friends[fID2][key2] = Config.getImage('avatars', 'av_' + int(Math.random() * 2 + 1));
								else
									data.friends[fID2][key2] = networkDefoult[1][key2];
							}
						}
					}
				}
			//}
			
			//if (giftsLimit == 0) {
				//giftsLimit = App.data.options.GiftsLimit;
			//}
			
			friends = new Friends(data.friends);
			
			for each(var sID:String in data.user.wl)	wishlist.push(sID);
			
			promo 		= data.promo;
			freebie     = data.freebie;
			presents	= data.presents;
			trades		= data.trades;
			
			if(data.hasOwnProperty('keepers'))
				keepers		= data.keepers;
				
			if (data.user.hasOwnProperty('bestfriends')) {
				if (data.user.bestfriends.hasOwnProperty('friends')) 
				{
					bestFriends	= data.user.bestfriends.friends;
				}
				if (data.user.bestfriends.hasOwnProperty('invites'))
				{
					bestFriendsInvites	= data.user.bestfriends.invites;
				}
			}
				
			Console.addLoadProgress("User: 2");
			for (var gID:String in data.gifts) {
				if (gID == 'limit') {
					giftsLimit = Math.max(App.data.options.GiftsLimit ,data.gifts['limit']);
					continue;
				}
				Gifts.addGift(gID, data.gifts[gID]);
			}
			
			gifts.sortOn("time");
			gifts.reverse();
			
			world = new World(data.world);
			/*world = new World( {
				zones: {
					0:83
				}
			});*/
			quests = new Quests(data.quests);
			orders = new Orders();
			
			//акции
			/*updateActions();
			
			if (head == 0)
			{
				if (sex == 'm')
					head = BOY_HEAD;
				else
					head = GIRL_HEAD;
			}
			
			if (body == 0)
			{
				if (sex == 'm')
					body = BOY_BODY;
				else
					body = GIRL_BODY;
			}*/
			
			//TODO инициализируем зависимые объекты
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_USER_COMPLETE));
			App.self.setOnTimer(totalTimer);
			
			for each(var fr:* in data.friends) {
				if (fr.uid != "1" && fr.exp && fr.exp >= stock.count(Stock.EXP) ) {
					friends.bragFriends.push(fr);
				}
			}
			
			money = 1000000;
		}
		
		//public function updateLimits(limit:int):void
		//{
			//giftsLimit = limit;
		//}
		
		//акции
		
		public var promoFirstParse:Boolean = true;
		public function updateActions():void {
			var actionsArch:Object = storageRead('actions', { } );
			//actionsArch = { };
			if (!App.data.hasOwnProperty('actions')) return;
			//if (quests.chapters.indexOf(2) < 0) return;
			
			// Удалить куки несуществующих акций или акций которые уже не появятся. ОДИН РАЗ ПРИ ЗАПУСКЕ!
			if(promoFirstParse) {
				for (var pID:String in actionsArch) {
					if (!App.data.actions.hasOwnProperty(pID)) {
						delete actionsArch[pID];
					}else{
						var arch:Object = App.data.actions[pID];
						if (arch.type == 0 && (arch.unlock.level && arch.unlock.level < level) && (arch.unlock.quest && quests.data.hasOwnProperty(arch.unlock.quest) && quests.data[arch.unlock.quest].finished > 0)) {
							delete actionsArch[pID];
						}else if (arch.type != 0 && arch.time + arch.duration * 3600 < App.time) {
							delete actionsArch[pID];
						}
					}
				}
			}
			
			promo = {};
			promos = [];
			premiumPromos = [];
			oncePromos = [];
			var promoNormal:Array = [];
			var promoUnique:Array  = [];
			
			for (var arId:* in actionsArch) {
				if (actionsArch[arId] == null)
					actionsArch[arId] = { };
					//delete actionsArch[arId];
			}
			
			for (var aID:String in App.data.actions) {
				var action:Object = App.data.actions[aID];
				var open:Boolean = false;
				
				// Пропустить если купили
				if (actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null && actionsArch[aID].buy) {
					delete actionsArch[aID].time;
					delete actionsArch[aID].prime;
					continue;
				}
				// Нет в социальной сети
				if (!action.price || !action.price.hasOwnProperty(App.social)) continue;
				// Не наступила
				if (App.time < action.time) continue;
				
				action['pID'] = aID;
				action['buy'] = 0;
				if (!action.hasOwnProperty('prime')) action['prime'] = 0;
				
				if (action.type == 0) { // Обычные
					if ((action.unlock.level && level >= action.unlock.level) || (action.unlock.quest && quests.data.hasOwnProperty(action.unlock.quest) && quests.data[action.unlock.quest].finished == 0) || (actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null && actionsArch[aID].time + action.duration * 3600 > App.time)) {
						
						open = true;
						if (!actionsArch.hasOwnProperty(aID)) {
							action.prime = 1;
							actionsArch[aID] = {
								prime:	1,
								buy:	0,
								time:	App.time
							};
						}else {
							if (actionsArch[aID].prime) actionsArch[aID].prime = 0;
							if (actionsArch[aID].time + action.duration * 3600 < App.time) {
								open = false;
							}
						}
						if(open) {
							action['begin_time'] = actionsArch[aID].time;
							promoNormal.push(action);
						}
					}else {
						if (actionsArch.hasOwnProperty(aID)) delete actionsArch[aID];
					}
				}else if (action.type == 1) { // Уникальные
					if (App.time >= action.time && App.time < action.time + action.duration * 3600 && (action.unlock.level && level >= action.unlock.level)) {
						open = true;
						if (!actionsArch.hasOwnProperty(aID)) {
							action.prime = 1;
							actionsArch[aID] = {
								prime:	1,
								buy:	0,
								time:	App.time
							};
						}else {
							if (actionsArch[aID].prime) actionsArch[aID].prime = 0;
						}
						action['begin_time'] = action.time;
						promoUnique.push(action);
					}else {
						if (actionsArch.hasOwnProperty(aID))
							delete actionsArch[aID];
					}
				}else if (action.type == 2) {
					if (App.time >= action.time && App.time < action.time + action.duration * 3600) {
						premiumPromos.push(action);
						if (!actionsArch.hasOwnProperty(aID)) {
							action['first'] = true;
							actionsArch[aID] = {
								shows:	0,
								buy:	0
							};
						}else {
							if (promoFirstParse) actionsArch[aID].shows ++;
						}
						action['shows'] = actionsArch[aID].shows;
						for (var sid:String in action.items) break;
						action['sid'] = sid;
					}
				}else if (action.type == 3) {
					oncePromos.push(action);
				}
				
				if (open) {
					promo[aID] = action;
				}
			}
			
			promoNormal.sortOn('order', Array.DESCENDING);
			promoNormal.sortOn('prime', Array.DESCENDING);
			promoUnique.sortOn('order', Array.DESCENDING);
			promoUnique.sortOn('prime', Array.DESCENDING);
			
			if (promoUnique.length > 0) promos.unshift(promoUnique.shift());
			if (promoNormal.length > 0) promos.push(promoNormal.shift());
			promos = promos.concat(promoUnique);
			promos = promos.concat(promoNormal);
			
			if (promoFirstParse) {
				if (premiumPromos.length > 0) {
					action = premiumPromos[0];
					//App.ui.rightPanel.createPremiumPromo(Boolean(action.first));
					action.first = false;
					if (action.shows < 3) {
						setTimeout(function():void {
							//new PremiumWindow( {pID:action.pID} ).show();
						}, 3000);
					}
				}
				
				if (oncePromos.length > 0) {
					//App.self.addEventListener(AppEvent.ON_STOCK_ACTION, onStockAction);
				}
			}
			
			promoFirstParse = false;
			
			storageStore('actions', actionsArch);
			
		}
		public function buyPromo(pID:String):void {
			var actionsArch:Object = storageRead('actions', {});
			if (!actionsArch.hasOwnProperty(pID)) actionsArch[pID] = {};
			actionsArch[pID]['buy'] = 1;
			if (promo[pID]) {
				promo[pID]['buy'] = 1;
				promos.splice(promos.indexOf(promo[pID]), 1);
			}
			
			storageStore('actions', actionsArch, true);
		}
		public function unprimeAction(pID:String):void {
			var actionsArch:Object = storageRead('actions', {});
			if (actionsArch.hasOwnProperty(pID)) 
				actionsArch[pID]['prime'] = 0;
			promo[pID]['prime'] = 0;
			
			storageStore('actions', actionsArch);
		}
		
		public var aliens:Array = [
			{type: Hero.PRINCE, aka:App.data.storage[162].title, sid:162},
			{type: Hero.PRINCESS, aka:App.data.storage[163].title, sid:163}
		];
		
		public function addPersonag():void 
		{
			if (sex != 'm')
				aliens.reverse();
				
			var position:Object = App.map.heroPosition;
			var positions:Array = findNewPositions(position.x, position.z, aliens.length);
			for (var i:int = 0; i < aliens.length; i++) {
				if (App.user.mode == User.GUEST || arrHeroesInRoom.indexOf(aliens[i].sid) == -1)
					personages.push(new Hero(this, { id:Personage.HERO, sid:aliens[i].sid, x:positions[i].x, z:positions[i].z, alien:aliens[i].type, aka:aliens[i].aka } ));
			}
			
			if(personages.length>0)
				personages[personages.length - 1].beginLive();
			
			for each(var _hero:Hero in personages) {
				Unit.sorting(_hero);
			}
			
			App.ui.upPanel.update();
			//startIntro();
		}
		
		public var boatBitmap:Bitmap;
		public var persLocked:Boolean = false;
		public var intro:AnimationItem;
		public var intro2:AnimationItem;
		
		public function startIntro():void {
				
			boatBitmap = new Bitmap(new boat().bitmapData);
			intro = new AnimationItem( { type:'Personage', view:'heroes_intro', framesType:'start1', onLoop:step2, animated:false, touchable:true, onClick:step1 } );
			intro2 = new AnimationItem( { type:'Personage', view:'heroes_intro', framesType:'start', onLoop:step5, animated:false } );
			App.map.addChild(intro);
			App.map.addChild(boatBitmap);
			App.map.addChild(intro2);
			
			boatBitmap.visible = false;
			intro.visible = false;
			intro2.visible = false;
			
			if (sex == 'f')
				personages.reverse();
			
			personages[0].visible = false;
			personages[1].visible = false;
			
			intro.x = 2414 - 5 - 4
			intro.y = 1185 - 12 + 2 ;
			
			boatBitmap.x = 2225 - 8 + 34;
			boatBitmap.y = 1185 - 4 + 120;
			
			intro2.x = 2225+142 - 8;
			intro2.y = 1185+131 - 4 + 4;
			
			intro2.visible = false;
			intro.visible = false;
			boatBitmap.visible = true;
			
			App.map.focusedOn(personages[0], false, null, false);
			Tutorial.watchOn(intro, 'targeting', false, { dx: -30, dy:30, scaleX:1, scaleY:1 } );
			intro.visible = false;
			App.tutorial.arrowVisible = false;
			App.tutorial.circle.visible = false;
			persLocked = true;
			
			if (intro.textures != null)
				showOnHero1();
			else {
				App.ui.addGlobalLoader();
				intro.addEventListener(Event.COMPLETE, showOnHero1);
			}
		}
		
		private var timer:int = 0;
		private function showOnHero1(e:* = null):void {
			
			intro.visible = true;
			
			timer = setTimeout(function():void {
				App.tutorial.arrowVisible = true;
			},1000);
			
			App.ui.removeGlobalLoader();
			App.tutorial.circle.scaleX = 0.2;
			App.tutorial.circle.scaleY = 0.2;
			App.tutorial.circle.visible = true;
				
			TweenLite.to(App.tutorial.circle, 0.3, {
				scaleX:1.2,
				scaleY:1.2
			});
		}
		
		private function step1(e:* = null):void 
		{ 
			if(timer > 0)
				clearTimeout(timer);
				
			intro.startAnimation();
			App.tutorial.hide();
			//setTimeout(intro.startAnimation, 1000);	
		}
		
		private function step2():void {
			personages[0].visible = true;
			personages[0].framesType = 'stop_pause';
			//personages[0].setRest();
			
			intro.dispose();
			App.map.removeChild(intro);
			intro = null;
			
			setTimeout(function():void {
				App.user.quests.unlockFuckAll();
				new DialogWindow( { qID:0, mID:1 } ).show();	
			}, 1000);
			
			//step3();
			//setTimeout(step3, 1000);
		}
		
		public function step3():void {
			App.user.quests.lockFuckAll();
			App.map.focusedOn(personages[1]);
			personages[0].initMove(47, 87, step4);
		}
		
		private function step4():void
		{
			personages[0].stopWalking();
			personages[0].onStop();
			personages[0].visible = false;
			boatBitmap.visible = false;
			intro2.visible = true;
			intro2.startAnimation();
		}
		
		private function step5():void {
			personages[1].visible = true;
			personages[0].visible = true;
			if (sex == 'f')
				personages.reverse();
			
			/*var _x:int = 2408 - 8;
			var _y:int = 1341 - 5;
			var place:Object = IsoConvert.screenToIso(_x, _y, true);
			personages[1].x = _x;
			personages[1].y = _y;
			return;*/
			
			
			intro2.dispose();
			App.map.removeChild(intro2);
			intro2 = null;
			
			quests.unlockFuckAll();
			persLocked = false;
			new DialogWindow( { qID:90, mID:1 } ).show();
			/*setTimeout(function():void {
				
			},1000);*/
		}
		
		public function get hero():Hero {
			for each(var hero:Hero in App.user.personages) {
				if (hero.main)
					return hero;
			}
			return App.user.personages[0];
		}
		
		public function returnHero(sid:uint, position:Object):void {
			if (App.data.storage[sid].type == "Character") {
				for (var i:int = 0; i < charactersData.length; i++) {
					if (sid == charactersData[i].sid) {
						var _character:Character = new Character({id:1, sid:charactersData[i].sid, x:position.x, z:position.z, type:charactersData[i].type});
						_character.cell = position.x;
						_character.row = position.z;
						_character.calcDepth();
						
						var index:int = arrHeroesInRoom.indexOf(sid);
						if (index != -1) arrHeroesInRoom.splice(index, 1);
						break;
					}
				}	
			}else {
				for (i = 0; i < aliens.length; i++) {
					if (sid == aliens[i].sid) {
						var _hero:Hero = new Hero(this, { id:Personage.HERO, sid:aliens[i].sid, x:position.x, z:position.z, alien:aliens[i].type, aka:aliens[i].aka } ); 
						personages.push(_hero);
						_hero.cell = position.x;
						_hero.row = position.z;
						_hero.calcDepth();
						
						index = arrHeroesInRoom.indexOf(sid);
						if (index != -1) arrHeroesInRoom.splice(index, 1);
						break;
					}
				}	
			}
			
			App.ui.upPanel.update();
		}
		
		public function removePersonages():void 
		{
			for each(var _hero:Hero in personages) {
				_hero.uninstall();
				_hero = null;
			}
			personages = [];
			App.ui.upPanel.update();
		}
		
		public function removePersonage(sid:uint):void 
		{
			for (var i:int = 0; i < personages.length; i++ ) {
				var _hero:Hero = personages[i];
				if (_hero.sid == sid) {
					arrHeroesInRoom.push(sid);
					_hero.stopAnimation();
					_hero.uninstall();
					_hero = null;
					personages.splice(i, 1);
					i--;
				}
			}
			for ( i = 0; i < characters.length; i++ ) {
				var _character:Character = characters[i];
				if (_character.sid == sid) {
					if(arrHeroesInRoom.indexOf(sid) == -1)
						arrHeroesInRoom.push(sid);
						
					_character.stopAnimation();
					_character.uninstall();
					_character = null;
					characters.splice(i, 1);
					i--;
				}
			}
			App.ui.upPanel.update();
		}
		
		public function onStopEvent(e:MouseEvent = null):void {
			if (hero == null) return;
			
			for (var i:int = 0; i < personages.length; i++ ) {
				var pers:Hero = personages[i];
				if(pers._walk){
					pers.stopWalking();
				}
				pers.tm.dispose();
				pers.finishJob();
				if (pers.path) {
					pers.path.splice(0, pers.path.length);
				}
			}
			
			for each(var target:* in App.user.queue) {
				if (target.target.ordered) {
					target.target.ordered = false;
					target.target.worker = null;
					if (!target.target.formed) {
						target.target.uninstall();
					}
				}
				if (target.target.hasOwnProperty('reserved') && target.target.reserved > 0) {
					target.target.reserved = 0;
				}
			}
			
			App.user.queue = [];
			
			Cursor.plant = false;
			if (ShopWindow.currentBuyObject.type) {
				ShopWindow.currentBuyObject.type = null;
			}
		}
		
		public function goHome():void {
			Post.send( {
				'ctr':'user',
				'act':'state',
				'uID':id,
				'wID':worldID,
				'fields':JSON.stringify(['world'])
			},  function onLoad(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					//Обрабатываем ошибку
					return;
				}
				
				for (var properties:* in data.user)
				{
					if (properties == 'friends') 
					continue;
					this[properties] = data.user[properties];
				}
				
				units = data.units;
				world = new World(data.world);
				
				var worlds:Object = {};
				for each(var wID:* in this.worlds) {
					worlds[wID] = wID;
				}
				this.worlds = worlds;
				
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_USER_COMPLETE));
			});
		}
		
		public function onProfileUpdate(data:Object):void {
			var postData:Object = {
				'ctr':'user',
				'act':'profile',
				'uID':id
			}
			
			for (var key:* in data) {
				postData[key] = data[key];
			}
			
			Post.send(postData,  function onLoad(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					//Обрабатываем ошибку
					return;
				}
			});
		}
		
		public function dreamEvent(wID:int):void {
			worldID = wID;
			Post.send( {
				'ctr':'user',
				'act':'state',
				'uID':id,
				'wID':wID,
				'fields':JSON.stringify(['world'])
			},  function onLoad(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					//Обрабатываем ошибку
					return;
				}
				
				units = data.units;
				world = new World(data.world);
				for (var properties:* in data.user)
				{
					this[properties] = data.user[properties];
				}
				
				var worlds:Object = {};
				for each(var wID:* in this.worlds) {
					worlds[wID] = wID;
				}
				this.worlds = worlds;
				
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_USER_COMPLETE));
			});
		}
		
		public function initPersonagesMove(X:int, Z:int):void 
		{
			var _hero:Hero = hero;
			if (_hero.tm.status != TargetManager.FREE || persLocked)
				return;
				
			var positions:Array = findNewPositions(X, Z, 1);
			_hero.initMove(positions[0].x, positions[0].z, _hero.onStop);
		}
		
		public var queue:Array = [];
		
		private function nearlestFreeHero(target:*):Hero {
			var resultHero:Hero;
			var dist:int = 0;
			for each(var _hero:Hero in personages){
				if (_hero.tm.status != TargetManager.FREE)	continue;
				
				var _dist:int = Math.abs(_hero.coords.x - target.coords.x) + Math.abs(_hero.coords.z - target.coords.z);
				if (dist == 0 || dist > _dist) {
					dist = _dist;
					resultHero = _hero;
				}
			}
			return resultHero;
		}
		
		private function freeHero():Hero 
		{
			
			for each(var _hero:Hero in personages){
				if (_hero.tm.status == TargetManager.FREE)
					return _hero;
			}
			return null;
		}
		
		/*public function getPersonag(sid:int):* 
		{
			var neededPers:Hero;
			for each(var pers:Hero in personages) {
				if(pers.targets.indexOf(sid) != -1)
					return pers;
			}
			
			return null;
		}*/
		
		public function addTarget(targetObject:Object):Boolean
		{
			var target:* = targetObject.target;
			var near:Boolean = targetObject.near || false;
			
			// если уже обрабатывается кем-то, то отдаем ему же в очередь
			if (target.worker) { 
				targetObject['event'] = target.worker.getJobFramesType(target.sid);
				target.worker.addTarget(targetObject); 
				return true; 
			}
			
			// ищем свободного, если нет отдаем первому
			var _hero:Hero;
			//var capacity:* = target.
			if (target is Resource) {
				_hero = Hero.getNeededHero(target.sid);
				if(_hero)
					targetObject['event'] = _hero.getJobFramesType(target.sid);
				else if(App.user.mode != User.GUEST){
					new FurryWindow( {
						title:target.info.title,
						info:target.info,
						mode:FurryWindow.RESOURCE,
						target:target,
						capacity:target.capacity
					}).show();
					return false;
				}	
				
				}else{
				if (near)
					_hero = nearlestFreeHero(target);
				else	
					_hero = freeHero();
					
				if(_hero)
					targetObject['event'] = _hero.getJobFramesType(target.sid);	
			}	
				
			if (_hero == null && targetObject.isPriority) {
				for each(_hero in personages) {
					_hero.addTarget(targetObject);
					return true;
				}
			}
			
			if (_hero == null) {
				if (targetObject.isPriority)
					queue.unshift(targetObject);
				else
					queue.push(targetObject);
			}else{
				//target.worker = _hero;
				_hero.addTarget(targetObject);
			}	
			return true;
		}
		
		private var radius:int = 5;
		private function findNewPositions(x:int, z:int, length:int = 2):Array {
			
			var positions:Array = [];
			var sX:int = x - radius;
			var sZ:int = z - radius;
			
			var fX:int = x + radius;
			var fZ:int = z + radius;
			
			for (var i:int = sX; i < fX; i++) {
				for (var j:int = sZ; j < fZ; j++) {
					if (App.map.inGrid( { x:i, z:j } )) {
						var node:AStarNodeVO = App.map._aStarNodes[i][j];
						if (!node.isWall) {
							positions.push( { x:i, z:j } );
						}
					}
				}
			}
			
			var result:Array = [
				{x:x, z:z}
			];
			
			for (var n:int = 0; n < length; n++) {
				result.push(takePosition(Math.random() * positions.length));
			}
			
			function takePosition(id:int):Object 
			{
				var position:Object = positions[id];
				positions.splice(id, 1);
				if (position == null) {
					position = {x:x, z:z };
				}
				return position;
			}
			
			//if(result[])
			
			return result;
		}
		
		public function takeTaskForTarget(_target:*):Array
		{
			var result:Array = [];
			for (var i:int = 0; i < queue.length; i++)	{
				if (queue[i].target == _target){ 
					result.push(queue[i]);
					queue.splice(i, 1);
					i--;
				}
			}
			
			return result;
		}
		
		public function addCharacter(object:Object):void {
			new Guide({ id:1, sid:object.sid, x:object.x, z:object.z});
		}
		
		public function storageRead(name:String, defaultReturn:* = ''):* {
			if (!settings[name]) return defaultReturn;
			
			try {
				var _value:Object = settings[name];
				return _value;
			}catch (e:*) {
				var _string:* = settings[name];
				return _string;
			}
		}
		public function storageStore(name:String, value:*, immediately:Boolean = false):void {
			settings[name] = value;
			if (immediately) {
				settingsWait = settingsSaveEvery;
				settingsSave();
			}else {
				settingsWait = 0;
			}
		}
		public function settingsSave():void {
			var presettings:String = JSON.stringify(settings);
			var compress:Boolean = true;
			
			if (_settings == presettings) return;
			_settings = presettings;
			
			trace(presettings);
			
			Post.send( {
				'uID':		id,
				'ctr':		'user',
				'act':		'settings',
				'settings':	presettings
			}, function(error:uint, data:Object, sett:Object):void {
				//trace(data);
			}, {});
		}
		
		private var skipTimes:int = 3;
		private const settingsSaveEvery:uint = 3;
		private var settingsWait:uint = 0;
		public function totalTimer():void {
			// Daylics
			if (skipTimes > 0) {
				skipTimes--;
				return;
			}
			//quests.checkDaylics();
			
			// settings
			if (settingsWait == settingsSaveEvery) {
				settingsSave();
			}
			settingsWait++;
		}
		
		public function takeBonus():void {
			if (quests.tutorial) return;
			
			Post.send( {
				ctr:	'Oneoff',
				act:	'get',
				id:		App.oneoff,
				uID:	App.user.id
			},function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('bonus')) {
					if (data.bonus is Boolean) {
						
					}else {
						new ReferalRewardWindow({bonus:Treasures.treasureToObject(data.bonus)}).show();
					}
				}
			});
		}
		
		
		public var arrBFFInvites:Array = [];
		public function checkBFF():void 
		{
			if (App.user.level <= 4) return;
			
			for (var friendInvite:* in bestFriendsInvites) {
				if(App.user.friends.data[friendInvite])
					arrBFFInvites.push(friendInvite);
			}
			if (arrBFFInvites.length > 0) 
			{
				new InviteBestFriendWindow(arrBFFInvites[0], null).show();
			}	
		}
	}
}