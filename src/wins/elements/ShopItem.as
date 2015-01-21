package wins.elements 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.TweenMax;
	import core.IsoConvert;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import units.Factory;
	import units.Field;
	import units.Sphere;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;
	import wins.elements.PriceLabel;
	import wins.ErrorWindow;
	import wins.HeroWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;

	public class ShopItem extends LayerX {
		
		public var item:*;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		//public var preloader:Preloader;
		public var title:TextField;
		public var priceBttn:Button;
		public var openBttn:MoneyButton;
		public var window:*;
		
		public var moneyType:String = "coins";
		public var previewScale:Number = 1;
		
		private var needTechno:int = 0;
		
		private var preloader:Preloader = new Preloader();
		public function ShopItem(item:*, window:*) {
			
			this.item = item;
			this.window = window;
			
			var backing:String = 'itemBacking';
			if (item.type == 'Golden')
				backing = 'shopSpecialBacking';
			if (item.type == 'Gamble')
				backing = 'blueItemBacking';
		
			background = Window.backing(172, 210, 10, backing);
			
			if (ShopWindow.history.section == 3 && item.hasOwnProperty('price')) 
			{
				for (var pr:* in item.price) 
				{
					break;
				}
			}
			
			addChildAt(background, 0);
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			sprite.mouseChildren = false;
			sprite.mouseEnabled = false;
			tip = function():Object { 
				
				if (item.type == "Plant")
				{
					return {
						title:item.title,
						text:Locale.__e("flash:1382952380075", [TimeConverter.timeToCuts(item.levelTime * item.levels), item.experience, App.data.storage[item.out].cost])
					};
				}
				else if (item.type == "Decor")
				{
					return {
						title:item.title,
						text:Locale.__e("flash:1382952380076", item.experience)
					};
				}
				else
				{
					return {
						title:item.title,
						text:item.description
					};
				}
			};
			
			drawTitle();
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			
			var short:Boolean = false;
			if (item.type == "Material")
				short = true;
						
			Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
			
			//var itemsData:Object = ShopWindow.worldShop[ShopWindow.history.section];
			//var end:Boolean = false;
			//for (var ind:* in itemsData) {
				//if (item.sid == ind && itemsData[ind] == 0) {
					//drawNotAvailableTxt();
					//end = true;
					//break;
				//}
			//}
			//if (end) return;
	
			//if(!short){
				//if (ShopWindow.lockInThisWorld.indexOf(int(item.sid)) != -1) {
					//drawNotAvailableTxt();
					//return;
				//}
			//}
			
			var countOnMap:int = World.getBuildingCount(item.sid);
			
			if (short) {
				if (item.collection) {
					drawText(Locale.__e('flash:1405680422898'));
				}
			}else if (item.hasOwnProperty('instance') && World.getBuildingCount(item.sid) >= getInstanceNum() ) {  
				drawTextBought();
				drawCountBuild();
			}else if (item.hasOwnProperty('instance') && App.user.level < item.instance.level[countOnMap + 1] && App.user.shop[item.sid] != countOnMap + 1) {
				//drawNeedTxt(item.instance.level[countOnMap + 1], 10, 196);
				//drawCountBuild();
				
				if (item.id <= App.user.shop[item.sid]) {
					drawPriceBttn();
				}else if (item.instance.p && item.instance.p[countOnMap + 1]) {
					drawNeedTxt(item.instance.level[countOnMap + 1], 10, 190);
					drawOpenBttn(countOnMap + 1);
				}else{
					drawNeedTxt(item.instance.level[countOnMap + 1], 10, 196);
					drawCountBuild();
				}	
				
			}else if (item.type == "Golden" && item.level > App.user.level) {
				drawOpenBttn(item.sid);
			}else if ((item.type == 'Resource' || item.type == 'Decor')&& App.user.level < item.level) {
				drawNeedTxt(item.level, 7, 24, openSprite);
				//drawOpenBttn(0, true);
			}else if (item.type == 'Character' && (App.user.characters.length > 0 || App.user.arrHeroesInRoom.indexOf(item.sID) != -1 || App.user.stock.count(item.sID) > 0)) {
				drawTextBought();
			}else if (item.collection) {
				drawText(Locale.__e('flash:1405680422898'));
			}else{
				drawPriceBttn();
			}
			
			if (window.settings.find != null && window.settings.find.indexOf(int(item.sid)) != -1) {
				glowing();
			}
			
			if (ShopWindow.shop[100].data.indexOf(item.sid) != -1) {
				setNew();
			}
			item.type;
			if (item.type == 'Golden' || item.type == 'Gamble') {
				setGold();
			}
			
		}
		
		private function drawText(text:String):void 
		{
			var txt:TextField = Window.drawText(text, {
				color:0xc42f07,
				fontSize:22,
				borderColor:0xfcf5e5,
				textAlign:"center",
				borderSize:3
			});
			
			txt.width = 150;
			txt.height = txt.textHeight;
			addChild(txt);
			txt.x = (background.width - txt.width) / 2;
			txt.y = background.height - txt.textHeight - 28;
		}
		
		public function setGold():void {
			var newStripe:Bitmap = new Bitmap(Window.textures.goldRibbon);
			newStripe.x = 2;
			newStripe.y = 3;
			addChildAt(newStripe, 1);
		}
		
		public function setNew():void {
			var newStripe:Bitmap = new Bitmap(Window.textures.stripNew);
			newStripe.x = 2;
			newStripe.y = 3;
			addChild(newStripe);
		}
		
		private function getInstanceNum():int
		{
			var count:int = 0;
			for each(var inst:* in item.instance['level']) {
				count++;
			}
			return count;
		}
		
		private function setLabel(type:String):void {
			
			var text:String = '';
			var textSettings:Object = {
				color:0x4A401F,
				borderColor:0xfcf6e4,
				borderSize:4,
				fontSize:20,
				textAlign:"center",
				multiline:true
			}
			switch(type) {
				case 'Collection':
					text = Locale.__e('flash:1382952380077');
					textSettings['fontSize'] = 22;
					textSettings['color'] = 0x4683a6;
					break;
				case 'Dreams':
					textSettings['fontSize'] = 22;
					textSettings['color'] = 0x5c9e5a;
					text = Locale.__e('flash:1382952380078');
					break;	
			}
			
			var label:TextField = Window.drawText(text, textSettings);
			addChild(label);
			label.wordWrap = true;
			label.width = background.width - 20
			label.x = 10;
			label.y = 140;
		}
		
		
		
		private var _closed:Boolean = false;
		private function set closed(value:Boolean):void {
			_closed = value;
			if (_closed)
			{
				/*//bitmap.alpha = 0.5;
				if (openSprite) openSprite.visible = false;
				if(priceBttn) priceBttn.visible = false;
				if (openBttn) openBttn.visible = false;
				if (priceLabel) priceLabel.visible = false;*/
				drawClosedLabel();
			}
		}
		
		private function drawClosedLabel():void 
		{
			var label:TextField = Window.drawText(Locale.__e("flash:1382952380079"), {
				color:0x4A401F,
				borderColor:0xfcf6e4,
				borderSize:4,
				fontSize:20,
				textAlign:"center",
				multiline:true
			});
			addChild(label);
			label.wordWrap = true;
			label.width = background.width - 20
			label.x = 10;
			label.y = 125;
			//label.border = true;
		}
		
		private function get closed():Boolean {
			return _closed;
		}
		
		private var dY:int = -22;//-15
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			var centerY:int = 90;
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = previewScale;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width) / 2;
			if (item.type == 'Resource') centerY = 110;
			bitmap.y = centerY - bitmap.height / 2;
			
			if (item.type == 'Material')
				bitmap.y = (background.height - bitmap.height) / 2;
			
			if (item.type == 'Golden') {
				var sid:int;
				var btm:Bitmap = new Bitmap(UserInterface.textures.collectionsIcon);
				var bonus:Object = App.data.treasures[item.shake];
				var tips:Object = {
					title:"",
					text:Locale.__e("flash:1396002489532")
				}		
				for each (var item:* in bonus)
				{
					for (var innerItem:* in item.item)
					{
						sid = item.item[innerItem];
						if ((App.data.storage[sid].type != "Collection") &&
							(App.data.storage[sid].mtype != 3)) {
								btm.bitmapData = UserInterface.textures.collectionsIcon2;
								tips.text = Locale.__e("flash:1404910191257");
								break;
						}
					}
				}
				var contGolden:LayerX = new LayerX();
				contGolden.addChild(btm);
				addChild(contGolden);
				contGolden.x = background.width - contGolden.width - 6;
				contGolden.y = background.height - contGolden.height - 32;
				contGolden.tip = function():Object { 
					return {
						title:tips.title,
						text:tips.text
					};
				}
			}
		}
		
		public function dispose():void {
			if(priceBttn != null){
				priceBttn.removeEventListener(MouseEvent.CLICK, onBuyEvent);
			}
			if(openBttn != null){
				openBttn.removeEventListener(MouseEvent.CLICK, onOpenEvent);
			}
			
			if (Quests.targetSettings != null) {
				Quests.targetSettings = null;
				if (App.user.quests.currentTarget == null) {
					QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
				}
			}
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(item.title), {
				color:0x814f31,
				borderColor:0xfaf9ec,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				textLeading:-6,
				multiline:true,
				wrap:true,
				width:background.width - 20
			});
			title.y = 10;
			title.x = (background.width - title.width)/2;
			addChild(title)
		}
		
		public function drawBuyedLabel():void {
			var label:TextField = Window.drawText(Locale.__e("flash:1382952380080"), {
				color:0x4A401F,
				borderSize:0,
				fontSize:14,
				autoSize:"center"
			});
			addChild(label);
			label.x = (background.width - label.width)/2;
			label.y = 152;
		}
		
		public var priceLabel:PriceLabelShop;
		public function drawPriceBttn():void {
			
			var countInstance:int = 0;
			var count:int = 0;
			
			var icon:Bitmap;
			var price:int = 0;
			var settings:Object = { fontSize:16, autoSize:"center" };
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379751"),
				fontSize:24,
				width:120,
				height:38,
				hasDotes:false
			};
			
			if (item.hasOwnProperty('unlock')) {
				priceLabel = new PriceLabelShop( { 3:item.unlock.price });
					count = 133;
			}else if (item.hasOwnProperty('price')) {
				priceLabel = new PriceLabelShop(item.price);
				for (var sID:* in item.price) {
					count = sID;
					break;
				}
			}else{
				var countOnMap:int = World.getBuildingCount(item.sID);
				priceLabel = new PriceLabelShop(item.instance.cost[countOnMap+1]);
				
				for  (sID in item.instance.cost[countOnMap+1]) {
					if (sID == Stock.FANT) {
						count = sID;
						break;
					}	
				}
			}
			
			if (count == Stock.FANT){
				bttnSettings["bgColor"] = [0xffb19f, 0xff828a];
				bttnSettings["borderColor"] = [0xffdad3, 0xc25c62];
				bttnSettings["bevelColor"] = [0xffdad3, 0xc25c62];
				bttnSettings["fontColor"] = 0xffffff;			
				bttnSettings["fontBorderColor"] = 0xa53d44;
				bttnSettings["greenDotes"] = false;
			}
			
			priceLabel.x = 17;
			priceLabel.y = 170;
			priceLabel.text.scaleX = 1.2;
			priceLabel.text.scaleY = 1.1;

			if (item.type == 'Resource') priceLabel.y += 12;
			addChild(priceLabel);
			
			if(item.hasOwnProperty('instance'))countInstance = getInstanceNum();
			
			if(countInstance > 0){
				var txt:String = String(World.getBuildingCount(item.sid)) + "/" + countInstance;
				
				var counterLabel:TextField = Window.drawText(txt, {
					fontSize:23,
					color:0xffffff,
					borderColor:0x2D2D2D,
					autoSize:"left"
				});
				
				counterLabel.x = 108;
				/*counterLabel.y = - 35;*/
				if (priceLabel.getNum() == 1) counterLabel.y = -55;
				else counterLabel.y = -priceLabel.height/4 - 5;
				priceLabel.addChild(counterLabel);
			}
			
			priceBttn = new Button(bttnSettings);
			addChild(priceBttn);
			
			priceBttn.x = background.width/2 - priceBttn.width/2;
			priceBttn.y = background.height - priceBttn.height + 15;
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
		}
		
		private function drawNotAvailableTxt():void
		{
			var txt:TextField = Window.drawText(Locale.__e("flash:1394709941657"), {
				color:0xa62f14,
				borderColor:0xfcf5e5,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				textLeading:-6,
				multiline:true,
				wrap:true,
				width:background.width - 20
			});
			addChild(txt)
			txt.x = (background.width - txt.width)/2;
			txt.y = (background.height - txt.textHeight) - 20;
		}
		
		private var openSprite:Sprite = new Sprite();
		private function drawNeedTxt(lvl:int, posX:int, posY:int, container:Sprite = null):void
		{
			addChild(openSprite);
			openSprite.y = 170;
			
			var needed:TextField = Window.drawText(Locale.__e("flash:1382952380085",[lvl]), {
				color:0xc42f07,
				fontSize:22,
				borderColor:0xfcf5e5,
				textAlign:"center",
				borderSize:3
			});
			
			needed.width = 150;
			needed.height = needed.textHeight;
			if (container) container.addChild(needed);
			else addChild(needed);
			needed.x = posX;
			needed.y = posY - 32;
			
			//drawCountBuild();
		}
		
		private var boughtText:TextField;
		private function drawTextBought():void
		{
			boughtText = Window.drawText(Locale.__e("flash:1396612413334"), {
				color:0xfff2dd,
				borderColor:0x7a602f,
				borderSize:4,
				fontSize:24,
				autoSize:"center"
			});
			addChild(boughtText);
			boughtText.x = (background.width - boughtText.textWidth)/2;
			boughtText.y = background.height - boughtText.textHeight - 20;
			
			bitmap.alpha = 0.5;
			
		}
		
		private var openText:TextField;
		public function drawOpenBttn(idItem:int, isDecor:Boolean = false):void {
			
			var settings:Object = { 
				fontSize:20, 
				autoSize:"left",
				color:0xc5f68f,
				borderColor:0x3f670f
			};
			
			var cont:Sprite = new Sprite();
			
			openBttn = new MoneyButton({
				caption: Locale.__e("flash:1382952379890"),
				width:130,
				height:40,
				fontSize:24,
				radius:20,
				hasDotes:false
			})
			if (item.type == "Golden")
				openBttn.count = item.skip;
			else
				openBttn.count = item.instance.p[idItem];
				
			addChild(openBttn);
			openBttn.countLabel.x -= 4;
			openBttn.x = (background.width - openBttn.settings.width)/2;
			openBttn.y = background.height - openBttn.height/2 - 4;
				
			openBttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
		}
		
		
		private function drawCountBuild():void
		{
			var txt:String = String(World.getBuildingCount(item.sid)) + "/" + getInstanceNum();
				
				var counterLabel:TextField = Window.drawText(txt, {
					fontSize:24,
					color:0xffffff,
					borderColor:0x2D2D2D,
					autoSize:"left"
				});
				
				counterLabel.x = 125;
				counterLabel.y = 115;
				addChild(counterLabel);
		}
		
		private function onOpenEvent(e:MouseEvent):void {

			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			var countOnMap:int = World.getBuildingCount(item.sid);
			if (item.type == "Golden") {
				if (App.user.stock.take(Stock.FANT, item.skip)) {
					Hints.minus(Stock.FANT, item.skip, Window.localToGlobal(e.currentTarget), false, window);
				
					App.user.shop[item.sid] = countOnMap+1;
					window.contentChange();
					
					Post.send( {
						ctr:'user',
						act:'open',
						uID:App.user.id,
						sID:item.sid,
						iID:0
					}, function(error:*, data:*, params:*):void {
						if (!error) {
							App.user.shop[item.sid] = 1;
							window.contentChange();
						}
					})
				}
			}
			else if (App.user.stock.take(Stock.FANT, item.instance.p[countOnMap+1])) {
				
				Hints.minus(Stock.FANT, item.instance.p[countOnMap+1], Window.localToGlobal(e.currentTarget), false, window);
				
				App.user.shop[item.sid] = countOnMap+1;
				window.contentChange();
				
				Post.send( {
					ctr:'user',
					act:'open',
					uID:App.user.id,
					sID:item.sid,
					wID:App.user.worldID,
					iID:countOnMap+1
				}, function(error:*, data:*, params:*):void {
					if (!error) {
						App.user.shop[item.sid] = countOnMap+1;
						window.contentChange();
					}
				})
			}
			else
			{
				e.currentTarget.state = Button.NORMAL;
			}
		}
		
		private function onBuyEvent(e:MouseEvent):void {
			
			if (!isEnoughTechno()) return;
			
			//if (!isEnoughMoney()) return;
			
			ShopWindow.currentBuyObject = { type:item.type, sid:item.sid };
			var unit:Unit;
			switch(item.type)
			{
				case "Material":
					App.user.stock.buy(item.sid, 1);
					break;
				case "Boost":
				case "Energy":
					var sett:Object = null;
					if (App.data.storage[item.sid].out == Techno.TECHNO) {
						sett = { 
							ctr:'techno',
							wID:App.user.worldID,
							x:App.map.heroPosition.x,
							z:App.map.heroPosition.z,
							capacity:1
						};
						App.user.stock.pack(item.sid, onBuyComplete, function():void {
						}, sett);
					}else {
						App.user.stock.pack(item.sid);
					}
					break;
				//case "Plant":
					//if(Field.exists == false){
						//unit = Unit.add( { sid:13 } );
						//unit.move = true;
						//App.map.moved = unit;
						//Cursor.plant = item.sid;
					//}
					//Field.exists = false;
					//
					//if (App.user.quests.currentQID == 10) {
						//App.user.quests.currentTarget = null;
						//QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
					//}
					//
					//break;
				case 'Clothing':
					new HeroWindow({find:item.sid}).show();
					break;
				case 'Animal':
					unit = Unit.add( { sid:item.sid, buy:true } );
					unit.move = true;
					App.map.moved = unit;
					break
				default:
					//if (item.type == "Character") {
						//var arr:Array = [];
						//arr.length
						//for (var j:int = 0; j < ShopWindow.shop[item.market].data.length; j ++ ) {
							//if (ShopWindow.shop[item.market].data[j].sID == item.sID)
								//ShopWindow.shop[item.market].data.splice(j);
						//}
					//}
					if (item.sid == 172 && App.user.quests.currentQID == 11) {
						var coords:Object = IsoConvert.isoToScreen(55, 106, true);
						App.map.focusedOn(coords);
					}
					
					if (item.sid == 54 && App.user.quests.data["16"] == null) {
						new SimpleWindow( {
							text:Locale.__e('flash:1383043022250', [App.data.quests[16].title]),
							label:SimpleWindow.ATTENTION
						}).show();
						break;
					}
					unit = Unit.add( { sid:item.sid, buy:true } );
					
					unit.move = true;
					App.map.moved = unit;
				break;
			}
			
	//		window.contentChange();
			
			if(item.type != "Material"){
				window.close();
			}else{
				var point:Point = localToGlobal(new Point(e.currentTarget.x, e.currentTarget.y));
				point.x += e.currentTarget.width / 2;
				Hints.minus(Stock.COINS, item.coins, point);
			}
			
			if(App.user.quests.tutorial){
				QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
			}
		}
		
		private function onBuyComplete(sID:uint, rez:Object = null):void 
		{
			if (Techno.TECHNO == sID) {
				addChildrens(sID, rez.ids);
			}
		}
		
		private function addChildrens(_sid:uint, ids:Object):void 
		{
			var rel:Object = { };
			rel[Factory.TECHNO_FACTORY] = _sid;
			var position:Object = App.map.heroPosition;
			for (var i:* in ids){
				var unit:Unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z, rel:rel } );
					(unit as WorkerUnit).born({capacity:1});
			}
		}
		
		private function isEnoughTechno():Boolean 
		{
			if (item.sid == Factory.TECHNO_FACTORY || !item.hasOwnProperty('instance')) return true;
			
			
			var req:Object = item.instance.cost[World.getBuildingCount(item.sid) + 1];
			for (var itm:* in req) {
				if (itm == Techno.TECHNO) {
					needTechno = req[itm];
					break;
				}
			}
			
			var bots:Array = Techno.freeTechno();
			if (bots.length < needTechno) {
				var arrFactories:Array = Map.findUnits([Factory.TECHNO_FACTORY]);
				if (arrFactories.length > 0) {
					
					var winSettings:Object = {
						title				:Locale.__e('flash:1396367125010'),
						text				:Locale.__e('flash:1396367066179'),
						buttonText			:Locale.__e('flash:1396367321622'),
						//image				:UserInterface.textures.alert_storage,
						image				:Window.textures.errorStorage,
						imageX				: -78,
						imageY				: -76,
						textPaddingY        : -18,
						textPaddingX        : -10,
						hasExit             :true,
						faderAsClose        :true,
						faderClickable      :true,
						closeAfterOk        :true,
						//forcedClosing       :true,
						isPopup             :true,
						bttnPaddingY        :25,
						ok					:function():void {
							new PurchaseWindow( {
								width:716,
								itemsOnPage:4,
								useText:true,
								shortWindow:true,
								closeAfterBuy:true,
								popup:true,
								//image:new Bitmap(UserInterface.textures.alert_techno),
								image:new Bitmap(Window.textures.errorWork),
								description:Locale.__e('flash:1393599816743'),
								descWidthMarging:-140,
								content:PurchaseWindow.createContent("Energy", {inguest:0, view:'furry'}),
								title:Locale.__e("flash:1396364739262"),
								callback:function(sID:int):void {
									var object:* = App.data.storage[sID];
									App.user.stock.add(sID, object);
								}
							}).show();
						}
					};
					new ErrorWindow(winSettings).show();
					
					//new PurchaseWindow( {
						//width:716,
						//itemsOnPage:4,
						//useText:true,
						//shortWindow:true,
						//popup:true,
						//closeAfterBuy:true,
						//image:new Bitmap(UserInterface.textures.alert_techno),
						//description:Locale.__e('flash:1393599816743'),
						//descWidthMarging:-140,
						//content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Техно'}),
						//title:Locale.__e("Техно"),
						//description:Locale.__e("flash:1382952379757"),
						//callback:function(sID:int):void {
							//var object:* = App.data.storage[sID];
							//App.user.stock.add(sID, object);
						//}
					//}).show();
				}else {
					//ShopMenu._currBtn = 1;
					winSettings = {
						title				:Locale.__e('flash:1396364590597'),
						text				:Locale.__e('flash:1396364608277', [App.data.storage[Factory.TECHNO_FACTORY].title]),
						buttonText			:Locale.__e('flash:1393577477211'),
						//image				:UserInterface.textures.alert_storage,
						image				:Window.textures.errorStorage,
						imageX				:-78,
						imageY				: -76,
						textPaddingY        : -18,
						textPaddingX        : -10,
						hasw             :true,
						faderAsClose        :true,
						faderClickable      :true,
						closeAfterOk        :true,
						bttnPaddingY        :25,
						ok					:function():void {
							new ShopWindow( { find:[Factory.TECHNO_FACTORY], forcedClosing:true } ).show();
						}
					};
					new ErrorWindow(winSettings).show();
				}
				
				
				return false;
			}
			
			return true;
		}
		
		private function glowing():void {
			if (!App.user.quests.tutorial) {
				customGlowing(background, glowing);
			}
			
			if (priceBttn) {
				if (App.user.quests.tutorial) {
					App.user.quests.currentTarget = priceBttn;
					trace(App.user.quests.currentTarget.caption);
					priceBttn.showGlowing();
					
					if (App.user.quests.currentQID == 5) {
						setTimeout(function():void {
							Tutorial.watchOn(priceBttn, 'bottom', false, { dx:0, dy:-100, arrow_dy:130, scaleX:1.2, scaleY:1.5} );
						}, 500);
					}else{
						priceBttn.showPointing("top", 0, 0, priceBttn.parent);
					}
				}else {
					
					
					if ((App.user.quests.data[103] && App.user.quests.data[103].finished == 0) || 			
						(App.user.quests.data[5] && App.user.quests.data[5].finished == 0)) {
							priceBttn.showPointing("bottom", 0, 30, this);
					}
					
					customGlowing(priceBttn);
				}
			}
		}
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}
	}
}	