package wins
{
	import buttons.MoneyButton;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author 
	 */
	public class ProgressBar extends Sprite
	{
		private var barL:Bitmap = new Bitmap(Window.textures.cookingPanelBarLeft); 
		private var barM:Bitmap = new Bitmap(Window.textures.cookingPanelBarM);
		private var barR:Bitmap = new Bitmap(Window.textures.cookingPanelBarRight);
		
		//private var cookingPanelBarBg:Bitmap = new Bitmap(Window.textures.cookingPanelBarBg);
		
		private var buyBttn:MoneyButton;
		private var timer:TextField;
		private var win:*;
		private var w:int;
		private var maska:Shape;
		
		private var Xs:int = 0;
		private var Xf:int = 0;
		
		public var bar:CookingPanelBar;
		private var delta:int;
		private var barWidth:int;
		
		private var timeFormat:uint = TimeConverter.H_M_S;
		
		private var isTimer:Boolean = true;
		
		private var timeSize:int;
		private var timeColor:int;
		private var timeborderColor:int;
		
		private var typeLine:String;
		
		public function ProgressBar(settings:Object)
		{
			this.w = settings.width;
			this.win = settings.win;
			timeSize = settings.timeSize || 24;
			timeborderColor = /*settings.borderColor || */0x613200;
			timeColor = /*settings.color || 0x38342c*/0xffffff;
			typeLine = settings.typeLine || 'yellowProgBarPiece';
			
			if(settings.hasOwnProperty('isTimer'))isTimer = settings.isTimer;
			
			timeFormat = settings.timeFormat || TimeConverter.H_M_S
			
			var container:Sprite = new Sprite();
			container.addChild(barL);
			container.addChild(barM);
			container.addChild(barR);
			
			var mediumBitmapData:BitmapData = new BitmapData(1, barM.height, true, 0);
			mediumBitmapData.copyPixels(barR.bitmapData, new Rectangle(0, 0, 1, barR.height), new Point(0, 0)); 
			barM.bitmapData = mediumBitmapData;
			
			barR.x = w - barL.width;
			barM.x = barL.width;
			barM.width = w - barR.width - barL.width;
			barM.y = 0;
			
			var bgBarBMD:BitmapData = new BitmapData(container.width, container.height, true, 0);
			bgBarBMD.draw(container);
			
			var bgBar:Bitmap = new Bitmap(bgBarBMD);
			container = null;
			//addChild(bgBar);
			
			barWidth = settings.width - 24;
			bar = new CookingPanelBar(barWidth, typeLine);
			bar.height = bar.height -2;
			addChild(bar);
			
			bar.x = 12;
			bar.y = 9;
			
			delta = -bar.width + 12;
			
			maska = new Shape();
			maska.graphics.beginFill(0x000000, 0.6);
			//maska.graphics.drawRect(10, 12, barWidth, bar.height-2);
			maska.graphics.drawRect(0, 0, barWidth+2, bar.height+1);
			maska.graphics.endFill();
			addChild(maska);
			maska.x = 12; 
			maska.y = 9;
			
			bar.mask = maska;
			bar.visible = false;
		
			if(isTimer){
			timer = Window.drawText(TimeConverter.timeToStr(127), {
				color:			timeColor,
				borderColor:	timeborderColor,
				fontSize:		timeSize
			});
			
			addChild(timer);
			timer.y = bar.height - timer.textHeight / 2 - 4;
			
			if (timeFormat == TimeConverter.H_M_S)
				timer.x = settings.width / 2 - 24;
			else
				timer.x = settings.width / 2 - 16;
			
			timer.x = (settings.width - timer.textWidth) / 2;
				
			timer.height = timer.textHeight;
			
			timer.visible = false;
			}
		}
		
		public function start():void
		{
			if(timer)timer.visible = true;
			bar.visible = true;
		}
		
		public function set time(value:int):void
		{
			if(timeFormat == TimeConverter.H_M_S)
				timer.text = TimeConverter.timeToStr(value);
			else
				timer.text = TimeConverter.minutesToStr(value);
		}
		
		public function set progress(value:Number):void
		{
			maska.width = barWidth * value;
		}
		
		public function dispose():void
		{
			win = null;
			bar.dispose();
		}
	}
}

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import wins.Window;

internal class CookingPanelBar extends Sprite
{
	private var bgL:Bitmap = new Bitmap(Window.textures.progressBarPink);//cookingBarL
	private var bgM:Bitmap = new Bitmap(Window.textures.cookingBarM);
	private var bgR:Bitmap = new Bitmap(Window.textures.cookingBarR);
	
	private var lines:Bitmap = new Bitmap(Window.textures.progressBar);//cookingPanelBarLines
	private var Xs:int = 0;
	private var maska:Shape;
		
	public function CookingPanelBar(_width:int, typeLine:String)
	{
		//addChild(bgL);
		//addChild(bgR);
		//addChild(bgM);
		
		var progress:Bitmap = Window.backingShort(_width, typeLine);
		addChild(progress);
		
		//bgM.width = _width - bgL.width - bgR.width;
		//bgM.x = bgL.width; 
		//bgR.x = _width - bgR.width; 
		//
		//addChild(lines);
		//Xs = _width + 10 - lines.width;
		//lines.x = Xs;
		//
		//maska = new Shape();
		//maska.graphics.beginFill(0x000000, 0.6);
		//maska.graphics.drawRoundRect(1, 1, _width-2, bgR.height-2, 15, 15);
		//maska.graphics.endFill();
		//addChild(maska);
		//
		//lines.mask = maska;
		
		//App.self.setOnEnterFrame(refresh);
	}
	
	private function refresh(e:Event = null):void
	{
		if (lines.x < Xs + 40)
		{
			lines.x += 1;
		}
		else
		{
			lines.x = Xs;
		}
	}
	
	public function dispose():void
	{
		App.self.setOffEnterFrame(refresh);
	}
	
	
}

