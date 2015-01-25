package wins 
{
	import adobe.utils.CustomActions;
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import core.Log;
	import core.Post;
	import core.WallPost;
	import effects.Particles;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import strings.Strings;
	import ui.UserInterface;
	
	public class LevelUpWindow extends Window
	{
		public var items:Array = new Array();
		public var label:Bitmap;
		public var tellBttn:Button;
		public var bg:Bitmap;
		public var screen:Bitmap;
		public var okBttn:Button;
		
		private var checkBox:CheckboxButton;
		
		private var isShort:Boolean = false;
		
		public function LevelUpWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}		
			settings['width'] = 440;
			settings['height'] = 380;
			
			settings['hasTitle'] = false;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['itemsOnPage'] = 3;
			
			settings['escExit'] = false;
			settings['faderClickable'] = false;
			settings['forcedClosing'] = false;
			//settings['popup'] = true;
			
			settings['bonus'] = App.data.levels[App.user.level].bonus;
			settings['content'] = [];
			settings['openSound'] = 'sound_7';
			
			for (var sID:* in App.data.storage)
			{
				var item:Object = App.data.storage[sID];
				
				if(item.visible != 0){
					if (item.level && App.user.level == item.level)
					{
						settings.content.push(sID);
					}else if (item.devel && item.devel.req[1].l == App.user.level) {
						settings.content.push(sID);
					}else if (item.instance && item.instance.level[1] == App.user.level) {
						settings.content.push(sID);
					}
				}
			}
			
			if (settings.content.length == 0) isShort = true;
			
			super(settings);
		}
		
		private var background:Bitmap;
		override public function drawBackground():void {
			
		}
		
		override public function drawArrows():void 
		{
				
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -0.6, scaleY:0.6 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:0.6, scaleY:0.6 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 44;
			paginator.arrowLeft.y = 218;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 24;
			paginator.arrowRight.y = 218;
			
		}
		
		override public function drawBody():void {
			exit.visible = false;
			
			
			
			var bgHeight:int = settings.height;
			if (isShort) {
				bgHeight = 214;
				this.y += 170;
				fader.y -= 170;
			}
			else{
				bg = Window.backing2(384, 162, 45, "questTaskBackingTop", "questTaskBackingBot");
				//bg.alpha = 0.4;
				bodyContainer.addChild(bg);
				bg.x = (settings.width - bg.width) / 2;
				bg.y = 140;
				
				var openTxt:TextField = Window.drawText(Locale.__e("flash:1393581153214"), {
				fontSize	:28,
				color		:0xfffde7,
				borderColor	:0x5d3c03
				});
				openTxt.width = openTxt.textWidth +5;
				openTxt.height = openTxt.textHeight;
				openTxt.x = settings.width/2 - openTxt.width/2 + 4;
				openTxt.y = bg.y - openTxt.textHeight / 2 - 4;
				bodyContainer.addChild(openTxt);
				
				this.y += 120;
				fader.y -= 120;
			}
			
			background = backing(settings.width, bgHeight, 78, "questsSmallBackingTopPiece");
			layer.addChildAt(background, 0);
			
			//var glowEffUnder:Bitmap = new Bitmap(Window.textures.glow2);
			//glowEffUnder.scaleX = glowEffUnder.scaleY = 1.8;
			//glowEffUnder.smoothing = true;
			//glowEffUnder.x = -170;
			//glowEffUnder.y = -300;
			//glowEffUnder.alpha = 0.8;
			//glowEffUnder.blendMode = BlendMode.OVERLAY;
			//layer.addChildAt(glowEffUnder,0);
			
			//var glowEff:Bitmap = new Bitmap(Window.textures.glow2);
			//glowEff.smoothing = true;
			//glowEff.x = 24;
			//glowEff.y = (bgHeight - glowEff.height) / 2;
			//glowEff.blendMode = BlendMode.OVERLAY;
			//
			//bodyContainer.addChildAt(glowEff, 0);
			
			
			
			
			drawBonusInfo();
			drawLevelInfo();
			okBttn = new Button( {
				borderColor:			[0xfeee7b,0xb27a1a],
				fontColor:				0xffffff,
				fontBorderColor:		0x814f31,
				bgColor:				[0xf5d159, 0xedb130],
				width:162,
				height:50,
				fontSize:32,
				hasDotes:false,
				caption:Locale.__e("flash:1393581174933")
			});
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, onTellBttn);
			
			//drawMirrowObjs('diamonds', -24, settings.width + 24, bgHeight - 87);
			
			
			okBttn.x = (settings.width - okBttn.width)/2;
			okBttn.y = bgHeight - okBttn.height + 16;
			
			
			checkBox = new CheckboxButton();
			bodyContainer.addChild(checkBox);
			checkBox.x = okBttn.x + 24;
			checkBox.y = okBttn.y - checkBox.height - 2;
			
			if(App.user.quests.tutorial){
				checkBox.checked = CheckboxButton.UNCHECKED;
				okBttn.showGlowing();
				okBttn.showPointing('right', 0,0, bodyContainer);	
			}
			
			//if (!isShort){
				paginator.itemsCount = settings['content'].length;
				paginator.update();
				contentChange();
			//}
			
			var that:LevelUpWindow = this;
			var time:int = 150;
			
			intervalEff = setInterval(function():void {
				var particle:Particles = new Particles();
				particle.init(layer, new Point(coordsEff[countEff].x, coordsEff[countEff].y));
				countEff++;
				if (countEff == 12)
					clearInterval(intervalEff);
			},time);
			
			if (App.data.levels[App.user.level].extra) {
				var extra:ExtraItem = new ExtraItem(this);
				bodyContainer.addChild(extra);
				extra.x = settings.width - extra.bg.width + 36;
				extra.y = background.height - extra.bg.height + 15;
			}
		}
		
		private var countEff:int = 0;
		private var intervalEff:int;
		private var coordsEff:Object = { 
			0:{x:40-100, y:-100},
			1:{x:100-100, y:-110},
			2:{x:160, y:-110},
			3:{x:220-100, y:-120},
			4:{x:380+100, y:-100},
			5:{x:260, y:-120},
			6:{x:190, y:-110},
			7:{x:60, y:-100},
			8:{x:120-100, y:-110},
			9:{x:200, y:-120},
			10:{x:250+100, y:-120},
			11:{x:360+100, y:-100},
			12:{x:220, y:-120}
		};
		
		private function onTellBttn(e:MouseEvent):void
		{
			if(checkBox.checked == CheckboxButton.CHECKED){
				
				WallPost.makePost(WallPost.LEVEL, { btm:screen, callBack:getExtraBonus } );
			}
			
			var checkMoneyLevel:Function = function(l:*, s:*) : Boolean {
					if(l == s)	return true;	
				return false;								
			}
			
			if (checkMoneyLevel(App.data.money.level, App.user.level) && App.user.money < App.time) {
				Post.send( {
					ctr:		'user',
					act:		'money',
					uID:		App.user.id,
					enable:		1
				}, function(error:int, data:Object, params:Object):void {
					if (error)
					{
						Errors.show(error, data);
						return;
					}
					App.user.money = App.time + (App.data.money.duration || 24) * 3600;
					
					new BankSaleWindow().show();
					App.ui.salesPanel.addBankSaleIcon(UserInterface.textures.saleBacking2);
				});	
			}
			
			var checkInviteLevel:Function = function(levels:String, s:*) : Boolean {
				var arr:Array = levels.split(',');
				for (var k:int = 0; k < arr.length; k++ ) {
					if (arr[k] == s)	
						return true;	
				}
				return false;								
			}
			
			bonusList.take();
			close();
			
			if (checkInviteLevel(App.data.options.InviteLevels, App.user.level)) {
				if (App.social == 'OK') {
					App.network.showInviteBox();
				}else if (App.social == 'ML') {
					//if(checkBox.checked != CheckboxButton.CHECKED)
						ExternalApi.apiInviteEvent();
				}else
					setTimeout(function():void { new InviteLostFriendsWindow( { } ).show(); }, 500);
			}
			
			//bonusList.take();
			//close();
		}
		
		private function getExtraBonus(result:* = null):void 
		{
			if (App.social == "ML" && result.status != "publishSuccess")
				return;
			
			Post.addToArchive('\n onPostComplete: ' + JSON.stringify(result));
			
			Post.statisticPost(Post.STATISTIC_WALLPOST);
			
			WallPost.onPostComplete(result);
			
			if (App.social == 'VK' && !(result != null && result.hasOwnProperty('post_id')))
				return;
				
			Post.send({
				'ctr':'user',
				'act':'viral',
				'uID':App.user.id,
				'type':'tell'
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
		
		override public function contentChange():void {
			
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var X:int = 28 + 28;
			var Y:int = 158 + 3;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:OpenedItem = new OpenedItem(settings.content[i], this);
				bodyContainer.addChild(item);
				items.push(item);
				item.x = X;
				item.y = Y;
				
				X += item.bg.width + 9;
			}
		}
		
		public var bonusList:RewardList;
		private function drawBonusInfo():void{
			
			bonusList = new RewardList(settings.bonus, true, 384, Locale.__e("flash:1382952380000"), 0.4, 28, 30);
			bodyContainer.addChild(bonusList);
			bonusList.x = (settings.width - bonusList.width)/2;
			bonusList.y = -15;
		}
		
		
		private function drawLevelInfo():void{
			var sprite:Sprite = new Sprite();
			
			label = new Bitmap(Window.textures.levelUpHeader);
			sprite.addChild(label);
			sprite.x = settings.width / 2 - label.width / 2;
			sprite.y = - 340;
			
			bodyContainer.addChild(sprite);
			
			var textSettings:Object = 
			{
				title		:String(App.user.level),
				fontSize	:24,//32,
				color		:0xfefdcf,
				borderColor	:0x7f5100,
				borderSize: 2,
				sharpness: 0,
				fontBorder	: 0,
				fontBorderGlow:0,
				textShadow	:0
			}
			
			var levelText:TextField = Window.drawText(Locale.__e("flash:1393581217883"), {
				fontSize	:44,//32,
				color		:0xfffde7,
				borderColor	:0x5b2a7a,
				fontBorderSize:1
				});
				levelText.width = levelText.textWidth +5;
				levelText.height = levelText.textHeight;
				levelText.x = sprite.width/2 - levelText.width/2 + 4;
				levelText.y = 290;
				sprite.addChild(levelText);
				
			textSettings.fontSize = 58;	
			//textSettings.color = 0x000000;
			//textSettings.borderColor = 0x000000;
			textSettings['textAlign'] = 'center';	
			//textSettings.fontBorderSize = 12;
		
			var leveleTitle:Sprite = titleText(textSettings);	
				leveleTitle.x = sprite.width/2 - leveleTitle.width/2 + 4;
				leveleTitle.y = 220;
				
				sprite.addChild(leveleTitle);
			
			var addBackToImage:Function = function(_cont:Sprite, width:Number, height:Number):void
			{
				var sp:Sprite = new Sprite();
				sp.graphics.beginFill(0xffffff);
				sp.graphics.drawRect(0, 0, width, height);
				sp.graphics.endFill();		
				_cont.addChildAt(sp, 0);
				
				//back.x = (width - back.width)/2 + back.width / 2;
				//back.y = (_cont.height - back.height)/2;
			}	
			//
			
			
			
			screen = new Bitmap(new BitmapData(sprite.width, sprite.height));
			screen.bitmapData.draw(sprite);
			
		}
		
		override public function dispose():void
		{	
			clearInterval(intervalEff);
			super.dispose();
		}
	}
}

