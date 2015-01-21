package wins.elements 
{

	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.Window;	
	
	public class Bar extends Sprite{
		
		public var bar:Bitmap;
		public var icon:Bitmap;
		public var _counter:TextField;
		public var slider:Sprite = new Sprite();
		public var have:int;
		public var all:int;
		
		private var sliderBmd:String = "energySlider";
			
		public function Bar(counter:String, have:int, all:int, icon:String = "energyIcon", bar:String = "energyBar", slider:String = "energySlider") {
			
			this.have = have;
			this.all = all;
			
			sliderBmd = slider;
			
			if(UserInterface.textures[icon] != undefined){
				this.icon = new Bitmap(UserInterface.textures[icon]);
			}else {
				this.icon = new Bitmap(Window.textures[icon]);
			}
			
			
			this.bar = new Bitmap(UserInterface.textures[bar]);
			
			_counter = Window.drawText(counter, {
				color:0x38342c,
				borderColor:0xf0e9db,
				fontSize:16,
				textAlign:"center"
			});
			
			_counter.width = 82;
			_counter.height = _counter.textHeight;
			
			UserInterface.slider(this.slider, have, all, slider);
			
			this.icon.x = this.bar.x - 11;
			this.icon.y = this.bar.y - 16;
			
			this.slider.x = this.bar.x + 41;
			this.slider.y = this.bar.y + 6;
			
			_counter.x = this.bar.x + 42;
			_counter.y = this.bar.y + 6;
			
			addChild(this.bar);
			addChild(this.icon);
			addChild(this.slider);
			addChild(_counter);
			
		}
		
		public function set counter(counter:String):void {
			_counter.text = counter;
			UserInterface.slider(this.slider, have, all, sliderBmd);	
		}
		
		public function glowing():void {
			TweenMax.to(icon, 0.3, { glowFilter: { color:0xa56eee, alpha:0.8, strength: 2, blurX:12, blurY:12 }, onComplete:function():void {
				
				TweenMax.to(icon, 0.2, { glowFilter: { color:0xa56eee, alpha:0, strength: 2, blurX:12, blurY:12 }, onComplete:function():void {
					icon.filters = [];
				}});
			}});
		}
		
		public function get point():Object {
			return { x:x, y:y };
		}
		
	}

}