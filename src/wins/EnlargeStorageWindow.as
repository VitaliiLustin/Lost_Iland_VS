package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	/**
	 * ...
	 * @author ...
	 */
	public class EnlargeStorageWindow extends Window 
	{
		private var back:Bitmap,
					preloader:Preloader = new Preloader(),
					bitmap:Bitmap,
					sID:String,
					action:Object,
					priceBttn:Button,
					actionCounter:int;
					
		public function EnlargeStorageWindow(settings:Object=null) 
		{
			settings['width'] = 505;
			settings['height'] = 345;
			settings['title'] = settings.title || Locale.__e('flash:1396521604876');
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			super(settings);	
			
			
			
			action = App.data.actions[settings.pID];
			action.id = settings.pID;
			for (var sid:* in action.items) {
				sID = sid;
			}
			countAction();
		}
		
		private function countAction():void
		{
			if (actionCounter<2) 
			{
				if (App.user.stock.count(365)) {
					actionCounter += App.user.stock.count(365);
				}
				if (actionCounter<2) 
				{
					if (World.getBuildingCount(365)) {
					actionCounter += World.getBuildingCount(365);
					}	
				}
				if (actionCounter >= 2) {
					actionCounter = 2;
				}
				if (actionCounter == 0) {
					actionCounter = 1;
				}
			}
		}
		
		override public function drawBackground():void
		{
			var background:Bitmap = backing(settings.width, settings.height, 25, 'questBacking');
			layer.addChild(background);
		}
		
		override public function drawBody():void
		{
			exit.y -= 20;
			drawIcon();
			
			back = backing(288, 220, 20, 'dialogueBacking');
				back.x = (settings.width - back.width) / 2 + 85;
				back.y = (settings.height - back.height) / 2 - 50;
				bodyContainer.addChild(back);
			
			var ribbon:Bitmap = backingShort(settings.width + 100, 'questRibbon');
				ribbon.x = (settings.width - ribbon.width) / 2;
				ribbon.y = 245;
				bodyContainer.addChild(ribbon);
			
			var textCont:Sprite = new Sprite();
			var ribbonText:TextField = drawText(Locale.__e("flash:1408441188465"), {
				fontSize	:34,
				autoSize	:"left",
				textAlign	:"center",
				color		:0xffffff,
				borderColor	:0x8140a7
			}); 
				textCont.addChild(ribbonText);
				textCont.filters = [new GlowFilter(0xab71cd, 1, 4, 4, 2, 1)];
				textCont.x = ribbon.x + (ribbon.width - textCont.width) / 2;
				textCont.y = ribbon.y + (ribbon.height - textCont.height) / 2 - 18;
				bodyContainer.addChild(textCont);
			
			
			var title:TextField = drawText(App.data.storage[sID].title, {
				fontSize	:32,
				autoSize	:"left",
				textAlign	:"center",
				color		:0xffffff,
				borderColor	:0x855729
			}); 
				title.x = back.x + (back.width - title.width) / 2;
				title.y = back.y + 20;
				bodyContainer.addChild(title);
			
			
			var description:TextField = drawText(App.data.storage[sID].description, {
				fontSize	:26,
				autoSize	:"center",
				textAlign	:"center",
				color		:0x624512,
				width		:260,
				wrap		:true,
				multiline	:true,
				borderSize	:0
			}); 
				description.x = back.x + (back.width - description.width) / 2;
				description.y = back.y + (back.height - description.height) / 2 + 15;
				bodyContainer.addChild(description);
			
			drawButton();
		}
		
		private function drawButton():void 
		{
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52,
				hasDotes:false
			};
			
			var text:String;
			switch(App.self.flashVars.social) {
				
				case "VK":
				case "DM":
						text = 'flash:1382952379972';
					break;
				case "OK":
						text = '%d ОК';
						//bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						//bttnSettings['fontColor'] = 0x3f2a1a;
						//bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;	
				case "ML":
						text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
						//bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						//bttnSettings['fontColor'] = 0x3f2a1a;
						//bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
				case "PL":
				case "YB":
						text = '%d';	
						//bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						//bttnSettings['fontColor'] = 0x3f2a1a;
						//bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
				case "FB":
						var price:Number = action.price[App.self.flashVars.social];
						price = price * App.network.currency.usd_exchange_inverse;
						price = int(price * 100 * (actionCounter+1)) / 100;
						text = price + ' ' + App.network.currency.user_currency;	
						
						//bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						//bttnSettings['fontColor'] = 0x3f2a1a;
						//bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
			}
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
				
			bttnSettings['caption'] = Locale.__e(text, [action.price[App.self.flashVars.social] * (actionCounter+1)])
			priceBttn = new Button(bttnSettings);
				priceBttn.x = (settings.width - priceBttn.width) / 2;
				priceBttn.y = settings.height - priceBttn.height / 2 - 15;
				bodyContainer.addChild(priceBttn);
			priceBttn.addEventListener(MouseEvent.CLICK, onBuy);
		}
		
		private function onBuy(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			switch(App.social) {
				case 'PL':
					//if(!App.user.stock.check(Stock.FANT, action.price[App.social])){
						//close();
						
						//break;
					//}
				case 'YB':
					if(App.user.stock.take(Stock.FANT, action.price[App.social] * (actionCounter+1))){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:action.id,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							onBuyComplete();
						});
					}else {
						close();
					}
					break;
				default:
					var object:Object;
					if (App.social == 'FB') {
						ExternalApi.apiNormalScreenEvent();
						object = {
							id:		 		action.id,
							type:			'promo',
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback:		onBuyComplete
						};
					}else{
						object = {
							count:			1,
							money:			'promo',
							type:			'item',
							item:			'promo_'+action.id,
							votes:			action.price[App.self.flashVars.social] * (actionCounter+1),
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback: 		onBuyComplete
						}
					}
					ExternalApi.apiPromoEvent(object);
					break;
			}
		}
		
		private function onBuyComplete(e:* = null):void 
		{
			priceBttn.state = Button.DISABLED;
			App.user.stock.addAll(action.items);
			
			for each(var item:* in action.items) {
				var bonus:BonusItem = new BonusItem(uint(sID), item);
				var point:Point = Window.localToGlobal(priceBttn);
					bonus.cashMove(point, App.self.windowContainer);
			}
			
			App.user.promo[action.id].buy = 1;
			App.user.buyPromo(action.id);
			App.ui.salesPanel.createPromoPanel();
			
			close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}
		
		private function drawIcon():void 
		{
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -40, true, true);
			drawMirrowObjs('storageWoodenDec', 0, settings.width, 45, false, false, false, 1, -1);
			
			var iconBack:Bitmap = new Bitmap(Window.textures.productionReadyBacking2);
			
			var icon:Bitmap;
			switch (int(sID)) 
			{
				case 139:
					icon = new Bitmap(Window.textures.warehouse);
					icon.x = -40;
					icon.y = (settings.height - icon.height) / 2 - 90;
					iconBack.x = icon.x + (icon.width - iconBack.width) / 2;
					iconBack.y = icon.y + (icon.height - iconBack.height) / 2;
				break;
				case 365:
					icon = new Bitmap(Window.textures.nectarsource);
					icon.x = -40;
					icon.y = (settings.height - icon.height) / 2 - 120;
					iconBack.x = icon.x + (icon.width - iconBack.width) / 2 - 30;
					iconBack.y = icon.y + (icon.height - iconBack.height) / 2 + 20;
				break;
			}
			bodyContainer.addChild(iconBack);
			bodyContainer.addChild(icon);
		}
		
	}

}