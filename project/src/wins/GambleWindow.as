package wins 
{
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UserInterface;
	import units.Hut;

	public class GambleWindow extends Window
	{
		public var playBttn:MoneyButton;
		public var playFreeBttn:Button;
		public var items:Array = [];
		
		public function GambleWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 500;
			settings['height'] = 300;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
						
			settings['title'] = settings.target.info.title;
			
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
				
			if (!settings.target.tribute)
				settings['height'] = 350;
				
			settings.content = settings.target.info.slots;
			super(settings);
		}
		
		public var dX:uint = 160
		override public function drawBody():void {
			
			//titleLabel.y -= 15;
			titleLabel.x += dX;
			exit.x = background.x + background.width - 80;
			exit.y -= 15;
			var text:String = Locale.__e("flash:1382952380126");
			
			var descriptionLabel:TextField = drawText(text, {
				fontSize:22,
				//autoSize:"left",
				textAlign:"center",
				color:0x604729,
				borderColor:0xfaf1df,
				multiline:true
			});
			
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = 225;
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2 + dX;
			descriptionLabel.y = 64;
			
			bodyContainer.addChild(wheel);
			drawArrow();
			
			
			back = Window.backing(260, 180, 30, 'textBacking');
			back.x = 280;
			back.y = 40;
			
			bodyContainer.addChild(back);
			bodyContainer.addChild(descriptionLabel);
			drawBttns();
			Load.loading(Config.getSwf('Gamble', 'wheel'), drawWheel);
			
			if (!settings.target.tribute) {
				playFreeBttn.visible = false;
				playBttn.visible = true;
				drawTime();
			}
			else
			{
				playFreeBttn.visible = true;
				playBttn.visible = false;
			}
		}
		
		private var timeConteiner:Sprite;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		public function drawTime():void {
			
			timeConteiner = new Sprite();
			
			/*var background:Bitmap = Window.backing(220, 100, 10, "bonusBacking");
			timeConteiner.addChild(background);*/
						
			descriptionLabel = drawText(Locale.__e('flash:1382952380127'), {
				fontSize:26,
				textAlign:"center",
				color:0xf0e6c1,
				borderColor:0x502f06
			});
			
			descriptionLabel.width = 230;
			descriptionLabel.x = (descriptionLabel.width - 230)/2;
			descriptionLabel.y = 25;
			timeConteiner.addChild(descriptionLabel);
			
			var time:int = App.nextMidnight - App.time;
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:30,
				borderColor:0x502f06
			});
			timerText.width = 230;
			timerText.y = 50;
			timerText.x = 0;
			timeConteiner.addChild(timerText);
			
			timeConteiner.x = (settings.width - timeConteiner.width)/2 + dX;
			timeConteiner.y = 194;
			bodyContainer.addChild(timeConteiner);
			
			App.self.setOnTimer(updateDuration);
		}
		
		private function updateDuration():void {
			var time:int = App.nextMidnight - App.time;
				timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				descriptionLabel.visible = false;
				timerText.visible = false;
				playFreeBttn.visible = true;
				playBttn.visible = false;
			}
		}
		
		public var background:Bitmap;
		public var back:Bitmap;
		override public function drawBackground():void
		{
			background = Window.backing(settings.width, settings.height, 50, "windowActionBacking");
			layer.addChild(background);
			background.x += 100;
		}
		
		private function drawBttns():void {
			
			playBttn = new MoneyButton({
				caption		:Locale.__e("flash:1382952380128"),
				width		:170,
				height		:42,	
				fontSize	:26,
				countText	:settings.target.info.skip
			});
			
			playFreeBttn = new Button( {
				caption		:Locale.__e("flash:1382952380129"),
				width		:170,
				height		:42
			});
			
			bodyContainer.addChild(playBttn);
			bodyContainer.addChild(playFreeBttn);
			
			playBttn.x = (settings.width - playBttn.width) / 2 + dX;
			playBttn.y = back.y + back.height - playBttn.height - 20;
			
			playFreeBttn.x = playBttn.x;
			playFreeBttn.y = playBttn.y;
			
			playBttn.addEventListener(MouseEvent.CLICK, onPlayClick);
			playFreeBttn.addEventListener(MouseEvent.CLICK, onPlayFreeClick);
			
			playFreeBttn.state = Button.DISABLED;	
			playBttn.state = Button.DISABLED;	
		}
		
		private var wheel:Sprite = new Sprite();
		private function drawWheel(data:*):void {
			var wheelImg:Bitmap = new Bitmap(data.bmp);
			//wheelImg.scaleX = wheelImg.scaleY = 0.8;
			wheelImg.smoothing = true;
			wheelImg.x = -wheelImg.width / 2;
			wheelImg.y = -wheelImg.height / 2;
			
			wheel.addChild(wheelImg);
			wheel.x = 100;
			wheel.y = settings.height / 2 - 20;
			
			drawItems();
			
			if (!settings.target.tribute)
				wheel.y = settings.height / 2 - 40
				
			playFreeBttn.state = Button.NORMAL;	
			playBttn.state = Button.NORMAL;	
		}
		
		public var arrow:Bitmap
		private function drawArrow():void {
			arrow = new Bitmap(UserInterface.textures.arrow);
			bodyContainer.addChild(arrow);
			arrow.x = 245;
			arrow.y = 100;
		}
		
		private function drawItems():void {
			
			var num:uint = 0;
			for (var id:* in settings.content) {
				var item:WheelItem = new WheelItem(settings.content[id], this);
				items.push(item);
				
				wheel.addChild(item);
				var angle:Number = num * 360 / 12;
				item.angle 		= angle;
				item.rotation 	= angle;
				num ++;
			}
		}
		
		private function onPlayFreeClick(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED)
				return;
				
			exit.visible = false;
			e.currentTarget.state = Button.DISABLED;
			settings.onPlay(0, onPlayComplete);
		}
		
		private function onPlayClick(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			
			exit.visible = false;	
			e.currentTarget.state = Button.DISABLED;
			var X:Number = App.self.mouseX - e.currentTarget.mouseX + e.currentTarget.width / 2;
			var Y:Number = App.self.mouseY - e.currentTarget.mouseY;
				
			Hints.minus(Stock.FANT, settings.target.info.skip, new Point(X, Y), false, App.self.tipsContainer);
			
			settings.onPlay(1, onPlayComplete);
		}
		
		public function onPlayComplete(bonus:Object):void {
			var count:uint;
			for (var sID:* in bonus) {
				count = bonus[sID];
			}
			
			for each(var item:* in items) {
				if (item.sID == sID && item.count == count) {
					setWheelStopPoint(item);
				}
			}
		}
		
		private var winItem:WheelItem;
		private function setWheelStopPoint(item:WheelItem):void {
			
			trace(App.data.storage[item.sID].title);
			trace(item.count);
			trace(item.angle);
			winItem = item;
			
			var needRot:Number = 0 - item.angle + int(Math.random()*14) - 7;
			var circles:int = int(Math.random() * 5) + 3;
			var time:Number = 8;
			
			setTimeout(takeReward, (time - 1)*1000);
			TweenLite.to(wheel, time, { rotation:needRot + circles*360 , ease:Strong.easeOut} );
		}
		
		private function takeReward():void {
			winItem.take();
			exit.visible = true;
		}
		
		public function onWheelStop():void
		{
			playBttn.state = Button.NORMAL;
			playBttn.visible = true;
			playFreeBttn.visible = false;
		}
		
		public override function dispose():void{
			if(playFreeBttn) playFreeBttn.removeEventListener(MouseEvent.CLICK, onPlayFreeClick);
			if (playBttn) playBttn.removeEventListener(MouseEvent.CLICK, onPlayClick);
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
	}
}

