package ui
{
	import adobe.utils.CustomActions;
	import com.greensock.TweenMax;
	import core.CookieManager;
	import core.Load;
	import core.Log;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class UserInterface extends Sprite
	{
		public static var textures:Object;
		public static var over:Boolean = false;
		
		public var bottomPanel:BottomPanel;
		public var upPanel:UpPanel;
		public var systemPanel:SystemPanel;
		public var rightPanel:RightPanel;
		public var leftPanel:LeftPanel;
		public var salesPanel:SalesPanel;
		
		public function UserInterface()
		{
			Load.loading(Config.getInterface('panels'), onLoad, 0, false,
			function(progress:Number):void{
				if(App.self.changeLoader != null) App.self.changeLoader('ui', progress);
			});
		}
		
		public function hideAll():void 
		{
			bottomPanel.hide();
			rightPanel.hide();
			salesPanel.hide();
			systemPanel.visible = false;
			leftPanel.visible = false;
			
			upPanel.hide();
			refresh();
		}
		
		public function refresh():void {
			if (App.user.quests.data[123] && App.user.quests.data[123].finished > 0) {
				//upPanel.showMiddle();
				bottomPanel.showMain();
				//App.ui.bottomPanel.show('mainPanel');
			}
			if (App.user.quests.data[5] && App.user.quests.data[5].finished > 0) {
				upPanel.showMiddle();
			}
			if (App.user.quests.data[6] && App.user.quests.data[6].finished > 0) {
				upPanel.showRight();
			}
			if (App.user.quests.data[8] && App.user.quests.data[8].finished > 0) {
				upPanel.showLeft();
			}
			if (App.user.quests.data[140] && App.user.quests.data[140].finished > 0) {
				bottomPanel.showIcons();
			}
		}
		
		public function showAll(e:AppEvent = null):void {
			bottomPanel.show();
			rightPanel.show();
			systemPanel.visible = true;
			upPanel.show();
			leftPanel.visible = true;
			App.self.removeEventListener(AppEvent.ON_FINISH_TUTORIAL, showAll);
		}
		
		private function onLoad(data:*):void {
			textures = data;

			Cursor.init();
			bottomPanel = new BottomPanel();
			upPanel = new UpPanel();
			systemPanel = new SystemPanel();
			rightPanel = new RightPanel();
			leftPanel = new LeftPanel();
			salesPanel = new SalesPanel();

			addChild(bottomPanel);
			addChild(upPanel);
			addChild(systemPanel);
			addChild(rightPanel);
			addChild(leftPanel);
			
			addChild(salesPanel);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onDownEvent);
			
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_UI_LOAD));
			
			resize();
			/*if (App.user.quests.tutorial) {
				hideAll();
				App.self.addEventListener(AppEvent.ON_FINISH_TUTORIAL, showAll);
			}*/
		}
		
		private function onDownEvent(e:MouseEvent):void {
			over = true;
		}
		
		public function resize():void 
		{
			bottomPanel.resize();
			rightPanel.resize();
			upPanel.resize();
			leftPanel.resize();
			systemPanel.resize();
			salesPanel.resize();
		}
		
		public static function slider(result:Sprite, value:Number, max:Number, bmd:String = "energySlider", useWindowTextures:Boolean = false):void {
			while (result.numChildren) {
				result.removeChildAt(0);
			}
			var slider:Bitmap;
			
			if(useWindowTextures)slider = new Bitmap(Window.textures[bmd]);
			else slider = new Bitmap(UserInterface.textures[bmd]);
			
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0x000000, 1);
			mask.graphics.drawRect(0, 0, slider.width, slider.height);
			mask.graphics.endFill();
			
			result.addChild(mask);			
			result.addChild(slider);
			
			slider.mask = mask;
			
			var percent:Number = value > max ? 1: value / max;
			var currentWidth:Number = slider.width * percent;
			
			mask.x = currentWidth - slider.width;
			mask.x = slider.x <= 0?mask.x:0;
		}
		
		public function glowing(target:*, color:uint = 0xFFFF00, callback:Function = null):void {
			TweenMax.to(target, 0.3, { glowFilter: { color:color, alpha:0.8, strength: 4, blurX:12, blurY:12 }, onComplete:function():void {
				
				TweenMax.to(target, 0.2, { glowFilter: { color:color, alpha:0, strength: 4, blurX:12, blurY:12 }, onComplete:function():void {
					target.filters = [];
					if (callback != null) {
						callback();
					}
				}});
			}});
		}
		
		public function flashGlowing(target:*, color:uint = 0xFFFF00, callback:Function = null, hasSound:Boolean = true):void 
		{
			TweenMax.to(target, 0.4, { glowFilter: { color:color, alpha:0.8, strength: 7, blurX:30, blurY:30 }, onComplete:function():void {
				TweenMax.to(target, 1, { glowFilter: { color:color, alpha:0, strength: 4, blurX:6, blurY:6 }, onComplete:function():void {
					target.filters = [];
					if (callback != null) {
						callback();
					}
				}});	
			}});
			
			if(hasSound)
				SoundsManager.instance.playSFX('glow');	
		}
		
		import silin.filters.ColorAdjust;	
		
		public static function effect(target:*, brightness:Number = 1, saturation:Number = 1):void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(saturation);
			mtrx.brightness(brightness);
			target.filters = [mtrx.filter];
		}
		
		public static function colorize(target:*, rgb:*, amount:*):void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.colorize(rgb, amount);
			target.filters = [mtrx.filter];
		}
		
		public function showNews(data:Object, name:String):void 
		{
			var news:NewsItem = new NewsItem(data, name);
				news.show();
		}
		
		public var globalLoader:GlobalLoader;
		public function addGlobalLoader():void {
			if (globalLoader != null)
				globalLoader.dispose();
				
			globalLoader = new GlobalLoader();
			globalLoader.show();
		}
		public function removeGlobalLoader():void {
			if(globalLoader != null)
				globalLoader.dispose();
				
			globalLoader = null;	
		}
	}
}

