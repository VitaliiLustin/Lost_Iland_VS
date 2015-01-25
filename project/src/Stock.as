package 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Missionhouse;
	import units.Storehouse;
	import units.Techno;
	import units.Trade;
	import units.Unit;
	import units.WorkerUnit;
	import wins.BankSaleWindow;
	import wins.BanksWindow;
	import wins.BankWindow;
	import wins.elements.BankMenu;
	import wins.ErrorWindow;
	import wins.LevelBragWindow;
	import wins.LevelUpWindow;
	import wins.NectarAddChooseWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.Window;
	import wins.WindowEvent;

	public class Stock 
	{
		public static const EXP:uint = 4;
		public static const COINS:uint = 3;
		public static const FANT:uint = 5;
		public static const FANTASY:uint = 2;
		public static const JAM:uint = 16;
		public static const SPHERE:uint = 54;
		public static const GUESTFANTASY:uint = 285;
		public static const TECHNO:uint = 164;
		
		public var data:Object = null;
		public static var energyRestoreSettings:int;
		public static var _efirLimit:int = 0;
		public static var _limit:int = 0;
		public static var _value:int = 0;
		
		public static var _limit_mag:int = 0;
		public static var _value_mag:int = 0;
		
		/**
		 * Инициалиflash:1382952379984ция склада пользователя
		 * @param	data	объект склада
		 */
		public function Stock(data:Object)
		{
			
			if (data.hasOwnProperty('capacity')) {
				limit = data['capacity'];
				delete data['capacity'];
			}else {
				limit = App.data.options.Capacity;
			}
			
			
			for (var sID:* in data) {
				if (App.data.storage[sID] == null)
				{
					delete data[sID];
					continue;
				}
				data[sID] = int(data[sID]);
			}
			this.data = data;
			energyRestoreSettings = App.data.options['EnergyRestoreTime'];
			checkValue();
			
			emulateData();
		}
		
		private function emulateData():void 
		{
			data[COINS] = 100000;
			data[FANT] = 100000;
			data[FANTASY] = 100000;
		}
		
		public static function set efirLimit(value:int):void {
			_efirLimit = value;
			App.ui.upPanel.updateEnergy();
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_FANTASY));
		}
		
		public static function get efirLimit():int {
			return _efirLimit;
		}
		
		public static function set limit(value:int):void {
			_limit = value;
		}
		public static function get limit():int {
			return _limit;
		}
		
		public static function set limit_mag(value:int):void {
			_limit_mag = value;
		}
		public static function get limit_mag():int {
			return _limit_mag;
		}
		/*
		public function checkEnergy():void 
		{
			if (App.user.energy <= 0) {
				return;
			}
			
			var bonus:int = 0;
			if (App.social == 'PL' && App.data.options['PlingaEnergyPlus'] != undefined) {
				bonus = App.data.options['PlingaEnergyPlus'];
			}
			if (App.social == 'FB' && App.data.options['FBEnergyPlus'] != undefined) {
				bonus = App.data.options['FBEnergyPlus'];
			}
			
			var maxEenergyOnLevel:uint = App.data.levels[App.user.level].energy + bonus;
			
			if (data[FANTASY] >= efirLimit) {//maxEenergyOnLevel
				App.user.energy = 0;
				return;
			}
			
			var diffTime:int = App.time - App.user.energy;
			
			if (App.user.energy > 0 && diffTime >= energyRestoreSettings)
			{
				var countEnergy:int = int(diffTime / energyRestoreSettings);
				
				var maxCanAdd:int = efirLimit - data[FANTASY];//maxEenergyOnLevel
				maxCanAdd = maxCanAdd>0?maxCanAdd:0;
				maxCanAdd = Math.min(maxCanAdd, countEnergy);
				
				App.user.energy = App.time - diffTime % energyRestoreSettings;
				//data[FANTASY] += maxCanAdd;
				Post.addToArchive("client addOnTime: +"+maxCanAdd+"  total:"+(App.user.stock.data[Stock.FANTASY] + maxCanAdd));
				//checkSystem();
			}
		}*/
		
		/**
		 * Обновление склада
		 * @param	data	объект склада
		 */	
		
		public function bulkPost(needItems:Object, callBack:Function = null):void
		{
			Post.send({
				ctr:'stock',
				act:'bulk',
				uID:App.user.id,
				items:JSON.stringify(needItems)
			}, function(error:int, data:Object, params:Object):void {
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				if (callBack != null)
					callBack();
			});
		}
		 
		private function reinit(data:Object):void
		{
			this.data = data;
			App.ui.upPanel.update();
		}
		
		public function put(sID:uint, count:uint):void
		{
			data[sID] = count;
			App.ui.upPanel.update();
		}
		
		/**
		 * Возвращает кол-во текущего объекта на складе
		 * @param	sID	идентификатор объекта
		 * @return	uint	кол-во текущего объекта
		 */
		public function count(sID:uint):uint
		{
			return data[sID] == null ? 0 : data[sID]; 
		}
		
		/**
		 * Возвращает кол-во все виды варенья
		 * @return	Object	list:{sID:count}, totalCount
		 */
		public function jam(view:String = 'jam'):Object
		{
			var result:Object = {
				totalCount:0,
				list:{}
				}
			for (var sID:* in data)
			{
				if (App.data.storage[sID] == undefined) continue;
				
				var count:uint = count(sID)
				if (App.data.storage[sID].type == "Jam"){
					if (App.data.storage[sID].view == view) {
						if(count > 0){
							result.totalCount += count;
							result.list[sID] = count;
						}
					}
				}
			}
			
			return result;
		}
		
		/**
		 * Проверка кол-ва объекта на складе
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 * @return	true, если есть требуемое кол-во, false, если нет
		 */
		public function check(sID:uint, count:uint = 1):Boolean
		{
			if (data[sID] != null && data[sID] >= count)
			{
				return true;
			}
			if (sID == Techno.TECHNO) {
				return true;
			}
			if (Missionhouse.windowOpened) {
				return false;
			}
			
			if (sID == COINS || sID == FANT)
			{
				if (sID == COINS){
					BankMenu._currBtn = BankMenu.COINS;
					BanksWindow.history = {section:'Coins',page:0};
				}else {
					BankMenu._currBtn = BankMenu.REALS;
					BanksWindow.history = {section:'Reals',page:0};
				}
				
				var text:String;
				switch(App.social) {
					case "PL":
						if (sID == COINS) {
							text = Locale.__e("flash:1382952379746");
						}else {
							text = Locale.__e("flash:1382952379749");
						}
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							text:text,
							buttonText:Locale.__e('flash:1382952379751'),
							ok:function():void {
								if (sID == COINS) {
									ExternalApi.apiBalanceEvent('coins');
								}else{
									ExternalApi.apiBalanceEvent('reals');
								}
							}
						}).show();
						break;
					case 'YB':
						text = Locale.__e("flash:1382952379749");
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							text:text,
							forcedClosing:true,
							buttonText:Locale.__e('flash:1382952379751'),
							ok:function():void {
								new BanksWindow().show();
							}
						}).show();
						break;
						
					default:
						new BanksWindow().show();
						break;
				}
			}
			else if(sID == FANTASY)
			{
				if(!App.user.settings.notenough || (App.user.settings.notenough && App.user.settings.notenough.c < App.data.options.NotEnoughLimit))
					new NectarAddChooseWindow().show();
				else {
					new PurchaseWindow( {
						width:716,
						itemsOnPage:4,
						content:PurchaseWindow.createContent("Energy", {view:'Energy'}),
						title:Locale.__e("flash:1382952379756"),
						popup:true,
						description:Locale.__e("flash:1382952379757")
					}).show();
				}
				
				App.user.onStopEvent();
				//if (App.social == 'FB')
					//ExternalApi._6epush([ "_event", { event: "achievement", achievement: "out_of_fantasy" } ]);
				
			}else if(sID == GUESTFANTASY){
				
				new PurchaseWindow( {
					width:716,
					itemsOnPage:4,
					content:PurchaseWindow.createContent("Energy", {view:'GuestEnergy'}),
					title:Locale.__e("flash:1396252152417"),
					popup:true,
					description:Locale.__e("flash:1382952379757"),
					noDesc:true
				}).show();
				App.user.onStopEvent();
			}
			return false;
		}
		
		public function checkAll(items:Object):Boolean {
			for(var sID:* in items) {
				if (!check(sID, items[sID])) return false;
			}
			return true;
		}
		
		/**
		 * Добавление объекта на склад в кол-ве count
		 * @param	sID	идентификатор объекта
		 * @param	count	его кол-во
		 */
		public function add(sID:uint, count:uint, update:Boolean = true):void
		{
			if (data[sID] == null) data[sID] = 0;
			data[sID] = int(data[sID]);
			data[sID] += int(count);
			
			addValue(sID, count);
			
			switch(sID) {
				case Stock.EXP:
						var currentLevel:int = App.user.level;
						while (App.data.levels[App.user.level + 1] && data[sID] >= App.data.levels[App.user.level + 1].experience) {
							App.user.level++;
							//TODO выдаем тихо бонусы, чтобы не показывать кучу окон
							for (var _sID:* in App.data.levels[App.user.level].bonus)
							{
								App.user.stock.add(_sID, App.data.levels[App.user.level].bonus[_sID]);
							}
						}
						
						if (currentLevel < App.user.level) {
							App.self.dispatchEvent(new AppEvent(AppEvent.ON_LEVEL_UP));
							//TODO показываем окно с ревардами и текущим новым уровнем
							
							var bonus:int = 0;
							if (App.social == 'PL' && App.data.options['PlingaEnergyPlus'] != undefined) {
								bonus = App.data.options['PlingaEnergyPlus'];
							}
							if (App.social == 'FB' && App.data.options['FBEnergyPlus'] != undefined) {
								bonus = App.data.options['FBEnergyPlus'];
							}
							
							Post.addToArchive('level ' + App.user.level);
							var energy:int = App.data.levels[App.user.level].energy + bonus;
							if (data[FANTASY] < energy) {
								data[FANTASY] = energy;
								App.ui.upPanel.update(['energy']);
							}
							Post.addToArchive(data[FANTASY] + ' > ' + energy);
							
							App.user.quests.checkPromo(true);
							
							//делаем push в _6e
							//if (App.social == 'FB') {
								//ExternalApi._6epush([ "_event", { "event": "level", "level": App.user.level } ]);
							//}
								
							//App.ui.rightPanel.addFreebie();
							var win:LevelUpWindow = new LevelUpWindow( { } );
							win.show();
							win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpening);
							function onAfterOpening(e:WindowEvent):void
							{
								win.removeEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpening);
								SoundsManager.instance.playSFX('levelup');
							}
							
							for (var i:int = 0; i < App.user.promos.length; i++ ) {
								App.user.promos[i]['showed'] = true;
							}
							
							//App.user.quests.checkPromo(true);
							
							var checkMoneyLevel:Function = function(l:*, s:*) : Boolean {
								//for each(var value:* in l)
									if(l == s)	return true;	
								return false;								
							}
														
							//if (checkMoneyLevel(App.data.money.level, App.user.level) && App.user.money < App.time) {
								//Post.send( {
									//ctr:		'user',
									//act:		'money',
									//uID:		App.user.id,
									//enable:		1
								//}, function(error:int, data:Object, params:Object):void {
									//if (error)
									//{
										//Errors.show(error, data);
										//return;
									//}
									//App.user.money = App.time + (App.data.money.duration || 24) * 3600;
									//
									//new BankSaleWindow().show();
									//App.ui.salesPanel.addBankSaleIcon(UserInterface.textures.saleBacking2);
								//});	
							//}
							
							var arrTrades:Array = Map.findUnits([Trade.TRADE_ID]);
							if (arrTrades.length == 0)
								break;
								
							var trade:Trade = arrTrades[0];
							
							Post.send({
								ctr:'Trade',
								act:'refresh',
								uID:App.user.id,
								wID:App.user.worldID,
								sID:trade.sid,
								id:trade.id
							}, function(error:int, data:Object, params:Object):void {
								if (error)
								{
									Errors.show(error, data);
									return;
								}
								if (data.cells != false) {
									
									
									var trade:Trade = arrTrades[0];
									var obj:Object = trade.trades;
									
									trade.trades = data.cells;
									
									for (var num:* in data.cells) {
									}
									
									var count:int = num+1;
									for (var item:* in obj) {
										trade.trades[count] = obj[item];
										count += 1;
									}
									
									//var obj:Object = App.user.trades;
									//
									//App.user.trades = data.cells;
									//
									//for (var num:* in data.cells) {
									//}
									//
									//var count:int = num+1;
									//for (var item:* in obj) {
										//App.user.trades[count] = obj[item];
										//count += 1;
									//}
								}
								
							});	
						}
						
						if(App.user.level >= 5){
							for (var k:int = 0; k < App.user.friends.bragFriends.length; k++ ) {
								var brFriend:Object = App.user.friends.bragFriends[k];
								if (brFriend.exp && brFriend.exp < data[sID]) {
									LevelBragWindow.init(k);
									break;
								}
							}
						}
					break;
				case Stock.FANTASY:
					Storehouse.efirDistribution();
					App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_FANTASY));
					break;
				case Stock.GUESTFANTASY:
					App.ui.leftPanel.showGuestEnergy();
					break;	
			}
			
			if(update)
				App.ui.upPanel.update();
				
			App.ui.rightPanel.update();
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_STOCK));
		}
		
		public function addAll(items:Object):void {
			for (var sID:* in items) {
				add(sID, items[sID]);
			}
		}
		
		/**
		 * Удаление объекта со склада в укаflash:1382952379984нном кол-ве
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 * @return	true, если смогли взять, false, если не смогли
		 */
		public function take(sID:uint, count:uint):Boolean
		{
			if (check(sID, count))
			{
				if (sID == Techno.TECHNO)
				return true;
				
				data[sID] -= count;
				
				takeValue(sID, count);
				switch(sID) {
					case Stock.FANTASY:
							Storehouse.efirDistribution();
							App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_FANTASY));
							App.user.energy = App.time;
						break;
					case Stock.GUESTFANTASY:
							App.ui.leftPanel.showGuestEnergy();
						break;
				}
				
				App.ui.upPanel.update();
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_STOCK));
				return true;
			}
			
			return false;
		}
		
		public function takeAll(items:Object):Boolean {
			if (!checkAll(items)) 
			return false;
			for (var sID:* in items) {
				if (!take(sID, items[sID])) 
				return false;
			}
			return true;
		}
		
		/**
		 * Покупка объекта
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 */
		public function buy(sID:uint, count:uint, callback:Function = null):void {
			
			var object:Object = App.data.storage[sID];
			var params:Object = { };
			var price:Object = {};
			
			params[sID] = this.count(sID);
			
			for (var _sid:* in object.price) {
				price[_sid] = object.price[_sid] * count;
			}
			
			if (!takeAll(price)) return;
			
			add(sID, count);
				
			if (callback != null)
			{
				params['callback'] = callback;
				params['price'] = price;
			}
				
				Post.send( {
					ctr:'stock',
					act:'buy',
					uID:App.user.id,
					sID:sID,
					count:count
				},onBuyEvent, params);
		}
		
		/**
		 * Покупка пакета материалов
		 * @param	sID	идентификатор объекта
		 */
		public function pack(sID:uint, callback:Function = null, fail:Function = null, sett:Object = null):void 
		{
			var object:Object = App.data.storage[sID];
			var price:Object;
			
			var settings:Object = { 
					ctr:'stock',
					act:'pack',
					uID:App.user.id,
					sID:sID
				};
				
			if (sett) {
				for (var it:* in sett) {
					settings[it] = sett[it];
				}
			}
			
			if (object.hasOwnProperty('price')) price = object.price;
			else {
				var _price:int;
				object['count'] = Stock.efirLimit - App.user.stock.count(Stock.FANTASY);
				if (object['count'] > 0) _price = Math.ceil(object['count'] / 30);
				else _price = 0;
				
				settings['price'] = _price;
				settings['count'] = object['count'];
				
				price = { };
				price[Stock.FANT] = _price;
			}
			
			if (takeAll(price)) {
				
				if (!object.hasOwnProperty('out')){
					object['out'] = object.sID;
					object['count'] = 1;
				}	
					
				if(settings.ctr == "stock")add(object.out, object.count);
				
				Post.send(settings, function(error:*, result:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (callback != null) {
						callback(object.out, result);
					}
					
					App.self.dispatchEvent(new AppEvent(AppEvent.ON_AFTER_PACK));
				});
				
			}else {
				if (fail != null) {
					fail();
				}
			}
		}
		
		public function checkCollection(sID:uint):Boolean {
			var collection:Object = App.data.storage[sID];
			var materials:Object = { };
			for each(var mID:* in collection.materials){
				materials[mID] = 1;
			}
			return checkAll(materials);
		}
		
		public function exchange(sID:uint, callback:Function):Boolean {
			
			var collection:Object = App.data.storage[sID];
			var materials:Object = { };
			for each(var mID:* in collection.materials){
				materials[mID] = 1;
			}
			
			if (checkAll(sID)) {
				takeAll(materials);
			}else {
				return false;
			}
			
			Post.send( {
				ctr:'stock',
				act:'exchange',
				uID:App.user.id,
				sID:sID
			},onExchangeEvent, { sID:sID, callback:callback } );
			
			return true;
		}
		
		private function onExchangeEvent(error:int, data:Object, params:Object):void {
			
			var mID:*;
			var collection:Object = App.data.storage[params.sID];
			
			params.callback();
			
			if (error) {
				Errors.show(error, data);
				for each(mID in collection.materials){
					add(mID, 1);
				}
				return;
			}
			//Выдаем бонусы
			for (mID in collection.reward) {
				add(mID, collection.reward[mID]);
			}
			
		}
		
		/**
		 * flash:1382952380091 объекта
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 */
		public function sell(sID:uint, count:uint, callback:Function = null):void {
			
			var object:Object = App.data.storage[sID]; 
			var price:int = object.cost * count;
			
				add(COINS, price);
				take(sID, count);
				
			var params:Object = { }
			params['callback'] = callback;
				
				Post.send({
					ctr:'stock',
					act:'sell',
					uID:App.user.id,
					sID:sID,
					count:count
				},onSellEvent, params);
		}
		
		private function onSellEvent(error:int, data:Object, params:Object):void {
			var id:*;
			
			if (error) {
				//синхронflash:1382952379993ируем с сервером
				Errors.show(error, data);
				if (data) reinit(data);
				if (params) params.callback()
				return;
			}
			
			for (id in data) {
				if (this.data[id] != data[id]) {
					this.data[id] = data[id];
				}
				
				if (params && params.callback != null) params.callback();
			}
		}
		
		private function onBuyEvent(error:int, data:Object, params:Object):void {
			var id:*;
			
			if (error) {
				Errors.show(error, data);
				//Возвращаем как было
				for (id in params) {
					this.data[id] = params[id];
				}
				if (data) reinit(data);
				return; 
			}
			
			for (id in data) {
				if (this.data[id] != data[id]) {
					//TODO втихаря меняем на актуальное значение, которое пришло от сервера
					//или как-то иначе обрабатываем несоотвествие
					this.data[id] = data[id];
				}
			}
			
			if (params.hasOwnProperty('callback')) {
				params.callback(params.price);
			}
		}
		
		public function checkSystem():void
		{
			Post.send( {
				ctr:		'stock',
				act:		'system',
				uID:		App.user.id
			},
			function(error:*, data:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (data == null) return;
				
				if(data.hasOwnProperty('gifts')){
					var hasGift:Boolean = false;
					
					for (var gID:String in data.gifts) {
					Gifts.addGift(gID, data.gifts[gID]);
						hasGift = true;
					}
					if (hasGift) {
						App.ui.glowing(App.ui.bottomPanel.bttnMainGifts, 0xFFFF00);
					}
						
					App.user.gifts.sortOn("time", Array.DESCENDING);
					if (App.user.gifts.length > App.user.giftsLimit/*App.data.options['GiftsLimit']*/) {
						App.user.gifts.splice(45, App.user.gifts.length - 45);
						if(App.ui) App.ui.rightPanel.update();
					}
				}
				
				if(data.hasOwnProperty(Stock.FANTASY)){
					App.user.stock.data[Stock.FANTASY] = data[Stock.FANTASY];
					Post.addToArchive("server addOnTime  total:"+data[Stock.FANTASY]);
				}
				
				if(data.hasOwnProperty('restore')){
					App.user.energy = data.restore;
				}	
				
				if(App.ui != null && App.ui.upPanel != null){
					App.ui.upPanel.update();
				}
			});
		}	
		
		public function setFantasy(count:uint):void
		{
			Post.addToArchive("take: " + App.user.stock.data[Stock.FANTASY] + " -> " + count);
			data[Stock.FANTASY] = count;
			if (App.user.energy == 0) {
				App.user.energy = App.time;
			}
				
			App.ui.upPanel.update(['energy']);
			if (data[Stock.FANTASY] == 0) {
					App.user.onStopEvent();
					Post.clear();
					if(!App.user.settings.notenough || (App.user.settings.notenough && App.user.settings.notenough.t + App.data.options.NotEnoughLimit < App.time))
						new NectarAddChooseWindow().show();
					else {
						new PurchaseWindow( {
							width:716,
							itemsOnPage:4,
							content:PurchaseWindow.createContent("Energy", {view:'Energy'}),
							title:Locale.__e("flash:1382952379756"),
							popup:true,
							description:Locale.__e("flash:1382952379757")
						}).show();
					}
			}
		}
		
		public function charge(sID:uint, count:uint = 1):void {
			
			if (!take(sID, count)) return;
			
			Post.send( {
				ctr:'stock',
				act:'charge',
				uID:App.user.id,
				sID:sID,
				count:count
			},function(error:*, result:*, params:*):void {
				
				if (error) {
					Errors.show(error, result);
					return;
				}
				
				if (result.hasOwnProperty(Stock.FANTASY)) {
					data[Stock.FANTASY] = result[Stock.FANTASY];
					App.ui.upPanel.update(['energy']);
				}
			});
		}
		
		public function takeValue(sid:int, count:int):void {
			var item:Object = App.data.storage[sid];
			if (item.artifact) {
				_value_mag -= count;
				return;
			}
			
			if (consider(sid))
				_value -= count;
		}
		
		public function addValue(sid:int, count:int):void {
			var item:Object = App.data.storage[sid];
			if (item.artifact) {
				_value_mag += count;
				return;
			}
			
			if (consider(sid)){
				App.ui.upPanel.updateCapasity(value);
				_value += count;
			}
		}
		
		
		/*public static function set value(count:int):void 
		{
			trace(_value +' -> ' + count);
			_value = count;
			// Показываем прогресс в upPanel
		}*/
		
		public static function get value():int {
			return _value;
		}
		
		public function checkValue():void {
			for (var sid:* in data) {
				if (App.data.storage[sid].artifact) {
					_value_mag += data[sid];
					continue;
				}
					
				if(consider(sid))
					_value += data[sid];
			}
		}
		
		public static function notAvailableItems():Array 
		{
			var updtItems:Array = [];
			if(App.data.updatelist.hasOwnProperty(App.social)) {
				for (var s:String in App.data.updatelist["DM"]) {
					if (!App.data.updates[s].social.hasOwnProperty(App.social)) {
						for(var sidItem:* in App.data.updates[s].items){
							updtItems.push(sidItem);
						}
					}
				}
			}
			return updtItems;
		}
		
		public static function consider(sid:int):Boolean 
		{
			switch(sid) {
				case EXP:
				case COINS:
				case FANT:
				case FANTASY:
				case GUESTFANTASY:
				case JAM:
					return false;
				break;	
			}
			
			var item:Object = App.data.storage[sid];
			
			switch(item.type){
				case 'Material':
					if (item.mtype == 3 || item.mtype == 4 || item.artifact)
						return false;
					else
						return true;
						
					break;
				case 'Jam':
				case 'Clothing':
				case 'Lamp':
				case 'Animal':
				case 'Guide':
				return false;
					break;
				default:
						return true;
					break;	
			}
			
			return true;
		}
		
		public function canTake(obj:Object):Boolean 
		{
			//return true;
			
			var count:int = 0;
			if (obj is Number) {
				count = int(obj);
			}else if (obj is Object) {
				for (var sid:* in obj) {
					count += obj[sid];
				}
			}
			
			if (App.user.mode == User.GUEST ||
				value + count <= limit ||
				sid == Stock.EXP || 
				sid == Stock.COINS || 
				sid == Stock.FANT ||
				sid && App.data.storage[sid].artifact && _value_mag + count <= limit_mag
			){
				return true;
			}else {	
				
				var winSettings:Object = {
					title				:Locale.__e('flash:1393576964828'),
					text				:Locale.__e('flash:1393577003645'),
					buttonText			:Locale.__e('flash:1393576915356'),
					//image				:UserInterface.textures.alert_storage,
					image				:Window.textures.errorStorage,
					imageX				:-78,
					imageY				: -76,
					textPaddingY        : -18,
					textPaddingX        : -10,
					hasExit             :true,
					faderAsClose        :true,
					faderClickable      :true,
					forcedClosing       :true,
					closeAfterOk        :true,
					popup               :true,
					bttnPaddingY        :25,
					ok					:function():void {
						new StockWindow({isStock:true}).show();
					}
				};
				new ErrorWindow(winSettings).show();
				
				return false;
			}	
		}
		
		public function canTakeEfir(count:int):Boolean {
			
			var canAddedToStock:int = Stock.efirLimit - App.user.stock.count(Stock.FANTASY);
				if (canAddedToStock <= 0 || canAddedToStock < count) {
					
					var winSettings:Object = {
						title				:Locale.__e('flash:1396250443959'),
						text				:Locale.__e('flash:1396250937724', [App.data.storage[Storehouse.STOREHOUSE_1].title]),
						buttonText			:Locale.__e('flash:1393577477211'),
						//image				:UserInterface.textures.alert_storage,
						image				:Window.textures.errorStorage,
						imageX				:-78,
						imageY				: -76,
						textPaddingY        : -18,
						textPaddingX        : -10,
						hasExit             :true,
						faderAsClose        :true,
						faderClickable      :true,
						closeAfterOk        :true,
						forcedClosing       :true,
						bttnPaddingY        :25,
						ok					:function():void {
							new ShopWindow( { find:[Storehouse.STOREHOUSE_1], forcedClosing:true } ).show();
						}
					};
					new ErrorWindow(winSettings).show();
					
					
					return false;
				}
			return true;
		}
		
		public function remove(sID:uint, count:int = 0):void {
			
			var countD:int = data[sID];
			
			if (countD - count <= 0)
				delete data[sID];
			else
				data[sID] -= count;
			
			takeValue(sID, count);	
			//value -= count;
			
			Post.send( {
				ctr:'stock',
				act:'remove',
				uID:App.user.id,
				sID:sID,
				count:count
			},function(error:*, result:*, params:*):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
	}	
}