package units
{
	import adobe.utils.CustomActions;
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.ContextMenu;
	import ui.Cursor;
	import ui.Hints;
	import ui.IconsMenu;
	import ui.UserInterface;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Firework extends Decor{

		public static var _boom:Boolean = false;
		public function Firework(object:Object)
		{
			layer = Map.LAYER_SORT;
			if (App.data.storage[object.sid].dtype == 1)
				layer = Map.LAYER_LAND;
			
			super(object);
			
			touchableInGuest = false;
			multiple = false;
			stockable = false;
			
			Load.loading(Config.getSwf(info.type, 'explode'), onLoadExplode);
		}
		
		private var explodeTextures:Object = null;
		private function onLoadExplode(data:*):void {
			explodeTextures = data;
		}
		
		override public function set touch(touch:Boolean):void 
		{
			if (!touchable) 
				return;
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			
			_touch = touch;
			
			if (touch) {
				if(state == DEFAULT){
					state = TOCHED;
				}else if (state == HIGHLIGHTED) {
					state = IDENTIFIED;
				}
				
			}else {
				if(state == TOCHED){
					state = DEFAULT;
				}else if (state == IDENTIFIED) {
					state = HIGHLIGHTED;
				}
			}
		}
		
		private var iconMenu:IconsMenu;
		override public function click():Boolean 
		{
			if (!super.click() || this.id == 0) return false;
			
			if (_boom == true) {
				return true;
			}
			var icons:Array = [];
			var dY:int = 0;
			icons.push( { status:true,	image:UserInterface.textures.fireworkIcon, 	callback:initBoom, params:sid, description:Locale.__e("flash:1383658502987")} );
			
			iconMenu = new IconsMenu(icons, this, hideTargets, dY);
			iconMenu.show();
			
			showTargets();
			return true;
		}
		
		public var damageTargets:Array = [];
		public var targets:Array = [];
		private function showTargets(params:Object = null):void 
		{
			hideTargets();
			var startX:int = coords.x - info.count;
			var startZ:int = coords.z - info.count;
			var finishX:int = coords.x + info.count;
			var finishZ:int = coords.z + info.count;
			
			if (startX < 0) startX = 0;
			if (startZ < 0) startZ = 0;
			
			if (finishX > Map.cells) finishX = Map.cells;
			if (finishZ > Map.rows) finishZ = Map.rows;
			
			for (var _x:int = startX; _x < finishX; _x++) {
				for (var _z:int = startZ; _z < finishZ; _z++) {
					var node:AStarNodeVO = App.map._aStarNodes[_x][_z];
					if (node.object != null && node.object is Resource) {
						if (targets.indexOf(node.object) == -1) {
							if (node.object.busy == true) continue;
							targets.push(node.object);
							node.object.state = HIGHLIGHTED;
						}
					}
				}
			}
		}
		
		private function hideTargets():void {
			for each(var target:Resource in targets) {
				target.state = DEFAULT;
			}
			targets = [];
		}
		
		private function generateDamage():void {
			
			var target:Resource;
			var damageLeft:int = info.capacity;
			
			var destroyed:Array = [];
			
			while (damageLeft > 0) {
				if (damageTargets.length <= destroyed.length) break;
				
				for (var i:int = 0; i < damageTargets.length; i++) {
					target = damageTargets[i];
					if (destroyed.indexOf(target) != -1) continue;
					if (target.capacity - target.damage > 0) {
						target.damage ++;
						damageLeft --;
						if (damageLeft <= 0) break;
					}
					else
					{
						destroyed.push(target);
					}
				}
			}
		}
		
		public function initBoom(params:Object = null):void {
			
			_boom = true;
			
			clickable = false;
			touchable = false;
			moveable = false;
			removable = false;
			rotateable = false;
			stockable = false;
			
			damageTargets = [];
			damageTargets = damageTargets.concat(targets);
			for each(var target:Resource in targets) {
				target.busy = 1;
				target.clickable = false;
			}
			startCountdown();
		}
		
		private function showExplodes():void {
			
			var counter:int = 0;
			var X:int = App.map.x;
			var Y:int = App.map.y;
			
			doExplode();
			var count:int = 0;
			var interval:int = setInterval(doExplode, 300);
			/*var move:int = setInterval(function():void {
				
				count++;
				if (count == 2) {
					count = 0;
					App.map.x = X;
					App.map.y = Y;
				}
				else
				{
					App.map.x = X + 200 - int(Math.random() * 400);
					App.map.y = Y + 200 - int(Math.random() * 400);
				}
				
			}, 100);*/
			
			function doExplode():void 
			{
				if (counter >= damageTargets.length)
				{
					clearInterval(interval);
					//clearInterval(move);
					_boom = false;
					return;
				}
				
				var target:Resource = damageTargets[counter];
				setTimeout(target.showDamage, 200);
				
				var explode:Explode = new Explode(explodeTextures);
				explode.filters = [new GlowFilter(0xffFF00, 1, 15, 15, 4, 3)];
				explode.x = target.x;
				explode.y = target.y - 100;
				counter ++;	
			}
			
			/*App.map.x += 200 - int(Math.random() * 400);
			App.map.y += 200 - int(Math.random() * 400);
			TweenLite.to(App.map, 1, { x:X, y:Y, ease:Elastic } );*/
		}
		
		private function boom(params:Object = null):void 
		{
			generateDamage();
			
			var _units:Array = [];
			
			for (var i:int = 0; i < damageTargets.length; i++) 
			{
				var target:Resource = damageTargets[i];
				var array:Array = [target.sid, target.id, target.damage];
				_units.push(array);
			}
			
			showExplodes();
			
			var that:*= this;
			
			Post.send({
				ctr:this.type,
				act:'boom',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				units:JSON.stringify(_units)
			}, function(error:*, data:*, params:*):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				App.ui.flashGlowing(that.bitmap);
				TweenLite.to(that, 1, { alpha:0, onComplete:uninstall } );
				Treasures.bonus(data.bonus, new Point(that.x, that.y));
			});	
		}
		
		private var countDown:TextField;
		private var counter:int = 4;
		private var cont:Sprite;
		private function startCountdown():void {
			cont = new Sprite();
			countDown = Window.drawText(String(counter), {
				color:0xffdc39,
				borderColor:0x6d4b15,
				textAlign:"center",
				fontSize:30,
				width:30
			});
			
			cont.addChild(countDown);
			countDown.x = -countDown.width / 2;
			countDown.y = -countDown.textHeight - 20;
			
			cont.x = 0;
			cont.y = -20;
			addChild(cont);
			
			doCountDown();
			interval = setInterval(doCountDown, 1000);
		}
		
		private var interval:int = 0;
		private function doCountDown():void {
			if (counter == 0) {
				clearInterval(interval);
				removeChild(cont);
				boom();
				return;
			}
			
			cont.scaleX = cont.scaleY = 1;
			//cont.alpha = 0.2;
			//TweenLite.to(cont, 1, { alpha:1 } );
			TweenLite.to(cont, 1, { scaleX:2, scaleY:2 } );
			
			counter--;
			countDown.text = String(counter);
		}
	}
}	


