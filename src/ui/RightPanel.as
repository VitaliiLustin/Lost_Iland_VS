package ui 
{
	import api.ExternalApi;
	import buttons.ImagesButton;
	import core.CookieManager;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import wins.ChapterWindow;
	import wins.CollectionWindow;
	import wins.FreebieWindow;
	import wins.FreechoiseWindow;
	import wins.FreeGiftsWindow;
	import wins.FriendsWindow;
	import wins.GiftWindow;
	import wins.InviteSocialFriends;
	import wins.MapWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.TravelWindow;
	import wins.Window;
	
	public class RightPanel extends Sprite
	{
		
		public var bttnMainGifts:ImagesButton;
		public var bttnMainCollections:ImagesButton;
		public var bttnMap:ImagesButton;
		public var freebieBttn:ImagesButton;
		
		public var counterPanel:Bitmap;
		public var giftCounter:TextField;
		public var collCounter:TextField;
		
		private var giftCounterCont:Sprite
		private var collCounterCont:Sprite
		
		public function RightPanel():void 
		{
			bttnMainGifts = new ImagesButton(UserInterface.textures.interRoundBttn2, UserInterface.textures.giftsIcon,null, 0.8);
			bttnMainGifts.tip = function():Object {
				return {
					title:Locale.__e("flash:1382952379798"),
					text:Locale.__e("flash:1382952379799")
				};
			}
			addChild(bttnMainGifts);
			bttnMainGifts.addEventListener(MouseEvent.CLICK, onMainGifts);
			
			counterPanel = new Bitmap(UserInterface.textures.simpleCounterGreen);
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x35717d,
				fontSize:16,
				textAlign:"center"
			};
			
			giftCounter = Window.drawText(String(25), textSettings);
			giftCounter.width = 60;
			giftCounter.height = giftCounter.textHeight;
			giftCounter.x = counterPanel.width / 2 - 31;
			giftCounter.y = counterPanel.height / 2 - giftCounter.height / 2 - 1;
			//
			giftCounterCont = new Sprite();
			giftCounterCont.addChild(counterPanel);
			giftCounterCont.addChild(giftCounter);
			giftCounterCont.x = bttnMainGifts.x - 12;
			giftCounterCont.y = bttnMainGifts.y + 30;
			addChild(giftCounterCont);
			giftCounterCont.addEventListener(MouseEvent.CLICK, onMainGifts);
			
			update();
			resize();
		}
		
		public function hide():void {
			this.visible = false;
		}
		
		public function show():void {
			this.visible = true;
		}
		
		public function resize():void {
			this.x = App.self.stage.stageWidth - 63;
			this.y = App.self.stage.stageHeight - 126;
		}
		
		public function addFreebie(isAchive:Boolean = false):void {
			//return;
			
			if(App.social == 'PL' && !(App.self.flashVars.hasOwnProperty('platform') && App.self.flashVars.platform == 'nk'))
				return;
			
			if (freebieBttn != null)
				return;
				
			freebieBttn = getMoneyIcon(freebieBttn);
			
			if(App.user.freebie){
				freebieBttn.settings['ID'] = App.user.freebie.ID || 0;
			}
			if(!isAchive){
				freebieBttn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					freebieBttn.hideGlowing();
					freebieBttn.hidePointing();
					onFreebie(e);
				});
			}else {
				freebieBttn.addEventListener(MouseEvent.CLICK, onAchiveFreebe);
			}
			
			freebieBttn.y = bttnMainGifts.y - freebieBttn.height + 12;
			freebieBttn.x = -15;
			addChild(freebieBttn);

			if (App.user.settings.f == '0') {
				App.user.settings.f = '1';
				Post.addToArchive('freebie read: ' + App.user.settings.f);
				startGlow();
				App.user.settingsSave();
			}
			
			function startGlow():void {
				freebieBttn.showGlowing();
				freebieBttn.showPointing("top", 10, 90, freebieBttn);
			}
			///startGlow();
		}
		
		private function onAchiveFreebe(e:MouseEvent):void 
		{
			new InviteSocialFriends().show();
		}
		
		public function hideFreebie():void {
			removeChild(freebieBttn);
			freebieBttn.removeEventListener(MouseEvent.CLICK, onFreebie);
			freebieBttn = null;
		}
		
		private function onMainGifts(e:MouseEvent):void
		{
			if (App.user.gifts.length == 0)
				new FreeGiftsWindow().show();
			else		
				new FreeGiftsWindow( {
					mode:FreeGiftsWindow.TAKE
				}).show();
		}
		
		public function onMapClick(e:MouseEvent):void
		{
			var hasGuide:Boolean = false;
			if (App.user.stock.count(440) > 0)
				hasGuide = true;
			else {
				var guids:Array = Map.findUnits([440]);
				for each(var _guid:* in guids)
					if (_guid.level >= _guid.totalLevels)
						hasGuide = true;
			}
			
			if (hasGuide) {
				openTravelWindow();
			}
			else
			{
				new SimpleWindow( {
					title:Locale.__e('flash:1382952379804'),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e("flash:1382952379805"),
					popup:true,
					buttonText:Locale.__e("flash:1382952379806"),
					ok:function():void {
						new ShopWindow( { find:[440] } ).show();
					}
				}).show();
			}
		}
		
		private function openTravelWindow():void {
			if (App.user.mode == User.OWNER) {
				new TravelWindow().show();
			}else{
				new MapWindow({ 
					sID:441
				}).show();
			}
		}
		
		private function onFreebie(e:MouseEvent):void
		{
			var many:Boolean = false;
			var fast:Boolean = true;
			
			if(App.user.freebie == null || App.user.freebie.status == 1){
				fast = false;
			}
			
			if (fast) {
				new FreebieWindow( { ID:e.currentTarget.settings.ID } ).show();
			}
		}
		
		public function update():void
		{
			giftCounter.text = String(App.user.gifts.length);
			if (App.user.gifts.length == 0) 
				giftCounterCont.visible = false;	
			else 							
				giftCounterCont.visible = true;	
				
			/*collCounter.text = String(CollectionWindow.completed());
			if (Number(collCounter.text) == 0) 
				collCounterCont.visible = false;	
			else 							
				collCounterCont.visible = true;		*/
		}
		
		private function getMoneyIcon(bttn:ImagesButton):ImagesButton {
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(85, 85, true, 0), "auto", true);
			
			bttn = new ImagesButton(bitmap.bitmapData, UserInterface.textures.fantsIcon); 
			bttn.iconBmp.visible = false;
			bttn.visible = false;
			//bttn.addGlow(Window.textures.iconEff, 1, 0.7, 0x8cd72d);
			
			var title:TextField = Window.drawText(Locale.__e("flash:1382952380285"), {
				color:0xffffff,
				borderColor:0x0f3343,
				fontSize:18,
				textAlign:'center',
				multiline:true,
				width:70,
				distShadow:0
			});
			
			title.wordWrap = true;
			//title.border = true;
			title.height = title.textHeight + 4;
			
			Load.loading(Config.getImage('promo/icons', 'FreeRubyBacking'), function(data:*):void {
				bttn.bitmapData = data.bitmapData;
				
				bttn.addChild(title);
				title.x = (bttn.bitmap.width - title.width)/2;
				title.y = (bttn.bitmap.height - title.height) / 2 + 18;
				
				bttn.iconBmp.visible = true;
				bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = 1.1;
				bttn.iconBmp.smoothing = true;
				//bttn.iconBmp.x -= 5;
				bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width) / 2 + 1;
				bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2 - 3;
				//bttn.iconBmp.y -= 7;
				//bttn.glowIcon.visible = true;
				
				bttn.visible = true;
			});
			
			return bttn;
			
		}
		
		private var _mode:Boolean = User.OWNER;
		public function set mode(value:*):void {
			_mode = value;
			if (value == User.OWNER) {
				bttnMainGifts.visible = true;
				bttnMainCollections.visible = true;
				//bttnMap.visible = true;
				freebieBttn.visible = true;
				giftCounterCont.visible = true;
				collCounterCont.visible = true;
				bttnMap.y = /*bttnMainGifts.y*/1 - bttnMap.height - 7;
			}
			else
			{
				bttnMainGifts.visible = false;
				bttnMainCollections.visible = false;
				//bttnMap.visible = false;
				freebieBttn.visible = false;
				bttnMap.y = bttnMainCollections.y;
				giftCounterCont.visible = false;
				collCounterCont.visible = false;
			}
			
		}
	}
}