import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class OpenedItem extends Sprite
{
	public var bg:Bitmap = Window.backing(104, 124, 30, "itemBacking2");
	public var sID:uint;
	public var bitmap:Bitmap = new Bitmap();
	public var window:*;
	private var preloader:Preloader = new Preloader();
	
	public function OpenedItem(sID:uint, window:*)
	{
		this.sID = sID;
		this.window = window;
		//addChild(bg);
		//var backBitmap:Bitmap = new Bitmap(Window.textures.levelUpOpenBacking);
		var backBitmap:Bitmap = Window.backing(100, 125, 5, 'levelUpOpenBacking');
		addChild(backBitmap);
		addChild(bitmap);
		drawTitle();
		addChild(preloader);
		preloader.x = (bg.width - preloader.width) / 2 + 43;
		preloader.y = (bg.height - preloader.height) / 2 + 46;
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.5;
		bitmap.smoothing = true;
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 + 4;
	}
	
	private function drawTitle():void
	{
		var title:TextField = Window.drawText(App.data.storage[sID].title, {
			color:0x814f31,
			textLeading: -5,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:18,
			multiline:true
		});
		
		title.wordWrap = true;
		title.width = bg.width;
		title.y = 6;
		title.x = -2;
		addChild(title);
	}
}

import wins.RewardList;

internal class ExtraItem extends Sprite
{
	public var extra:Object;
	public var bg:Bitmap;
	
	public function ExtraItem(window:*) 
	{
		extra = App.data.levels[App.user.level].extra;
		
		bg = Window.backing(164, 92, 38, "tutorialDialogueBacking");
		addChild(bg);
		
		drawTitle();
		drawReward();
	}
	
	private function drawTitle():void 
	{
		var title:TextField = Window.drawText(Locale.__e("flash:1406545004234"), {
			fontSize	:18,
			color		:0x673a1f,
			borderColor	:0xffffff,
			textAlign   :'center',
			multiline   :true,
			wrap        :true
		});
		title.width = bg.width - 10;
		title.x = 5
		title.y = 6;
		
		addChild(title);
	}
	
	private function drawReward():void 
	{
		var reward:RewardList = new RewardList(extra, false, 0, '', 1, 44, 16, 32, "x", 0.6, -6, 7);
		addChild(reward);
		reward.x = 25;
		reward.y = bg.height - reward.height - 10;
		
		var icon:Bitmap = new Bitmap(Window.textures.vaultFury);
		addChild(icon);
		icon.x = 114;
		icon.y = -72;
	}
}