import flash.display.Sprite;
internal class GlobalLoader extends Sprite
{
	private var preloader:Preloader = new Preloader();
		
		public function GlobalLoader() 
		{
			drawBody();
		}
		
		private function drawBody():void 
		{
			addChild(preloader);
			preloader.scaleX = preloader.scaleY = 0.8;
			preloader.x = 50;
			preloader.y = 80;
			
			var txt:TextField = Window.drawText(Locale.__e("flash:1405331495038"), {
				color:0xffffff,
				borderColor:0x1d3b3d,
				fontSize:22,
				textAlign:"left"
			});
			addChild(txt);
			txt.width = txt.textWidth + 10;
			txt.x = preloader.x + preloader.width/2 + 10;
			txt.y = preloader.y - txt.textHeight/2;
			
		}
		
		public function dispose():void
		{
			if (preloader && preloader.parent)
				preloader.parent.removeChild(preloader);
				
			App.self.removeChild(this);	
		}
		
		public function show():void {
			App.self.addChild(this);
			this.x = (App.self.stage.stageWidth - this.width) / 2 - 20;
			this.y = (App.self.stage.stageHeight - this.height) / 2 - 40;
		}
}

import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenLite;
import core.CookieManager;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.text.TextField;
import wins.ShopWindow;
import wins.Window;

internal class NewsItem extends Sprite
{
	private var bg:Bitmap;
	public var exit:ImageButton
	private var data:Object;
	private var cookieName:String;
	
	public function NewsItem(data:Object, cookieName:String) {
		this.data = data;
		this.cookieName = cookieName;
		
		bg = Window.backing(300, 150, 50, 'windowBacking');
		addChild(bg);
		
		App.ui.addChild(this);
		this.x = App.self.stage.stageWidth - bg.width - 30;
		this.y = -200;
		
		exit = new ImageButton(Window.textures.closeBttn);
		exit.scaleX = exit.scaleY = 0.7;
		addChild(exit);
		exit.x = bg.width - 25;
		exit.y = 0;
		exit.addEventListener(MouseEvent.CLICK, onClose);
		
		drawIcon();
		drawTexts();
		drawBttn();
		
		App.self.setOnTimer(timer);
	}
	
	public function onClose(e:MouseEvent):void {
		if(ExternalInterface.available){
			CookieManager.store(this.cookieName, '1');
		}
		dispose();
	}
	
	public function show():void {
		TweenLite.to(this, 0.5, {y:60})
	}
	
	private var bttn:Button;
	private function drawBttn():void {
		bttn = new Button( {
			caption:Locale.__e('flash:1382952379751'),
			fontSize:22,
			width:94,
			height:30
		})
		addChild(bttn);
		bttn.x = 200 - bttn.width / 2;
		bttn.y = bg.height - bttn.height / 2 - 10;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var title:TextField;
	private var description:TextField;
	private var timeText:TextField;
	private function drawTexts():void {
		title = Window.drawText(item.title, {
			color:0xFFFFFF,
			borderColor:0x502f06,
			borderSize:4,
			fontSize:26,
			textAlign:"center",
			multiline:true
		});
		title.width = 140;
		title.height = title.textHeight;
		addChild(title);
		
		description = Window.drawText(data.description, {
			color:0xFFFFFF,
			borderColor:0x502f06,
			borderSize:4,
			fontSize:22,
			textAlign:"center",
			multiline:true,
			wrap:true
		});
		description.width = 140;
		description.x = 130;
		description.height = 130;
		addChild(description);
		
		var time:int = (data.time + data.duration * 3600) - App.time;
		timeText = Window.drawText(TimeConverter.timeToStr(time), {
			color:0xf7d64b,
			borderColor:0x502f06,
			borderSize:4,
			fontSize:36,
			textAlign:"center",
			multiline:true,
			wrap:true
		});
		
		timeText.width = 140;
		timeText.x = description.x;
		timeText.y = 70;
		timeText.height = 130;
		addChild(timeText);
	}
	
	private var item:Object;
	private var bitmap:Bitmap;
	private var sID:*;
	private function drawIcon():void {
		bitmap = new Bitmap();
		addChild(bitmap);
		for (sID in data.items) break;
			item = App.data.storage[sID];
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
	}
	
	private function onLoad(data:Bitmap):void
	{
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = 70 - bitmap.width / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
	}
	
	public function onClick(e:MouseEvent = null):void {
		dispose();
		new ShopWindow( { find:[sID] } ).show();
	}
	
	public function dispose(e:MouseEvent = null):void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
		exit.removeEventListener(MouseEvent.CLICK, dispose);
		App.self.setOffTimer(timer);
		App.ui.removeChild(this);
	}
	
	public function timer(e:MouseEvent = null):void {
		var time:int = (data.time + data.duration * 3600) - App.time;
		if (time < 0) {
			dispose();
		}
		timeText.text = TimeConverter.timeToStr(time);
	}
}
