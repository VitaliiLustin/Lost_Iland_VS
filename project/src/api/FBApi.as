package api
{
	import api.com.adobe.json.JSONDecoder;
	import core.Log;
	import core.MultipartURLLoader;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import flash.events.Event;
	
	import com.adobe.images.PNGEncoder;
	import com.adobe.images.JPGEncoder;
	
	import api.com.adobe.crypto.MD5;
		
	public class FBApi
	{
		public var flashVars:Object;
		
		public var dictionary:Object = {
			
			0: function(sID:uint):Object {
					return{
						title:'',//App.data.storage[sID].title,
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			1: function(e:* = null):Object {
					return{
						title:Locale.__e("flash:1382952379697"),
						url:Config.getImage('mail', 'zone')
					}
			},
			2: function(sID:uint):Object {
					return{				
						title:Locale.__e("flash:1382952379698"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			3: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379699"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			4: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379700"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			5: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379701"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			6: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379702"),
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			},
			7: function(qID:uint):Object {
					return{				
						title:Locale.__e(App.data.quests[qID].description),
						url:Config.getQuestIcon('icons', App.data.personages[App.data.quests[qID].character].preview)
					}	
			},
			8: function(sID:uint):Object {
					return{				
						title:Locale.__e("flash:1382952379703"),
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			}
		}
				
		public var appFriends:Array = [];
		public var allFriends:Array = [];
		public var otherFriends:Object = {};
		public var profile:Object = { };
		public var friends:Object = { };
		public var albums:Object = { };
		public var currency:Object = { };
		

		public function FBApi(flashVars:Object)
		{
			Log.alert('Init FB API');
			this.flashVars = flashVars;
			if (ExternalInterface.available){
				ExternalInterface.addCallback("initNetwork", onNetworkComplete);
				ExternalInterface.call("initNetwork");
			}else {
				App.self.onNetworkComplete( {
					profile:flashVars.profile,
					appFriends:flashVars.appFriends
				});
			}
		}
		
		
		private function onNetworkComplete(data:*):void {
			for (var prop:String in data) {
				if(this[prop] != null)
					this[prop] = data[prop];
			}
			Log.alert(this);
			App.self.onNetworkComplete(this);
		}
		
			
		
		public function wallPost(params:Object):void {
			Log.alert(params);
			Log.alert('params');
			//params.msg = params.msg.replace(/http[^ ]+/, "");
			
			var obj:Object = dictionary[params.type](params.sID);
			var url:String = obj.url;
				
			if (ExternalInterface.available) {
				Log.alert('wallPost');
				ExternalInterface.call("wallPost", App.user.id, params.owner_id, obj.title, params.msg, url, null);
			}	
		}
		
		/*
		public function purchase(params:Object):void
		{
			
			if (ExternalInterface.available){
				ExternalInterface.addCallback("updateBalance", function():void {
					
					if (params.callback != null)
						params.callback();
						
					Post.send( {
						'ctr':'stock',
						'act':'balance',
						'uID':App.user.id
					}, function(error:*, result:*, params:*):void {
						if(!error && result){
							for (var sID:* in result){
								App.user.stock.put(sID, result[sID]);
							}
						}
					});
				});
				
				var service_name:String = "";
				var money:String = "";
				
				switch(params.money) {
					
					case "coins":
							service_name = App.data.storage[Stock.COINS].title;
							money = "coins";
						break;
					
					case "promo":	
							service_name = params.description;
							money = "promo";
						break;
						
					default:
							service_name = App.data.storage[Stock.FANT].title;
							money = "reals";
						break;	
				}
					
				var result:Array = params.item.split("_");
				var service_id:String = money + result[1];
					
				var obj:Object = {
					service_id:		service_id,
					service_name:	service_name,
					mailiki_price:	params.votes
				}
				
				ExternalInterface.call("purchase", obj);
			}
		}
		
		public function checkGroupMember(callback:Function):void {
			callback(1);
		}
		
		public function saveScreenshot(e:* = null):void {
			
			var scale:Number = 1;
			var W:int = 900;
			var H:int = 700;
			
			var screenBmd:BitmapData = new BitmapData(App.self.stage.stageWidth, App.self.stage.stageHeight);
			screenBmd.draw(App.self);
			
			var screenshot:BitmapData;
			
			if (App.self.stage.stageHeight > 700){
				scale = 0.5;
				screenshot = new BitmapData(App.self.stage.stageWidth * scale, App.self.stage.stageHeight * scale, true, 0);
				var matrix:Matrix = new Matrix();
				matrix.scale(scale, scale);
				
				screenshot.draw(App.self, matrix);
			}else{
				screenshot = new BitmapData(W, H, true, 0);
				screenshot.copyPixels(screenBmd, new Rectangle((App.self.stage.stageWidth - W )/2, 0, W, H), new Point());
			}
			
			var pngStream:ByteArray = PNGEncoder.encode(screenshot);
			
			var ldr:MultipartURLLoader = new MultipartURLLoader(); 
			ldr.addEventListener(Event.COMPLETE, function(e:Event):void {
				var response:Object = JSON.parse(e.currentTarget.loader.data);
				var url:String = response.url;
				
				var attach:Object = {
				  'url': response.url
				}
				
				e.currentTarget.dispose();
				
				if (ExternalInterface.available){
						ExternalInterface.call("saveToAlbum", attach);
				}
			});
			
			ldr.addFile(pngStream, "file", "image", "image/png");
			var pid:* = new Date().time;
			ldr.addVariable("crc",  MD5.hash('ytf$%$yuGFis*&udh' + pid));
			ldr.addVariable("pid",  pid);
			ldr.load("http://dreams.islandsville.com/ok/59b514174b/img.php");
			
			
		}
		*/
	}
}