package wins.elements 
{

	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.TweenMax;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.Window;

	//Вспомогательный класс
	public class OutItem extends Sprite{
		
		public var background:Bitmap = null;
		public var bitmap:Bitmap = null;
		public var sID:String;
		
		public var title:TextField = null;
		public var timeText:TextField = null;
		public var recipeText:TextField = null;
		public var recipeBttn:Button;
		public var jamTick:LayerX;
		public var jamTickBitmap:Bitmap;
		public var icon:Bitmap
		public var buyBttn:MoneyButton
		public var fontSize:int = 22;
		private var price:uint = 0;
		public var preloader:Preloader = new Preloader();
		public var sprTip:LayerX = new LayerX();
		
		private var settings:Object = { 
			bttnText:Locale.__e("flash:1382952380036"),
			hasBuyBttn:false,
			onBuy:function():void { } 
		};
		
		public function OutItem(onCook:Function, settings:Object = null)
		{
			if (settings != null)
			{
				for (var key:* in settings)
					this.settings[key] = settings[key];
			}
			
			settings['bttnText'] = settings.recipeBttnName;
			
			background = Window.backing(170, 250, 10, "itemBacking");
			addChild(background);
			
			if (contains(sprTip)) {
				removeChild(sprTip);
				sprTip = new LayerX();
			}
			bitmap = new Bitmap();
			sprTip.addChild(bitmap);
			addChild(sprTip);
			
			title = Window.drawText("", {
				fontSize:24,
				color:0x814f31,
				borderColor:0xfaf9ec,
				textLeading: -6,
				multiline:true,
				textAlign:"center",
				//autoSize:"center",
				width:background.width - 50,
				wrap:true
			});
			
			addChild(title);
			title.wordWrap = true;
			
			title.y = 20;
			//removeChild(bitmap);
			
			//bitmap = new Bitmap();
			//addChild(bitmap);
			
			addChild(preloader);
			preloader.x = (background.width) / 2;
			preloader.y = (background.height) / 2;
			
			icon = new Bitmap(Window.textures.timerBrown);
			addChild(icon);
			
			icon.x = 32;
			icon.y = background.height - 77;
			
			timeText = Window.drawText("", {
				fontSize:28,
				color:0xfffef5,
				borderColor:0x693a2e
			});
			addChild(timeText);
			
			timeText.x = icon.x + icon.width + 5;
			timeText.y = icon.y + 3;
			
			recipeBttn = new Button( {
				width:128,
				fontSize:26,
				radius:14,
				caption:Locale.__e("flash:1382952380036"),
				fontSize:20,
				height:44
			});
			
			addChild(recipeBttn);
			recipeBttn.x = (background.width - recipeBttn.width) / 2;
			recipeBttn.y = background.height - recipeBttn.height / 2 - 14;
			recipeBttn.addEventListener(MouseEvent.CLICK, onCook)
			//var recipeText = Window.drawText(Locale.__e("flash:1382952380097"), {
				//fontSize:24,
				//color:0x814f31,
				//borderColor:0xfaf9ec,
				//textLeading: -6,
				//multiline:true,
				//textAlign:"center",
				////autoSize:"center",
				//width:background.width - 50,
				//wrap:true
			//});
			//addChild(recipeText);
			
			
			
			jamTick = new LayerX();
			jamTickBitmap = new Bitmap(UserInterface.textures.tick);
			jamTick.addChild(jamTickBitmap);
			addChild(jamTick);
			jamTick.x = background.width - jamTick.width + 10;
			jamTick.y = 0;
			jamTick.visible = false;
			jamTick.tip = function():Object { 
				return {
					title:"",
					text:""//Locale.__e("flash:1382952379767 варенья переполнен.")
				};
			};
			
			
			/*if (App.user.quests.currentQID == 8 && App.user.quests.currentMID == 1) {
				glowing();
			}*/
			
			if (settings.hasOwnProperty('formula') && settings.formula.count > 1)
				drawCount();
			
			if (!settings.hasBuyBttn) return;
			
			buyBttn = new MoneyButton({
					caption		:Locale.__e('flash:1382952379751'),
					width		:121,
					height		:42,
					fontSize	:22,
					radius		:16,
					fontColor:0xffffff,
					fontBorderColor:0x4d7d0e,
					fontCountColor:0xffffff,				
					fontCountBorder:0x4d7d0e,
					
					bgColor     :[0xa8f84a,0x74bc17],
					bevelColor :[0xc8fa8f,0x5f9c11], 
					
					countText	:0,
					multiline	:true
				});
				buyBttn.textLabel.x -= 2;
				buyBttn.coinsIcon.y -= 1;
				buyBttn.coinsIcon.x -= 1;
				buyBttn.countLabel.y += 3;
				buyBttn.countLabel.x += 3;
			addChild(buyBttn);
			
			buyBttn.x = (background.width - buyBttn.width) / 2;
			buyBttn.y = background.height - buyBttn.height / 2 - 8;
			buyBttn.addEventListener(MouseEvent.CLICK, settings.onBuy);
			
			buyBttn.visible = false;
		}
		
		public function change(formula:Object):void
		{
			
			if (title.parent != null) title.parent.removeChild(title);
			
			title = Window.drawText(App.data.storage[formula.out].title, {
				fontSize:24,
				color:0x814f31,
				borderColor:0xfaf9ec,
				textLeading: -6,
				multiline:true,
				textAlign:"center",
				//autoSize:"center",
				width:background.width - 40,
				wrap:true
			});
			addChild(title);
			title.x = (background.width - title.width) / 2;
			title.y = 20;
						
			//title.height = title.textHeight + 6;
			
			sID = formula.out;
			var iconUrl:String
			
			if (formula.hasOwnProperty('iconUrl'))
				iconUrl = formula.iconUrl;
			else
				iconUrl = Config.getIcon(App.data.storage[formula.out].type, App.data.storage[formula.out].preview); 
				
			Load.loading(iconUrl, onPreviewComplete);
			
			if (formula.time == null)
			{
				timeText.visible = false;
				icon.visible = false;
			}
			else
			{
				timeText.text = TimeConverter.timeToCuts(formula.time, true, true);
				timeText.height = timeText.textHeight + 6;
			}
			
			var info:Object = App.data.storage[sID];
			sprTip.tip = function():Object {
				return {
					title: info.title,
					text: info.description
				};
			}
			
			if (!settings.hasBuyBttn) return;
			
			price = 1;//info.unlock.price;
			buyBttn.count = String(price);
		}
		
		public function drawCount():void {
			var counterSprite:LayerX = new LayerX();
			counterSprite.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1382952380064")
				};
			};
			
			var countOnStock:TextField = Window.drawText("x "+settings.formula.count, {
				color:0xe9ddba,
				borderColor:0x2e3332,
				fontSize:18,
				autoSize:"left"
			});
			
			var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
			var bg:Bitmap = Window.backing(width, 40, 10, "smallBacking");
			
			
			counterSprite.addChild(bg);
			addChild(counterSprite);
			counterSprite.x = background.width - counterSprite.width + 8;
			counterSprite.y = 36;
			
			addChild(countOnStock);
			countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2;
			countOnStock.y = counterSprite.y + 10;
		}
			
		public function onPreviewComplete(obj:Object):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = obj.bitmapData;
			bitmap.smoothing = true;
			//if(bitmap.width>80){
				//bitmap.scaleX = bitmap.scaleY = 0.8;
			//}
			//bitmap.scaleX = bitmap.scaleY = 1.2;
			bitmap.y -= 10;
			sprTip.x = (background.width - bitmap.width) / 2;
			sprTip.y = (background.height - bitmap.height) / 2 - 5;
		}
		
		
		private function glowing():void {
			customGlowing(background, glowing);
			if (recipeBttn) {
				customGlowing(recipeBttn);
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