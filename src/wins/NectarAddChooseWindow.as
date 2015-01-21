package wins 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class NectarAddChooseWindow extends Window 
	{
		public var items:Array = new Array();
		public var handler:Function; 
		
		private var find:int = 0;
		public function NectarAddChooseWindow(settings:Object=null) 
		{
			var defaults:Object = {
				width: 496,
				height:332 ,
				hasPaper:true,
				title:Locale.__e("flash:1406535249022"),
				titleScaleX:0.76,
				titleScaleY:0.76,
				hasPaginator:true,
				hasArrows:false,
				hasButtons:false,
				shortWindow:false,
				useText:false,
				itemsOnPage:2,
				descWidthMarging:0,
				description:Locale.__e("flash:1382952380241"),
				closeAfterBuy:false,
				autoClose:true,
				popup:true
			};
			
			if (settings == null) {
				settings = new Object();
			}
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			
			settings = defaults;
			settings["noDesc"] = settings.noDesc || false;
			handler = settings.callback;
			if (settings.find != undefined) this.find = settings.find;
			super(settings);
		}
		
		override public function drawTitle():void {
		}
		
		override public function drawBackground():void {
		}
		
		private var descriptionLabel:TextField
		override public function drawBody():void {
			exit.y -= 20;
			var bg:Bitmap = backing(settings.width, settings.height, 45, "questBacking");
			layer.addChild(bg);
			
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			headerContainer.addChild(titleLabel);
			titleLabel.x = bg.x + (bg.width - titleLabel.width) / 2;
			titleLabel.y = bg.y - 20;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
			
			var storageWoodenDec:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
			var storageWoodenDec2:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
				storageWoodenDec.x = bg.x + 3;
				storageWoodenDec2.x = bg.x + bg.width - 3;
				storageWoodenDec.y = storageWoodenDec2.y = bg.y + 75;
				storageWoodenDec2.scaleX *= -1;
				storageWoodenDec.scaleY *= -1;
				storageWoodenDec2.scaleY *= -1;
			layer.addChild(storageWoodenDec);
			layer.addChild(storageWoodenDec2);
			
			var storageWoodenDec3:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
			var storageWoodenDec4:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
				storageWoodenDec3.x = bg.x + 3;
				storageWoodenDec4.scaleX *= -1;
				storageWoodenDec4.x = bg.x + bg.width - 3;
				storageWoodenDec3.y = storageWoodenDec4.y = bg.y + bg.height - 75;
			layer.addChild(storageWoodenDec3);
			layer.addChild(storageWoodenDec4);
			
			drawItems("energy");
			
			var furryBimtap:Bitmap = new Bitmap(Window.textures.errorStorage);
			furryBimtap.x = bg.x - furryBimtap.width  + 80;
			furryBimtap.y = bg.y + (bg.height - furryBimtap.height) / 2;
			layer.addChild(furryBimtap);
		}
	
		private var chooseItem:ChooseItem;
		private	var count:uint;
		private	var sid:uint;
		private	var itemX:int;
		
		private function drawItems(type:String):void 
		{	
			var itemsContainer:Sprite = new Sprite();
			
			for (var i:int = 0; i < 2; i++) 
			{
				count++;
				if (count == 1) {
					sid = 171;
				}else {
					sid = 169;
					
				}
				
				var chooseItem:ChooseItem = new ChooseItem(this, sid, count);
				chooseItem.x = itemX;
				
				itemsContainer.addChild(chooseItem);
				itemX += chooseItem.width - 10;
			}
			itemsContainer.x = (settings.width - itemsContainer.width) / 2 + 20;
			itemsContainer.y = (settings.height - itemsContainer.height) / 2 + 25;
			
			
				
			layer.addChild(itemsContainer);
				
		}
		
	}

}

import api.ExternalApi;
import api.OKApi;
import buttons.Button;
import core.Load;
import core.Log;
import core.Post;
import core.WallPost;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.NectarAddChooseWindow;
import wins.Window;
import wins.PurchaseWindow;
import wins.QuestRewardWindow;
import wins.AskWindow;

internal class ChooseItem extends Sprite
{
	public var sID:uint;
	public var count:uint;
	public var bitmap:Bitmap = new Bitmap();
	private var preloader:Preloader = new Preloader();
	private var backBitmap:Bitmap;
	private var shine:Bitmap;
	private var nectarAddChooseWindow:NectarAddChooseWindow;
	private var freeEnergyObj:Object = { };
	
	public function ChooseItem(window:*, sID:uint, count:uint)
	{
		this.sID = sID;
		nectarAddChooseWindow = window;
		this.count = count;
		backBitmap = Window.backing2(193, 246, 40, "purchItemBg1", "purchItemBg2");
		addChild(backBitmap);
		
		shine = new Bitmap(Window.textures.productionReadyBacking);
		shine.scaleX = shine.scaleY = 1.7;
		shine.x = backBitmap.x + (backBitmap.width - shine.width) / 2;
		shine.y = backBitmap.y + (backBitmap.height - shine.height) / 2 - 15;
		addChild(shine);
		
		
		addChild(bitmap);
		drawTitle();
		addChild(preloader);
		preloader.x = (backBitmap.width - preloader.width) / 2 + 53;
		preloader.y = (backBitmap.height - preloader.height) / 2 + 56;
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
		drawBttn();
		
		if (count == 2) {
			freeEnergyObj = JSON.parse(App.data.options.NotEnoughTreasure);
			for each(var key:* in freeEnergyObj) {
				break;
			}
			
			var freeCount:TextField = Window.drawText("+ " + key, {
				color:0xffdb65,
				borderColor:0x775002,
				fontSize:36,
				autoSize:"center",
				textAlign:"center"
			});
			
			freeCount.x = backBitmap.x + (backBitmap.width - freeCount.width) / 2;
			freeCount.y = backBitmap.y + (backBitmap.height - freeCount.height) / 2 + 60;
			addChild(freeCount);
		}
		
		
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 1;
		bitmap.smoothing = true;
		bitmap.x = (backBitmap.width - bitmap.width) / 2;
		bitmap.y = (backBitmap.height - bitmap.height) / 2 - 15
	}
	private var text:String;
	
