package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	public class Hints
	{
		public static const ADD_MATERIAL:int 		= 1;
		public static const ADD_EXP:int 			= 2;
		public static const REMOVE_MATERIAL:int 	= 3;
		public static const ALERT:int 				= 4;
		public static const ENERGY:int 				= 5;
		public static const TEXT_RED:int			= 6;
		public static const BANKNOTES:int			= 7;
		public static const GEM:int			        = 8;
		public static const COINS:int			    = 9;
		
		public static var delay:uint				= 500;
		public static var flightDist:int			= -80;
		
		public static function getSettings(ID:int):Object {
			
			var settings:Object = {}
			switch(ID)
			{
				// + монеты и материалы
				case 1:
					settings = {
							color				:0xfff1cf,// 0xFFDC39,
							borderColor 		:0x482e16// 0x6D4B15
						};
					break;	
					
					// + опыт
				case 2:
					settings = {
							color				:0xebdff1,// 0xCC99FF,
							borderColor 		:0x5d0368// 0x330000
						};
					break;
					// - монеты
				case 3:
					settings = {
						//color				:0xfedb38,// 0xD21E27,
						//borderColor 		:0x6d4b15// 0x510000
						color				:0xfdd21e,// 0xFFDC39,
						borderColor 		:0x774702// 0x6D4B15
					};
					break;
					// alert
				case 4:
					settings = {
						color				: 0xeb4a2a,//0xE4454E,
						borderColor 		: 0x5d2511//0x510000
					};
					break;
					
					// energy
				case 5:
					settings = {
						color				:0xffdb65,// 0x6FB7D2,
						borderColor 		:0x775002// 0x142F8B
					};
					break;
					
					// energy
				case 6:
					settings = {
						color				: 0xD21E27,
						borderColor 		: 0x510000
					};
					break;
					
					// add banknotes	
				case 7:
					settings = {
						color				: 0x7fb4fa,//0xA3D637,
						borderColor 		: 0x382662
					};
					break;	
				case 8:
					settings = {
						color				: 0xffaec7,//0xc7f78e,//0xA3D637,
						borderColor 		: 0x931d4e//0x40680b
					};
					break;	
				case 9:
					settings = {
						color				: 0xfdd21e,//0xA3D637,
						borderColor 		: 0x774702
					};
					break;	
			}
			
				settings["borderSize"] 		= 4;
				settings["fontBorderGlow"] 	= 4;
				
				return settings;
		}
		
		public static function plus(sID:uint, count:uint, position:Point, _delay:Boolean = false, layer:Sprite = null, timeOut:int = 0):void
		{
			var settings_Numbs:Object;
			var settings_Text:Object;
			var hasTitle:Boolean = true;
						
			switch(App.data.storage[sID].view)
			{
				case "Reals":
					settings_Numbs 	= getSettings(Hints.GEM);
					settings_Text	= getSettings(Hints.GEM);
					break;
				case "Material":
					settings_Numbs 	= getSettings(Hints.ADD_MATERIAL);
					settings_Text	= getSettings(Hints.ADD_MATERIAL);
					break;
				case "honey":
					hasTitle = false;
					settings_Numbs 	= getSettings(Hints.ENERGY);
					settings_Text	= getSettings(Hints.ENERGY);
					break;
				case "coins":
					hasTitle = false;
					settings_Numbs 	= getSettings(Hints.COINS);
					settings_Text 	= getSettings(Hints.COINS);
					break;
				case "experience":
					hasTitle = false;
					settings_Numbs 	= getSettings(Hints.ADD_EXP);
					settings_Text 	= getSettings(Hints.ADD_EXP);
					break;
				case "ether":
					hasTitle = false;
					settings_Numbs 	= getSettings(Hints.ENERGY);
					settings_Text 	= getSettings(Hints.ENERGY);
					break;
				default:
					settings_Numbs 	= getSettings(Hints.ADD_MATERIAL);
					settings_Text 	= getSettings(Hints.ADD_MATERIAL);
					break
			}
			
			settings_Numbs['text'] =  "+" + count;
			if(hasTitle)
				settings_Text['text'] =  App.data.storage[sID].title;
			
			settings_Numbs['fontSize'] = 24;
			settings_Numbs['textAlign'] = 'right';
			settings_Text['fontSize'] = 16;
			settings_Text['textAlign'] = 'left';
			
			if (timeOut > 0)
				setTimeout(function():void {new Hint([settings_Numbs, settings_Text], _delay, position, layer); }, timeOut);
			else
				new Hint([settings_Numbs, settings_Text], _delay, position, layer);
		}
		
		public static function minus(sID:uint, price:uint, position:Point, _delay:Boolean = false, layer:Sprite = null, timeOut:int = 0):void
		{
			var settings_Numbs:Object;
			var settings_Text:Object;
			
			switch(sID)
			{
				case Stock.FANTASY:
					settings_Numbs 	= getSettings(Hints.ENERGY);
					settings_Text	= getSettings(Hints.ENERGY);
					break;
				case Stock.COINS:
					settings_Numbs 	= getSettings(Hints.COINS);
					settings_Text 	= getSettings(Hints.COINS);
					break;
				case Stock.FANT:
					settings_Numbs 	= getSettings(Hints.GEM);
					settings_Text 	= getSettings(Hints.GEM);
					break;
				case Stock.EXP:
					settings_Numbs 	= getSettings(Hints.ADD_EXP);
					settings_Text 	= getSettings(Hints.ADD_EXP);
					break;
				default:
					settings_Numbs 	= getSettings(Hints.REMOVE_MATERIAL);
					settings_Text 	= getSettings(Hints.REMOVE_MATERIAL);
					break
			}
			
			settings_Numbs['text'] =  "-"+price;
			settings_Text['text'] =  App.data.storage[sID].title;
			
			settings_Numbs['fontSize'] = 24;
			settings_Numbs['textAlign'] = 'right';
			settings_Text['fontSize'] = 16;
			settings_Text['textAlign'] = 'left';
			
			if (timeOut > 0)
				setTimeout(function():void {new Hint([settings_Numbs, settings_Text], _delay, position, layer); }, timeOut);
			else
			 new Hint([settings_Numbs, settings_Text], _delay, position, layer);
		}
		
		public static function text(text:String, type:int, position:Point, _delay:Boolean = false, layer:Sprite = null):void
		{
			var settings_Text:Object = getSettings(type);
					
			settings_Text['text'] =  text;
			settings_Text['fontSize'] = 16;
			settings_Text['textAlign'] = 'left';
			
			new Hint([settings_Text], _delay, position, layer);
		}
		
		public static function buy(target:*):void
		{
			var info:Object = target.info;
			var count:uint = 0;
			var sID:*;
			
			
			if (info.hasOwnProperty('instance')) {  
				var countOnMap:int = World.getBuildingCount(info.sid);
				var counter:int = 0;
				for(sID in info.instance.cost[countOnMap]){     //поменть относительно нескольких инстенсов
					count = info.instance.cost[countOnMap][sID];
					var point:Point = new Point(target.x*App.map.scaleX + App.map.x, target.y*App.map.scaleY + App.map.y);
					Hints.minus(sID, count, point, false, null, counter);
					counter += 500;
				}
			}else if (info.hasOwnProperty('price')) {
				for(sID in info.price){
					count = info.price[sID];
				}
				point = new Point(target.x*App.map.scaleX + App.map.x, target.y*App.map.scaleY + App.map.y);
				Hints.minus(sID, count, point);
			}
						
			//var point:Point = new Point(target.x*App.map.scaleX + App.map.x, target.y*App.map.scaleY + App.map.y);
			//Hints.minus(sID, count, point);
		}
		
		public static function plusAll(data:Object, position:Point, layer:Sprite):void
		{
			var count:uint = 0;
			var counter:int = 0;
			var sID:*;
			
			for(sID in data){    
				count = data[sID];
				Hints.plus(sID, count, position, false, layer, counter);
				counter += 500;
			}
		}

	}
}

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import com.greensock.*
	import com.greensock.easing.*;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;
	import wins.Window;
	import ui.Hints;
	
	internal class Hint extends Sprite
	{
		private var container:Sprite = new Sprite();
		private var bitmap:Bitmap;
		private var hintsLayer:Sprite;
		private var timer:Timer
		private var position:Point
		
		public function Hint(labels:Array, delay:Boolean, position:Point, layer:Sprite = null)
		{
			this.position = position;
			
			if (layer) 
				hintsLayer = layer;
			else	
				hintsLayer = App.self.tipsContainer;
				
			createLabels(labels);
			draw();
			
			if (delay == false)
			{
				init();
			}
			else
			{
				timer = new Timer(Hints.delay, 1);
				timer.addEventListener(TimerEvent.TIMER, onComplete);
				timer.start();
			}
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		private function init():void
		{
			move();
			this.x = position.x;
			this.y = position.y;
			hintsLayer.addChild(this);
		}
		
		private function draw():void
		{
			var bitmapData:BitmapData = new BitmapData(container.width, container.height, true, 0x00000000);
			var mt:Matrix = new Matrix();
			mt.translate(0, container.height/2);
			bitmapData.draw(container, mt);
			bitmap = new Bitmap(bitmapData);
			bitmap.smoothing = true;
			addChild(bitmap);
			bitmap.x = -bitmap.width / 2;
			container = null;
		}
		
		private function move():void
		{
			TweenLite.to(bitmap, 4, { y:Hints.flightDist, onComplete:moveComplete, ease:Strong.easeOut } );
			TweenLite.to(this, 2, { alpha:0, ease:Strong.easeIn } );
		}	
		
		private function onComplete(e:TimerEvent):void
		{
			timer.removeEventListener(TimerEvent.TIMER, onComplete);
			init();
		}
		
		
		private function createLabels(labels:Array):void
		{
			var X:int = 0;
			var Y:int = 0;
			for each(var label:Object in labels)
			{
				var textLabel:TextField = Window.drawText(
									label.text, 
									label);
									
					textLabel.x = X;				
					
					textLabel.width  = textLabel.textWidth + 4;
					textLabel.height = textLabel.textHeight + 4;
					
					textLabel.y = -textLabel.height / 2;
					
				container.addChild(textLabel);
				X += textLabel.width;
			}
		}
		
		private function moveComplete():void
		{
			if(hintsLayer.contains(this)){
				hintsLayer.removeChild(this);
			}
		}
	}

