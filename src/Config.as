package
{
	import core.CookieManager;
	import core.Debug;
	import core.Log;
	import core.MD5;
	import flash.utils.getTimer;

	public class Config
	{
		public static var _mainIP:Array;
		public static var _resIP:*;
		
		public static var _curIP:String;
		
		public static var testMode:int = 1;
		public static var resServer:uint = 0;
		
		public static var secure:String = "http://";
		
		public static var OK:Object = {
			secret_key:'F6E767AC1132279A92FD9549'
		};
		
		public static function get appUrl():String
		{
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':
					return 'http://vk.com/app4422631';
				break;	
				case 'ML':
					return 'http://my.mail.ru/apps/705236';
				break;
				case 'OK':
					return 'http://www.odnoklassniki.ru/game/1096157440';
				break;
				case 'FB':
					return 'http://www.odnoklassniki.ru/game/1096157440';
				break;
				default:
					return '';
				break;
			}
		}
		
		public function Config()
		{
			
		}
		
		public static function setServersIP(parameters:Object):void
		{
			var mainIP:Array;
			var resIP:Array;
			
			if(parameters.hasOwnProperty('mainIP')){
				mainIP = JSON.parse(parameters.mainIP) as Array;
				resIP = JSON.parse(parameters.resIP) as Array;
			}	
			
			Log.alert("mainIP: " + mainIP);
			Log.alert("resIP: " + resIP);
			
			switch(App.SERVER) {
				case "VK":
					_mainIP	= mainIP != null ? mainIP : ['l-vk2.islandsville.com', 'l-vk2.islandsville.com'];
				break;
				case "OK":
					_mainIP	= mainIP != null ? mainIP : ['l-ok2.islandsville.com', 'l-ok2.islandsville.com'];
				break;
				case "DM":
					_mainIP	= mainIP != null ? mainIP : ['lumeria.islandsville.com', 'lumeria.islandsville.com'];
				break;
				case "FB":
					_mainIP	= mainIP != null ? mainIP : ['l-fb.islandsville.com', 'l-fb.islandsville.com'];
				break;
				case "ML":
					_mainIP	= mainIP != null ? mainIP : ['l-mm1.islandsville.com', 'l-mm1.islandsville.com'];
				break;
				default:
					_mainIP	= mainIP != null ? mainIP : ['lumeria.islandsville.com', 'lumeria.islandsville.com'];
			}
			
			_mainIP	= ['lost.iland/server'];//mainIP != null ? mainIP : ['lumeria.islandsville.com', 'lumeria.islandsville.com'];
			_resIP 	= ['lost.iland/server'];//resIP  != null ? resIP  : ['lumeria.islandsville.com'];
			
			var resRand:int = int(Math.random() * _resIP.length);
			_resIP = _resIP[resRand];
			
			var rand:int = int(Math.random() * 2);
			
			_curIP = _mainIP[0];//_mainIP[rand];
			_mainIP.splice(_mainIP.indexOf(_curIP));
			
			Log.alert("_mainIP: " + _curIP);
			Log.alert('_resIP: ' + _resIP);
			
			CookieManager._domain = String(_mainIP);
		}
		
		public static function get randomKey():String {
			var pos:int = int(Math.random() * (31 - 13));
			
			return MD5.encrypt(String(getTimer()) + App.user.id).substring(pos, pos + 13);
		}
		
		public static function changeIP():Boolean {
			_curIP = _mainIP.shift();
			if (_curIP) {
				return true;
			}
			return false;
		}
		
		public static function getQuestIcon(type:String, icon:String):String {
			return secure + _resIP + '/resources/icons/quests/' + type + '/' + icon + '.png' + '?v='+version;
		}
		
		public static function getQuestAva(icon:String):String {
			return secure + _resIP + '/resources/icons/avatars/' + icon + '.png' + '?v='+version;
		}
		
		public static function getUrl():String {
			return secure + _curIP + '/';
		}
		
		public static function getData(lang:String = ""):String {
			return secure + _curIP + '/app/data/json/game.json?v=' + String(new Date().time);
		}
		
		public static function getLocale(lg:String):String
		{
		   return resources + 'locales/' + lg + '.csv?v=' + int(Math.random() * 1000);
		}
			
		public static function get resources():String {
			return secure + _resIP + '/resources/';
		}	
		
		public static function getIcon(type:String, icon:String):String {
			return secure + _resIP + '/resources/icons/store/' + type + '/' + icon + '.png'+"?v="+version;
		}
		
		public static function getImageIcon(type:String, icon:String, _type:String = 'png'):String {
			return secure + _resIP + '/resources/icons/' + type + '/' + icon + '.'+_type+"?v="+version;
		}
		
		public static function getImage(type:String, icon:String, _type:String = 'png'):String
		{
			return secure + _resIP + '/resources/images/' + type + '/' + icon + '.' + _type +"?v="+version;
		}
			
		private static var version:int = 111229312;//Math.random()*999999999;
		public static function getSwf(type:String, name:String):String 
		{
			return Config.resources +'swf/' + type + '/' + name + '.swf?v='+version;
		}
		
		public static function getInterface(type:String):String {
			return Config.resources +'interface/' + type + '.swf?v='+version;
		}
		
		public static function getDream(type:String):String
		{
			return Config.resources +'lands/' + type + '.swf?v='+version;
		}
		
		public static function setSecure(secureValue:String = "http://"):void {
			secure = secureValue;
		}
	}
}