	private function drawTitle():void
	{
		if (count == 1) {
			text = Locale.__e("flash:1406539311723");
		}else{
			text = Locale.__e("flash:1406539345347");
		}
		var title:TextField = Window.drawText(text, {
			color:0xffffff,
			borderColor:0x7a4b1f,
			wrap:true,
			multiline:true,
			fontSize:28,
			autoSize:"center",
			textAlign:"center"
		});
		title.x = backBitmap.x + (backBitmap.width - title.width) / 2;
		title.y = backBitmap.y - title.height / 3;
		addChild(title);
	}
	private var okBttn:Button;
	private var okBttnTextSize:int;
	private var okBttnText:String;
	
	private function drawBttn():void
	{
		if (count == 1) {
			okBttnText = Locale.__e("flash:1382952379751");
			okBttnTextSize = 32;
		}else {
			okBttnTextSize = 24;
			okBttnText = Locale.__e("flash:1406544603820");
		}
		okBttn = new Button( {
				borderColor		:[0xfeee7b,0xb27a1a],
				fontColor		:0xffffff,
				//textLabel.width: 80,
				worldWrap		:true,
				multiline 		:true,
				textAlign		:"center",	
				fontBorderColor	:0x814f31,
				bgColor			:[0xf5d159, 0xedb130],
				width			:157,
				height			:59,
				fontSize		:okBttnTextSize,
				hasDotes		:false,
				caption			:okBttnText
			});
			addChild(okBttn);
		//okBttn.textLabel.width = 80;
		okBttn.x = backBitmap.x + (backBitmap.width - okBttn.width) / 2;
		okBttn.y = backBitmap.y + backBitmap.height - okBttn.height / 2 - 10;
		
		okBttn.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
		if (count == 1) {
			new PurchaseWindow( {
				width:716,
				itemsOnPage:4,
				content:PurchaseWindow.createContent("Energy", {view:'Energy'}),
				title:Locale.__e("flash:1382952379756"),
				popup:true,
				description:Locale.__e("flash:1382952379757")
			}).show();
		}else {
			if (App.social == 'OK')
			{
				OKApi.showInviteCallback = function(e:Object):void {
					if (e.data && e.result != 'cancel') {
							Log.alert('showInviteCallback '+e.data+" "+e.result)
							addReward();
							OKApi.showInviteCallback = null;
					}
				}
				
				ExternalApi.apiInviteEvent();
				nectarAddChooseWindow.close();
				return
			}
			
			for (var key:* in App.network.otherFriends) {
				break;
			}
			
			if (App.social == "ML") {
				ExternalApi.apiInviteEvent({callback:addReward});
			}else {
				new AskWindow(AskWindow.MODE_NOTIFY,  { 
					title:Locale.__e('flash:1407159672690'), 
					inviteTxt:Locale.__e("flash:1407159700409"), 
					desc:Locale.__e("flash:1407159715497"),
					descY:30,
					height:530
				},  function(uid:String):void {
						ExternalApi.notifyFriend({uid:uid, text:Locale.__e('flash:1407155160192'), callback:addReward});
					} ).show();
			}
			
			
			
			//ExternalApi.notifyFriend({uid:/*App.user.friends.data[1].uid*/key, text:Locale.__e('привет'), callback:addReward});
			
			//WallPost.makePost(WallPost.GAME, { callBack:addReward } ); 
			
			//addReward();
			nectarAddChooseWindow.close();
		}
	}
	
	private function addReward(result:* = null):void
	{
		//if (!(result != null && result.hasOwnProperty('post_id')))
			//return;
			
		if (App.social == "ML") {
			var goThrow:Boolean = false;
			if (result.data) {
				if (result.data.length == 0)
					return;
				else 
					goThrow = true;
			}else if(!goThrow && result.status != "publishSuccess"){
				return;
			}
		}

		WallPost.onPostComplete(result);
			
		if(App.user.settings.notenough && App.user.settings.notenough.hasOwnProperty('t')){
			App.user.settings.notenough['t'] = App.time;
			var c:int = App.user.settings['notenough']['c'];
			c++;
			App.user.settings['notenough']['c'] = c;
		}else {
			App.user.settings['notenough'] = { };
			App.user.settings['notenough']['t'] = App.time;
			App.user.settings['notenough']['c'] = 1;
		}
		
		Post.statisticPost(Post.STATISTIC_INVITE);
		
		Post.send({
				'ctr':'user',
				'act':'viral',
				'uID':App.user.id,
				'type':'notenough'
			}, function(error:*, data:*, params:*):void {
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				
				var rewData:Object = { };
				rewData['character'] = 1;
				rewData['title'] = Locale.__e('flash:1406554650287');
				rewData['description'] = Locale.__e('ffff');
				rewData['bonus'] = { };
				rewData['bonus']['materials'] = data.bonus;
				
				
				new QuestRewardWindow( {
					data:rewData,
					levelRew:true,
					forcedClosing:true,
					strong:false,
					callback:function():void{}
				}).show();
				
				App.user.stock.addAll(data.bonus);
			});
	}
}