import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class WheelItem extends Sprite
{
	private var text:TextField;
	private var icon:Bitmap;
	public var sID:uint;
	public var count:uint;
	public var angle:Number;
	public var bitmap:Bitmap;
	public var window:*;
	
	public function WheelItem(data:Object, window:*) {
		
		this.window = window;
		for (var sID:* in data) {
			var count:uint = data[sID];
		}
		
		this.sID = sID;
		
		var material:Object = App.data.storage[sID];
		this.count = count;
		text = Window.drawText(Numbers.moneyFormat(count), {
			color:0xe8dcb9,
			borderColor:0x5a4008,
			fontSize:22,
			textAlign:"center"
		});
		text.width = 80;
		text.height = text.textHeight;
		
		var cont:Sprite = new Sprite();
		cont.addChild(text);
		
		var bmd:BitmapData = new BitmapData(text.width, text.height, true, 0);
		bmd.draw(cont);
		
		bitmap = new Bitmap(bmd);
		addChild(bitmap);
		bitmap.x = 40;
		bitmap.y = -bitmap.height / 2;
		bitmap.smoothing = true;
		
		Load.loading(Config.getIcon(material.type, material.preview), onLoad);
	}
	
	public function take():void {
		
		var that:* = this;
		App.ui.flashGlowing(this, 0xFFFF00, function():void {
			var item:BonusItem = new BonusItem(that.sID, that.count);
			//var point:Point = Window.localToGlobal(that);
			var point:Point = new Point();
			point.x = App.self.mouseX - that.mouseX + 125;
			point.y = App.self.mouseY - that.mouseY;
			
			App.user.stock.add(sID, count);
			
			item.cashMove(point, App.self.windowContainer);
			
			that.window.onWheelStop();
		});
	}
	
	private function onLoad(data:Bitmap):void 
	{
		icon = new Bitmap(data.bitmapData);
		icon.scaleX = icon.scaleY = 0.45;
		icon.smoothing = true;
		addChild(icon);
		icon.x = bitmap.x + bitmap.width + 10 - icon.width/2;
		icon.y = -icon.height / 2;
	}
}