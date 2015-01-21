package 
{
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.SystemPanel;
	import units.Pigeon;
	import wins.ShopWindow;
	import wins.VisitWindow;
	import wins.WindowEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class Travel 
	{
		private static var visitWindow:VisitWindow;
		
		public static function goHome(e:MouseEvent = null):void {
			App.user.onStopEvent();
			App.ui.bottomPanel.bttnMainHome.hideGlowing();
			App.ui.bottomPanel.showOwnerPanel();
			App.ui.leftPanel.hideGuestEnergy();
			
			visitWindow = new VisitWindow({title:Locale.__e("flash:1382952379776")});
			visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, loadHome);
			visitWindow.show();
		}
		private static function clearWorlds():void {
			if (App.owner) {
				App.owner.world.dispose();
				App.owner = null;
			}
			if (App.map) {
				App.map.dispose();
				App.map = null;
			}
		}
		private static function loadHome(e:WindowEvent):void {
			visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, loadHome);
			App.self.addEventListener(AppEvent.ON_USER_COMPLETE, onHomeComplete);
			App.user.goHome();
		}
		private static function onHomeComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_USER_COMPLETE, onHomeComplete);
			clearWorlds();
			
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			App.user.mode = User.OWNER;
			App.map = new Map(App.user.worldID, App.user.units, false);
			App.map.load();
		}
		
		private static function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			//dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
			App.user.addPersonag();
			
			App.map.scaleX = App.map.scaleY = SystemPanel.scaleValue;
			App.map.center();
			if (visitWindow != null)
			{
				visitWindow.close();
				visitWindow = null;
			}
			
			//if (App.user.mode == User.OWNER && App.user.worldID == User.HOME_WORLD && !App.user.quests.tutorial)
				//Pigeon.checkNews();
		}
		
		private static var friend:Object;
		public static function onVisitEvent(e:MouseEvent):void {
			
			if(App.tutorial)
				App.tutorial.hide();
			Cursor.type = 'default';
			if (Quests.lockButtons) {
				Quests.lockButtons = false;
				return;
			}
			
			if (App.owner != null && e.currentTarget.friend.uid == App.owner.id)
				return;
			
			App.user.onStopEvent();
			
			friend = e.currentTarget.friend;
			currentFriend = e.currentTarget.friend;
			friend['visited'] = App.time;
			e.currentTarget.legs.visible = true;
			App.ui.bottomPanel.showGuestPanel();
			
			visitWindow = new VisitWindow();
			visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, loadOwner);
			visitWindow.show();
		}
		
		private static var startTime:uint;
		private static var finishTime:uint;
		public static var ownerWorldID:int;
		private static var currentFriend:Object = null;
		private static function loadOwner(e:WindowEvent):void 
		{
			ownerWorldID = User.HOME_WORLD;
			
			visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, loadOwner);
			App.self.addEventListener(AppEvent.ON_OWNER_COMPLETE, onOwnerComplete);
			App.owner = new Owner(friend, ownerWorldID);
			App.ui.leftPanel.showGuestEnergy();
			App.ui.upPanel.showAvatar();
			friend = null;
		}
		
		private static function onOwnerComplete(e:AppEvent):void 
		{ 
			App.self.removeEventListener(AppEvent.ON_OWNER_COMPLETE, onOwnerComplete);
			
			App.map.dispose();
			App.user.world.dispose();
			App.map = null;
			
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			App.user.mode = User.GUEST;
			
			App.map = new Map(App.owner.worldID, App.owner.units, false);
			//setTimeout(function():void {
			App.map.load();
			//}, 20);
		}
		
		public function Travel() {
			
		}
		
		private static var worldID:int;
		public static function goTo(_worldID:uint):void {
			worldID = _worldID;
			App.user.onStopEvent();
			visitWindow = new VisitWindow({title:Locale.__e('flash:1382952380050',[App.data.storage[worldID].title])});
			visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, _onLoadUser);
			visitWindow.show();	
		}
		
		private static function _onLoadUser(e:WindowEvent):void {
			visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, _onLoadUser);
			ShopWindow.shop = null;
			//ShopWindow.history.section = 2;
			App.self.addEventListener(AppEvent.ON_USER_COMPLETE, _onUserComplete);
			App.user.world.dispose();
			App.user.dreamEvent(worldID);
		}
		
		private static function _onUserComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_USER_COMPLETE, _onUserComplete);
			
			App.map.dispose();
			App.map = null;
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, _onMapComplete);
			
			App.user.mode = User.OWNER;
			App.map = new Map(App.user.worldID, App.user.units, false);
			App.map.load();
		}
		
		private static function _onMapComplete(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, _onMapComplete);
			//Вызываем событие окончания flash:1382952379984грузки игры, можно раставлять теперь объекты на карте
			//mapWindow.dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
			
			if(visitWindow != null){
				visitWindow.close();
				visitWindow = null;
			}
			
			App.user.addPersonag();
			App.map.scaleX = App.map.scaleY = SystemPanel.scaleValue;
			App.map.center();
			
			//Lantern.init();
			App.user.quests.scoreOpened();
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
			
		}
	}
}