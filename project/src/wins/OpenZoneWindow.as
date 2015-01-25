package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MixedButton2;
	import buttons.MoneyButton;
	import buttons.UpgradeButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import wins.elements.OutItem;
	import wins.elements.UnlockItem;
	
	public class OpenZoneWindow extends Window
	{
		public static const OPEN_ZONE:uint = 1;
		public static const OPEN_WORLD:uint = 2;
		
		public var item:Object;
		
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		//public var applyBttn:UpgradeButton;
		public var applyBttn:Button;
		
		private var progressBar:ProgressBar;
		private var buyBttn:MoneyButton;
		//protected var neddLvlBttn:UpgradeButton = null;
		
		private var leftTime:int;
		private var started:int;
		private var totalTime:int;
		
		private var sID:uint;
		private var unlock:Object;
		private var container:Sprite;
		
		private var partList:Array = [];
		private var padding:int = 10;
		private var outItem:OutItem;
		
		private var mode:uint;
		
		public function OpenZoneWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			mode = settings.mode || OPEN_ZONE;
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 560;
			settings["height"] = 380;
			settings["popup"] = true;
			settings["fontSize"] = 42;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			
			if(mode == OPEN_ZONE)
				settings["description"] = Locale.__e("flash:1382952380234");
			else
				settings["description"] = Locale.__e("flash:1382952380232");
			
			//formula = App.data.crafting[settings.fID];
			sID = settings.sID;
			
			settings["title"] = App.data.storage[sID].title;
			
			unlock = settings["unlock"];
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
		}
		
		private function onStockChange(e:AppEvent):void 
		{
			removeItems();
			
			if (container && container.parent)
				container.parent.removeChild(container);
				
			container = null;
			
			createItems();
			
			container.x = (settings.width - container.width) / 2;
			container.y = 51;
			
			applyBttn.x = (settings.width - applyBttn.width) / 2;
			buyBttn.x = (settings.width - buyBttn.width) / 2;
			//neddLvlBttn.x = (settings.width - neddLvlBttn.width) / 2;
			
			/*if (neddLvlBttn.visible && buyBttn.visible) {
				buyBttn.x = settings.width / 2 - buyBttn.width - 10;
				neddLvlBttn.x = settings.width / 2 + 10;
			}*/
		}
		
		private function removeItems():void 
		{
			for (var i:int = 0; i < partList.length; i ++ ) {
				var it:MaterialItem = partList[i];
				it.parent.removeChild(it);
				it.dispose();
				it = null;
			}
			partList.splice(0, partList.length);
			
			if (buyBttn) {
				buyBttn.removeEventListener(MouseEvent.CLICK, onBuyPlace);
				buyBttn.dispose();
				buyBttn = null;
			}
			if (applyBttn) {
				applyBttn.removeEventListener(MouseEvent.CLICK, onOpenPlace);
				applyBttn.dispose();
				applyBttn = null;
			}
			//if (neddLvlBttn) {
				//neddLvlBttn.dispose();
				//neddLvlBttn = null;
			//}
		}
		
		public function drawDescription():void {
			
			//var backLine:Bitmap = Window.backing(background.width - 36, 42, 10, "questRewardBacking1");
			var backLine:Shape = new Shape();
			//backLine.graphics.lineStyle(2, 0x47424e, 1, true);
			backLine.graphics.beginFill(0xf2d1ae,1);
			backLine.graphics.drawRoundRect(0, 0, background.width - 56, 42, 42, 42);
			backLine.graphics.endFill();
			bodyContainer.addChild(backLine);
			backLine.x = background.x + (background.width - backLine.width) / 2;
			backLine.y = background.y + 14;
			
			var descriptionLabel:TextField = drawText(settings.description, {
				fontSize:22,
				color:0xffffff,
				borderColor:0x7c561b
			});
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = backLine.width  + 5;
			descriptionLabel.x = backLine.x + (backLine.width - descriptionLabel.textWidth) / 2 - 5;
			descriptionLabel.y = backLine.y + 8;
			
			bodyContainer.addChild(descriptionLabel);
		}
		
		override public function drawBackground():void {
			//var background:Bitmap = backing(settings.width, settings.height, 30, "windowBacking");
			//layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 7;
			exit.y = -7;
		}
		

		override public function drawBody():void {
			
			createItems();
			
			var backgroundWidth:int = partList.length * (partList[0].background.width + 5) - 5;
			if (backgroundWidth < 480) backgroundWidth = 480;
			background = Window.backing(backgroundWidth, 254, 10, "shopBackingSmall1");
			bodyContainer.addChildAt(background, 0);
			background.x = (backgroundWidth + 80 - background.width) / 2;
			background.y = 15;
			
			settings.width = backgroundWidth + 80//padding + backgroundWidth + 5 + partList[0].background.width + 40 + padding;
			drawDescription();
			
			var background2:Bitmap = backing2(settings.width, settings.height, 30, "shopBackingMain", "shopBackingMain1");
			layer.addChild(background2);
			
			exit.x = settings.width - exit.width + 12;
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y += 20;
			
			container.x = (settings.width - container.width) / 2;
			container.y = 51;
			
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -20, true, true);
			drawMirrowObjs('diamonds', 22, settings.width -22, settings.height - 115);
			drawMirrowObjs('diamonds', 22, settings.width - 22, 55, false, false, false, 1, -1);
			
			applyBttn.x = (settings.width - applyBttn.width) / 2;
			buyBttn.x = (settings.width - buyBttn.width) / 2;
			//neddLvlBttn.x = (settings.width - neddLvlBttn.width) / 2;
		}
		
		private function createItems():void
		{
			container = new Sprite();
			
			var offsetX:int = 0;
			var offsetY:int = 10;
			var dX:int = 5;
			
			var pluses:Array = [];
			var count:int = 0;
			for (var sID:* in settings.require) {
				if (App.data.storage[sID].type == "Zones") continue;
				var itemBack:Sprite = new Sprite();
				itemBack.graphics.beginFill(0xf2d1ae);
				itemBack.graphics.drawCircle(57, 57, 57);
				itemBack.graphics.endFill();
				//addChild(circle);
				container.addChild(itemBack);
				itemBack.x = offsetX+20;
				itemBack.y = offsetY+30;
				//if (App.data.storage[sID].type == "Zones") continue;
				var inItem:MaterialItem = new MaterialItem({
					sID:sID,
					need:settings.require[sID],
					window:this, 
					type:MaterialItem.IN,
					bitmapDY:-10
				});
				
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(inItem);
				
				
				container.addChild(inItem);
				inItem.x = offsetX;
				inItem.y = offsetY;
				
				offsetX += inItem.background.width + dX;
				inItem.background.visible = false;
				
				//if (count > 0) addPlus(container, inItem);
				
				count++;
			}
			
			var unlockItem:UnlockItem
			// Добавляем требование по друзьям
			/*if (unlock.friends != 0)
			{
				unlockItem = new UnlockItem( {
					title:Locale.__e("flash:1382952380181"),
					description:"",
					need:unlock.friends,
					count:App.user.friends.keys.length,
					iconUrl:Config.getIcon("Material", 'friends'),
					window:this, 
					type:MaterialItem.IN,
					bitmapDY:-10
				});
				
				unlockItem.checkStatus();
				unlockItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(unlockItem);
				
				container.addChild(unlockItem);
				unlockItem.x = offsetX;
				unlockItem.y = offsetY;
				
				offsetX += unlockItem.background.width + dX;
				unlockItem.background.visible = false;
				
				addPlus(container, unlockItem);
			}
			
			// Добавляем требование по уровню
			if (unlock.level != 0)
			{
				unlockItem = new UnlockItem( {
					title:Locale.__e("flash:1382952380233"),
					description:"",
					need:unlock.level,
					count:App.user.level,
					window:this, 
					iconUrl:Config.getIcon("Material", 'level'),
					type:MaterialItem.IN,
					bitmapDY:-10
				});
				
				unlockItem.checkStatus();
				unlockItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(unlockItem);
				
				container.addChild(unlockItem);
				unlockItem.x = offsetX;
				unlockItem.y = offsetY;
				
				offsetX += unlockItem.background.width + dX;
				unlockItem.background.visible = false;
				
				addPlus(container, unlockItem);
			}*/
			
			/*function addPlus(container:Sprite, inItem:*):void
			{
				var plus:Bitmap = new Bitmap(Window.textures.plus);
				container.addChild(plus);
				pluses.push(plus)
				plus.x = inItem.x - plus.width / 2;
				plus.y = inItem.background.height / 2 - plus.height/2;
			}
			
			
			var buyBttnSettings:Object = {
				recipeBttnName:Locale.__e("flash:1382952379890"),
				hasBuyBttn:true,
				onBuy:onBuy
			}
			
			//if (mode == OPEN_WORLD)
			//	buyBttnSettings['hasBuyBttn'] = false;
			
			outItem = new OutItem(onCook, buyBttnSettings);
			
			outItem.change({out:this.sID, iconUrl:Config.getIcon("Zones", 'zone')});
			container.addChild(outItem);
			
			outItem.x = offsetX;
			outItem.y = -36;//offsetY;
			
			var equality:Bitmap = new Bitmap(Window.textures.equality);
			container.addChild(equality);
			equality.x = outItem.x - equality.width / 2 - 2;
			equality.y = outItem.background.height / 2 - equality.height/2;*/
			
			applyBttn = new Button({
				caption				:Locale.__e('flash:1382952379890'),
				width				:220,
				height				:62,
				fontSize			:28,
				radius				:25,
				bgColor				:[0xf5cf57, 0xeeb431],
				borderColor			:[0xbcbaa6,0xbcbaa6],
				bevelColor			:[0xfeee7b,0xbf7e1a],	
				fontColor			:0xffffff,
				fontBorderColor		:0x814f31, 
				active: {
					bgColor			:[0xad9765,0xd1be88],
					borderColor		:[0x8b7a51,0x8b7a51],
					bevelColor		:[0x8b7a51,0xded4bf],	
					fontColor		:0xffffff,
					fontBorderColor :0x7a683c		
					}
			});
			applyBttn.y = settings.height - applyBttn.height - 30;
			bodyContainer.addChild(applyBttn);
			
			buyBttn = new MoneyButton({
					caption		:Locale.__e('flash:1382952380083'),
					width		:220,
					height		:62,
					fontSize	:28,
					radius		:25,
					countText	:App.data.storage[settings.sID].price[Stock.FANT],
					fontColor:0xffffff,
					fontBorderColor:0x4d7d0e,
					fontCountColor:0xffffff,				
					fontCountBorder:0x4d7d0e,
					
					bgColor     :[0xa8f84a,0x74bc17],
					bevelColor :[0xc8fa8f,0x5f9c11], 
					
					countText	:0,
					multiline	:true,
					iconScale : 1,
					fontCountSize : 32
				});
			bodyContainer.addChild(buyBttn);
			buyBttn.y = settings.height - buyBttn.height - 30;
			
			//neddLvlBttn = new UpgradeButton(UpgradeButton.TYPE_OFF,{
				//caption: Locale.__e("flash:1393579961766"),
				//width:236,
				//height:55,
				//icon:Window.textures.star,
				//countText:String(App.data.storage[settings.sID].level),
				//fontSize:24,
				//iconScale:0.95,
				//radius:20,
				//bgColor:[0xe4e4e4, 0x9f9f9f],
				//bevelColor:[0xfdfdfd, 0x777777],
				//fontColor:0xffffff,
				//fontBorderColor:0x575757,
				//fontCountColor:0xffffff,
				//fontCountBorder:0x575757,
				//fontCountSize:24,
				//fontBorderCountSize:4
			//})
			
			//bodyContainer.addChild(neddLvlBttn);
			//neddLvlBttn.x = (settings.width - neddLvlBttn.width) / 2;
			//neddLvlBttn.y = settings.height - neddLvlBttn.height + 5;
			
			buyBttn.addEventListener(MouseEvent.CLICK, onBuyPlace);
			applyBttn.addEventListener(MouseEvent.CLICK, onOpenPlace);
			
			bodyContainer.addChild(container);
			
			if (App.user.level < App.data.storage[settings.sID].level) {
				//neddLvlBttn.visible = true;
				buyBttn.visible = false;
				applyBttn.visible = false;
			}
			
			inItem.dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
		}
		
		private function onOpenPlace(e:MouseEvent):void 
		{
			App.user.world.openZone(sID);
			close();
		}
		
		private function onBuyPlace(e:MouseEvent):void 
		{
			
			if(!App.user.stock.take(Stock.FANT, App.data.storage[settings.sID].price[Stock.FANT]))
				return;
				
			App.user.world.openZone(sID, true);
			close();
		}
		
		public function onUpdateOutMaterial(e:WindowEvent):void {
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			
			if (App.user.level < App.data.storage[settings.sID].level) {
				//neddLvlBttn.visible = true;
				buyBttn.visible = true;
				applyBttn.visible = false;
			}
			else if (outState == MaterialItem.UNREADY) 
			{
				buyBttn.visible = true;
				applyBttn.visible = false;
				//neddLvlBttn.visible = false;
			}	
			else 
			{
				buyBttn.visible = false;
				applyBttn.visible = true;
				//neddLvlBttn.visible = false;
			}	
		}
		
		private function onCook(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			settings.openZone(sID);
			close();
		}
		
		private function onBuy(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			settings.openZone(sID, true);
			close();
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			
			removeItems();
			
			super.dispose();
		}
	}		
}