import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;

internal class Explode extends Sprite
{
	private var textures:Object = null;
	private var _parent:*;
	
	public function Explode(textures:Object) 
	{
		this.textures = textures;
		frame = 0;
		addAnimation();
		startAnimation();
		App.map.mTreasure.addChild(this);
	}
	
	private var frameLength:int = 0;
	private var framesType:String = 'explode';
	private var bitmap:Bitmap;
	
	public function addAnimation():void
	{
		frameLength = textures.animation.animations[framesType].chain.length;
		bitmap = new Bitmap();
		addChild(bitmap);
	}
	
	public function startAnimation(random:Boolean = false):void
	{
		frameLength = textures.animation.animations[framesType].chain.length;
		
		if (random) {
			frame = int(Math.random() * frameLength);
		}
		
		App.self.setOnEnterFrame(animate);
		animated = true;
	}
	
	public var animated:Boolean = false;
	
	public function stopAnimation():void
	{
		animated = false;
		App.self.setOffEnterFrame(animate);
	}
	
	public var frame:int = 0;
	public function animate(e:Event = null):void
	{
		//if (!SystemPanel.animate) return;
		var cadr:uint 			= textures.animation.animations[framesType].chain[frame];
		var frameObject:Object 	= textures.animation.animations[framesType].frames[cadr];
				
		bitmap.bitmapData = frameObject.bmd;
		bitmap.x = frameObject.ox;
		bitmap.y = frameObject.oy;
		bitmap.smoothing = true;
		
		frame ++;
		if (frame >= frameLength)
			dispose();
	}
	
	public function dispose():void {
		stopAnimation();
		App.map.mTreasure.removeChild(this);
	}
}