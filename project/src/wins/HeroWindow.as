package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.BottomPanel;
	import ui.UserInterface;
	import units.Hero;
	import units.Personage;
	import wins.elements.ShopItem;

	public class HeroWindow extends Window
	{
		public static const HEAD:String = 'head';
		public static const BODY:String = 'body';
		
		public var femaleBttn:ImageButton;
		public var maleBttn:ImageButton;
		public var saveBttn:Button;
		public var akaField:TextField;
		public var hero:Hero;
		
		public var heroBg:Bitmap;
		public var saveSttings:Object = { };
		
		public var preloader:Preloader = new Preloader();
		public var clothing:Object = null;
		
		private var items:Array = [];
		private var backing:Bitmap;
		public static var history:Object = {section:BODY, page:0};
		
		public function checkOnDressed(sID:uint):Boolean
		{
			for each(var sid:* in hero.cloth)
			{
				if (sid == sID) 
					return true;
			}
			
			return false;
		}
		
		public function HeroWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 670;
			settings["height"] = 485;
			settings["fontSize"] = 30;
			settings["hasPaginator"] = false;
			
			settings["title"] = Locale.__e("flash:1382952380148");
			
			saveSttings['sex'] = App.user.sex || 'm';
			saveSttings['aka'] = App.user.aka || App.user.first_name;
			
			settings["section"] = settings.section || history.section; 
			settings["page"] = settings.page || history.page;
			
			initContent();
			
			saveSttings.body = App.user.body;
			saveSttings.head = App.user.head;
			saveSttings.sex = App.user.sex;
			
			super(settings);
		}
		
		public function initContent():void {
			
			if (clothing != null) return;
			
			clothing = {
				'm':{
					'head':[],
					'body':[]
				},
				'f':{
					'head':[],
					'body':[]
				}
			};
			
			for (var id:String in App.data.storage)
			{
				if (App.data.storage[id].market == 8)
				{
					var item:Object = App.data.storage[id];	
					if (item.visible == 0) continue;
					
					item['sid'] = id;
					item['onStock'] = false;
					if (App.user.stock.count(int(id)) > 0)
						item['onStock'] = true;
					
					if (item.part == 1)
						clothing[item.sex]['head'].push(item);
					else
						clothing[item.sex]['body'].push(item);
				}
			}
			
			for (id in clothing.m) {
				clothing.m[id].sortOn('order', Array.NUMERIC);
			}
			for (id in clothing.f) {
				clothing.f[id].sortOn('order', Array.NUMERIC);
			}
		}
		
		override public function drawBackground():void {
			//var background:Bitmap = backing(settings.width, settings.height, 30, "itemBacking");
			//layer.addChild(background);
		}
		
		private var paginatorUp:Paginator;
		private var paginatorDown:Paginator;
		public function createPaginators():void
		{
			paginator = new Paginator(6, 6, 9, {
				hasArrow:true,
				hasButtons:true
			});
			
			paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  210,  240-5, { scaleX:-0.8, scaleY:0.8 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 220 + 412, 240-5, { scaleX:0.8, scaleY:0.8 } );
			
			bottomContainer.addChild(paginator);
		}
		
		private var headBttn:Button;
		private var bodyBttn:Button;
		
		private function createBttns():void
		{
			headBttn = new Button( {
									caption:				Locale.__e("flash:1382952380151"),
									mode:					HEAD,
									fontSize:				21,
									height:					30,
									width:					110,
									multiline:				true
								});
							
			bodyContainer.addChild(headBttn);
			
			headBttn.textLabel.y -= 2;
			headBttn.addEventListener(MouseEvent.CLICK, bttnClick);
			headBttn.x = 445 -  headBttn.width - 4;
			headBttn.y = 10;
			
			bodyBttn = new Button({
									caption:				Locale.__e("flash:1382952380153"),
									mode:					BODY,
									fontSize:				21,
									height:					30,
									width:					110,
									multiline:				true
								});
							
			bodyContainer.addChild(bodyBttn);								
			bodyBttn.textLabel.y -= 2;
			bodyBttn.addEventListener(MouseEvent.CLICK, bttnClick);
			bodyBttn.x = 449;
			bodyBttn.y = 10;
		}
		
		private function bttnClick(e:MouseEvent):void
		{
			changeRazdel(e.currentTarget.settings.mode);
		}
		
		private function changeRazdel(mode:String):void
		{
			settings.mode = mode;
			history.section = mode; 
			switch(mode)
			{
				case HEAD:
					headBttn.state = Button.ACTIVE;
					bodyBttn.state = Button.NORMAL;
				break;
				
				case BODY:
					headBttn.state = Button.NORMAL;
					bodyBttn.state = Button.ACTIVE;
				break;
			}
			
			contentChange();
		}
		
		override public function drawBody():void {
			
			createPaginators();
			
			createBttns();
			
			var heroDX:uint = 120-10;
			var heroDY:uint = 15;
			
			titleLabel.y = -14;
			
			var background:Bitmap = Window.backing(settings.width, settings.height, 30, "windowBacking");
			layer.addChild(background);
			
			exit.x = settings.width - exit.width + 12;
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			
			var akaBg:Shape = new Shape();
			akaBg.graphics.lineStyle(2, 0x5d5321, 1, true);
			akaBg.graphics.beginFill(0xddd7ae,1);
			akaBg.graphics.drawRoundRect(0, 0, 160, 25, 15, 15);
			akaBg.graphics.endFill();
			akaBg.x = heroDX - (akaBg.width) / 2;
			akaBg.y = 10 + heroDY;
			bodyContainer.addChild(akaBg);
			
			akaField = Window.drawText(saveSttings.aka, App.self.userNameSettings({
				color:0x4f4f4f,
				borderColor:0xfcf6e4,
				border:false,
				textAlign:"left",
				fontSize:20,
				multiline:true,
				input:true
			}));
			
			akaField.height = 22;
			akaField.maxChars = 20;
			akaField.x = akaBg.x + 6;
			akaField.y = akaBg.y + 2;
			bodyContainer.addChild(akaField);
			
			akaField.addEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
			akaField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutEvent);
			
			heroBg = Window.backing(180, 200, 30, "itemBacking");
			bodyContainer.addChild(heroBg);
			heroBg.x = heroDX - (heroBg.width) / 2;
			heroBg.y = 50 + heroDY;
			
			//hero = new Hero(App.user, { sid:Personage.HERO, x:10, z:10 } );
			hero = new Hero(App.user, { id:Personage.HERO, sid:Personage.HERO, x:10, z:10, alien:Hero.PRINCE } );
			hero.uninstall();
			hero.touchable = false;
			hero.clickable = false;
			bodyContainer.addChild(hero);
			hero.framesType = 'walk';
			hero.startAnimation();
			hero.x = heroBg.x + 90;
			hero.y = heroBg.y + 140;
			
			
			var sexLabel:TextField = Window.drawText(Locale.__e("flash:1382952380158"), {
				fontSize:20,
				autoSize:"left"
			});
			
			bodyContainer.addChild(sexLabel);
			sexLabel.x = heroDX - (sexLabel.width) / 2;
			sexLabel.y = heroBg.y + heroBg.height - 15 + heroDY; 
			
			var sexBg:Bitmap = Window.backing(160, 76, 30, "bonusBacking");
			bodyContainer.addChild(sexBg);
			sexBg.x = heroDX - (sexBg.width) / 2;
			sexBg.y = sexLabel.y + sexLabel.height - 4;
			
			femaleBttn = new ImageButton(UserInterface.textures.female);
			maleBttn = new ImageButton(UserInterface.textures.male);
			
			femaleBttn.addEventListener(MouseEvent.CLICK, onFemaleClick);
			maleBttn.addEventListener(MouseEvent.CLICK, onMaleClick);
			
			bodyContainer.addChild(maleBttn);
			maleBttn.x = sexBg.x + 10;
			maleBttn.y = sexBg.y + 12;
			
			bodyContainer.addChild(femaleBttn);
			femaleBttn.x = sexBg.x + 10 + maleBttn.width;
			femaleBttn.y = sexBg.y + 12;
			
			
			
			saveBttn = new Button( {
				width:145,
				height:45,
				fontSize:26,
				caption:Locale.__e("flash:1382952380160")
			});
			
			saveBttn.x = heroDX - (saveBttn.width) / 2;
			saveBttn.y = sexBg.y + sexBg.height + 16;
			
			bodyContainer.addChild(saveBttn);
			saveBttn.addEventListener(MouseEvent.CLICK, onSaveEvent);
			
			drawItems();
			
			
			if(settings.hasOwnProperty('find')){
				var target:Object = App.data.storage[settings.find];
				if (target.part == 1)
					history.section = HEAD;
				else	
					history.section = BODY;
			}
			
			settings.mode = history.section;
			
			bodyBttn.state = Button.ACTIVE;
			
			if (saveSttings.sex == 'm') {
				//onMaleClick();
				maleBttn.filters = [new GlowFilter(0xd5edf8, 1, 10, 10, 4)];
			}else {
				//onFemaleClick();
				femaleBttn.filters = [new GlowFilter(0xd5edf8, 1, 10, 10, 4)];
			}
			
			
			changeHero();
		}
		
		private function drawItems():void
		{
			backing = Window.backing(430, 380, 20, 'bonusBacking');
			
			bodyContainer.addChild(backing);
			backing.x = 220;
			backing.y = 45;
			
			paginator.x = backing.x + (backing.width - paginator.width) / 2;
			paginator.y = backing.y + backing.height + 23;
		}
		
		override public function contentChange():void
		{
			for (var m:int = 0; m < items.length; m++)
			{
				items[m].dispose();
				bodyContainer.removeChild(items[m]);
			}
			
			paginator.itemsCount = clothing[saveSttings.sex][settings.mode].length;
			paginator.update();
			
			items = [];
			var X:int = backing.x + 20;
			var Y:int = backing.y + 10;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:ClothItem = new ClothItem(clothing[saveSttings.sex][settings.mode][i], this);
				bodyContainer.addChild(item);
				item.x = X;
				item.y = Y;
				
				items.push(item);
				X += item.background.width;
				
				if (i % 3 == 2 && i>0)
				{
					X = backing.x + 20;
					Y += item.background.height + 14;
				}
			}
		}
		
		private function onFemaleClick(e:MouseEvent = null ):void {
			
			saveSttings.sex = 'f';
			maleBttn.filters = [];
			femaleBttn.filters = [new GlowFilter(0xfbd9df, 1, 10, 10, 4)];
			saveSttings.head = User.GIRL_HEAD;
			saveSttings.body = User.GIRL_BODY;
			changeHero();
		}
		
		private var loadCounter:uint = 0;
		private function changeHero():void
		{
			bodyContainer.addChild(preloader);
			preloader.x = heroBg.x + heroBg.width/2;
			preloader.y = heroBg.y + heroBg.height/2;
			
			loadCounter = 0;
			hero.change(saveSttings, onClothLoad);
			contentChange();
		}
		
		private function onClothLoad():void
		{
			loadCounter++;
			if (loadCounter == 2)
			{
				bodyContainer.removeChild(preloader);
			}
		}
		
		private function onMaleClick(e:MouseEvent = null):void {
			
			saveSttings.sex = 'm';
			saveSttings.head = User.BOY_HEAD;
			saveSttings.body = User.BOY_BODY;
			femaleBttn.filters = [];
			maleBttn.filters = [new GlowFilter(0xd5edf8, 1, 10, 10, 4)];
			changeHero();
		}
		
		private function onFocusInEvent(e:Event):void {
			
			if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				App.self.stage.displayState = StageDisplayState.NORMAL;
			}
			
			if(e.currentTarget.text == saveSttings.aka)	e.currentTarget.text = "";
		}
		
		private function onFocusOutEvent(e:Event):void {
			if(e.currentTarget.text == "" || e.currentTarget.text == " ") e.currentTarget.text = saveSttings.aka;
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		private function onSaveEvent(e:MouseEvent):void {
			saveSttings.aka = akaField.text;
			
			App.user.aka = saveSttings.aka;
			App.user.sex = saveSttings.sex;
			App.user.head = saveSttings.head;
			App.user.body = saveSttings.body;
			
			App.user.onProfileUpdate(saveSttings);
			App.user.hero.change(saveSttings);
			close();
			
			Nature.tryChangeMode();
		}
		
		override public function dispose():void {
			super.dispose();
			
			hero.stopAnimation();
			hero = null;
			
			akaField.removeEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
			akaField.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOutEvent);
			
			femaleBttn.removeEventListener(MouseEvent.CLICK, onFemaleClick);
			maleBttn.removeEventListener(MouseEvent.CLICK, onMaleClick);
			
			saveBttn.removeEventListener(MouseEvent.CLICK, onSaveEvent);
		}
		
		public function addCloth(sID:uint):void
		{
			for (var type:String in clothing[saveSttings.sex])
			{
				var L:uint = clothing[saveSttings.sex][type].length;
				for (var i:int = 0; i < L; i++)
				{
					if (clothing[saveSttings.sex][type][i].sid == sID)
					{
						clothing[saveSttings.sex][type][i].onStock = true;
						return;
					}
				}
			}
		}
		
		public function clothOff(sID:uint):void
		{
			if (App.data.storage[sID].part == 1){
				if (saveSttings.sex == 'm')	saveSttings.head = User.BOY_HEAD;
				else 						saveSttings.head = User.GIRL_HEAD;
			}else{
				if (saveSttings.sex == 'm')	saveSttings.body = User.BOY_BODY;
				else 						saveSttings.body = User.GIRL_BODY;
			}	
				
			changeHero();	
		}
		
		public function clothOn(sID:uint):void
		{
			if (App.data.storage[sID].part == 1)
				saveSttings.head = sID
			else
				saveSttings.body = sID
				
			changeHero();	
		}
	}
}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import wins.Window;

	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import units.Field;
	import units.Unit;
	import wins.elements.PriceLabel;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;

	internal class ClothItem extends Sprite {
		
		public var item:*;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		//public var preloader:Preloader;
		public var title:TextField;
		public var priceBttn:Button;
		public var openBttn:Button;
		public var clothBttn:Button;
		public var window:*;
		private var CY:uint = 70;
		
		public var moneyType:String = "coins";
		
		private var preloader:Preloader = new Preloader();
		
		public function ClothItem(item:*, window:*) {
			
			this.item = item;
			this.window = window;
			
			background = Window.backing(130, 168, 10, "textBacking");
			addChild(background);
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			
			sprite.tip = function():Object { 				
				return {
					title:item.title,
					text:item.description
				};
			};
			
			drawTitle();
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			
			if(!item['onStock']){
				if (item.hasOwnProperty('unlock') && App.user.level < item.unlock.level && App.user.shop[item.sid] == undefined) {
					drawOpenBttn();
				}else{
					drawPriceBttn();
				}
			}else{
				drawBuyedLabel();
			}
			
			if (window.settings.find != null && window.settings.find.indexOf(int(item.sid)) != -1) {
				glowing();
			}
			
			Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = 0.8;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = CY - (bitmap.height)/ 2
		}
		
		public function dispose():void {
			
			if(priceBttn != null){
				priceBttn.removeEventListener(MouseEvent.CLICK, onBuyEvent);
			}
			
			if(openBttn != null){
				openBttn.removeEventListener(MouseEvent.CLICK, onOpenEvent);
			}
			
			if(clothBttn != null){
				clothBttn.removeEventListener(MouseEvent.CLICK, onClothEvent);
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
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:20,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 50;
			title.y = 10;
			title.x = 25;
			addChild(title)
		}
		
		public function drawBuyedLabel():void {
			
			var labelSettings:Object = {
				text:"",
				fontSize:20,
				autoSize:"left"
			}
			
			var bttnSettings:Object = {
				caption:"",
				fontSize:22,
				width:94,
				height:30
			};
			
			if (window.checkOnDressed(item.sid))
			{
				bttnSettings.caption = Locale.__e("flash:1383041777718");
				bttnSettings.type = 1;
				labelSettings.text = Locale.__e("flash:1382952380162");
				labelSettings.fontSize = 24;
				labelSettings.borderColor = 0x85620d;
				labelSettings.color = 0xf0e6c1;
				
				background.filters = [new GlowFilter(0xFFFF00, 1, 15,15, 7, 1, true)]
			}
			else
			{
				bttnSettings.type = 0;
				bttnSettings.caption = Locale.__e("flash:1382952380163");
				bttnSettings.borderColor = [0x9f9171, 0x9f9171];
				bttnSettings.fontColor = 0x4c4404;
				bttnSettings.fontBorderColor = 0xefe7d4;
				bttnSettings.bgColor = [0xe3d5b5, 0xc0b292];
				
				labelSettings.text = Locale.__e("flash:1382952380080");
				labelSettings.fontSize = 20;
				
				background.filters = null;
			}
			
			clothBttn = new Button(bttnSettings);
			addChild(clothBttn);
			clothBttn.x = background.width/2 - clothBttn.width/2;
			clothBttn.y = background.height - 22;
			
			clothBttn.addEventListener(MouseEvent.CLICK, onClothEvent);
				
			//var label:TextField = Window.drawText(labelSettings.text, labelSettings);
			//addChild(label);
			
			//label.x = (background.width - label.width)/2;
			//label.y = background.height - 54;
			
			if (bttnSettings.type == 1) {
				clothBttn.visible = false
				/*switch(int(item.sid))
				{
					case User.BOY_BODY:
					case User.BOY_HEAD:
					case User.GIRL_BODY:
					case User.GIRL_HEAD:
						clothBttn.visible = false
					break	
				}*/
			}
			
			CY = 90;
		}
		
		private function onClothEvent(e:MouseEvent):void
		{
			if (e.currentTarget.settings.type == 1)
				window.clothOff(item.sid);
			else
				window.clothOn(item.sid);
		}
		
		public function drawPriceBttn():void {
			
			var icon:Bitmap;
			var price:int = 0;
			var settings:Object = { fontSize:16, autoSize:"left" };
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379751"),
				fontSize:22,
				width:94,
				height:30
			};
			
			if (item.coins > 0) {
				moneyType = "coins";
			}
			else
			{
				moneyType = "real";
			}	
			
			price = item[moneyType];
			
			var priceLabel:PriceLabel = new PriceLabel(price);
				priceLabel.x = (background.width - priceLabel.width)/2;
				priceLabel.y = background.height - 23 - priceLabel.height;
				addChild(priceLabel);
			
			if (moneyType == "real")
			{
				bttnSettings["bgColor"] 		= [0xA9DC3C, 0x96C52E];
				bttnSettings["fontColor"]	 	= 0x4E6E16;
				bttnSettings["fontBorderColor"] = 0xDCFA9B;
			}
			priceBttn = new Button(bttnSettings);
			addChild(priceBttn);
			priceBttn.x = background.width/2 - priceBttn.width/2;
			priceBttn.y = background.height - 22;
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyAction);
		}
		
		public function drawOpenBttn():void {
			
			var sprite:Sprite = new Sprite();
			
			var icon:Bitmap;
			var settings:Object = { 
				fontSize:22, 
				autoSize:"left",
				color:0xA3D637,
				borderColor:0x38510D
			};
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379890"),
				fontSize:22,
				bgColor: [0xA9DC3C, 0x96C52E],
				borderColor : [0xf8f2bd, 0x836a07],
				fontColor : 0x4E6E16,
				fontBorderColor : 0xDCFA9B,
				width:94,
				height:30,
				shadow:true
			};		
			
			var open:TextField = Window.drawText(Locale.__e("flash:1382952380083"), {
				color:0x4A401F,
				borderSize:0,
				fontSize:16,
				autoSize:"left"
			});
			sprite.addChild(open);
			open.x = 5;
			open.y = 10;
			
			icon = new Bitmap(UserInterface.textures.fantsIcon,"auto",true);
			icon.scaleX = icon.scaleY = 0.7;
				
			icon.x = open.x + open.width + 2;
			icon.y = 6;

			sprite.addChild(icon);
			
			var count:TextField = Window.drawText(String(item.unlock.price),settings);
			sprite.addChild(count);
			count.x = icon.x + icon.width + 2;
			count.y = 8;
			
			var needed:TextField = Window.drawText(Locale.__e("flash:1382952380085",[item.unlock.level]), {
				color:0xbf1a22,
				fontSize:16,
				borderColor:0xfcf5e5,
				textAlign:"center",
				borderSize:6
			});
			
			needed.width = 130;
			needed.height = needed.textHeight;
			sprite.addChild(needed);
			needed.x = 0;
			needed.y = -12;
			
			openBttn = new Button(bttnSettings);
			sprite.addChild(openBttn);
			openBttn.x = 16;
			openBttn.y = 35;
				
			sprite.y = 111;
			addChild(sprite);
					
			openBttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
		}
		
		private function onOpenEvent(e:MouseEvent):void {
			
			openBttn.removeEventListener(MouseEvent.CLICK, onOpenEvent);
			
			if (App.user.stock.take(Stock.FANT, item.unlock.price)) {
				
				Hints.minus(Stock.FANT, item.unlock.price, Window.localToGlobal(e.currentTarget), false, window);
				
				App.user.shop[item.ID] = 1;
				//window.contentChange();
				
				Post.send( {
					ctr:'user',
					act:'open',
					uID:App.user.id,
					sID:item.sid
				}, function(error:*, data:*, params:*):void {
					if (!error) {
						App.user.shop[item.sid] = 1;
						window.contentChange();
					}
				})
			}
		}
		
		private function onBuyAction(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			priceBttn.state = Button.DISABLED;
			App.user.stock.buy(item.sid, 1, onBuyEvent);
		}
		
		private function onBuyEvent(MONEY:uint, price:uint):void
		{
			var point:Point = localToGlobal(new Point(priceBttn.x, priceBttn.y));
			point.x += priceBttn.width / 2;
			Hints.minus(MONEY, price, point);
			
			window.addCloth(item.sid);
			window.contentChange();
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
					priceBttn.showPointing("top", priceBttn.width/2 - 15, 0, priceBttn.parent);
				}else {
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