package ui 
{
	import com.greensock.TweenLite;
	import core.Log;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	//import flash.utils.Timer;
	import wins.Window;
	
	public class ProgressBar extends Sprite
	{
		private var slider:Sprite = new Sprite();
		public var maxWidth:int;
		private var time:int;
		private var value:Number = 0;
		
		//public var maxValue:int;
		//private var times:int;
		//private var step:Number;
		//private var timer:Timer;
		
		private var _label:TextField;
		
		public function ProgressBar(time:uint, maxWidth:int) 
		{	
			this.maxWidth = maxWidth;
			this.time = time;
			//timer = new Timer(time);
			//timer.addEventListener(TimerEvent.)
			
			//times = int(time / 31);
			//step = maxWidth / (time / 31);
			
			var bitmap:Bitmap = new Bitmap(UserInterface.textures.progressBar);
			addChild(bitmap);
			slider.x = 4;
			slider.y = 3;
			addChild(slider);
			
			_label = Window.drawText("", {
				fontSize:18,
				color:0x583c10,
				border:false,
				autoSize:"left"
			});
			
			addChild(_label);
		}
		
		public function set label(text:String):void {
			_label.text = text;
			_label.x = (width - _label.width) / 2;
			_label.y = 0;
		}
		
		public function get label():String {
			return _label.text;
		}
		
		public function start():void {
			
			value = 0;
			UserInterface.slider(slider, value, maxWidth, "progressSlider");
			
			var childs:int = slider.numChildren;
			while (childs--) {
				var mask:* = slider.getChildAt(childs);
				if (mask is Shape) break;
			}
						
			TweenLite.to(mask, time, { x:0, onComplete:function():void {
				dispatchEvent(new AppEvent(AppEvent.ON_FINISH));
			}});
			
			//App.self.setOnEnterFrame(progess);
		}
		
		/*
		public function stop():void {
			App.self.setOffEnterFrame(progess);
		}
		
		public function progess():void {
			value += step;
			value = Math.round(value);
			UserInterface.slider(slider, value, maxWidth, "progressSlider");
			
			if (value >= maxWidth) {
				stop();
				dispatchEvent(new AppEvent(AppEvent.ON_FINISH));	
			}
			
			Log.alert('Progress: ' + value);
		}
		*/
		
	}

}