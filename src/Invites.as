package  
{
	import api.ExternalApi;
	import core.Post;
	public class Invites 
	{		
		public var data:Object;
		public var random:Array = [];
		public var invited:Object = {}; //меня пригласили
		public var requested:Object = {}; //я пригласил
		public var randomProfiles:Object = {};
		public var invitedProfiles:Object = {};
		public var requestedProfiles:Object = {};
		public var inited:Boolean = false;
		
		public function Invites() 
		{
			
		}
		
		public function init(callback:Function):void {
			if (inited) {
				callback();
				return;
			}
			
			Post.send({
				'ctr':'invites',
				'act':'get',
				'uID':App.user.id
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					var _random:Object = response['random'];
					var fid:String;
					if(response['random']){
						for each(fid in response['random']) {
							random.push(fid);
						}
					}
					invited = response['invited'] || { };
					for (fid in invited ) {
						random.push(fid);
					}
					
					requested = response['requested'] || { };
					for (fid in requested) {
						random.push(fid);
					}
					
					ExternalApi.getUsersProfile(random, function(profiles:Object):void {
						inited = true;
						for each(var friend:Object in profiles) {
							if (invited[friend.uid] != undefined) {
								invitedProfiles[friend.uid] = friend;
							}else if (requested[friend.uid] != undefined) {
								requestedProfiles[friend.uid] = friend;
							}else {
								randomProfiles[friend.uid] = friend;
							}	
						}
						if(callback != null){
							callback();
						}
					});
				}
			});
		}
		
		public function invite(fID:String, callback:Function):void {
			
			Post.send({
				'ctr':'invites',
				'act':'invite',
				'uID':App.user.id,
				'fID':fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					
					invitedProfiles[fID] = randomProfiles[fID];
					invited[fID] = App.time;					
					callback();
				}
			});
			
		}
		
		public function accept(fID:String, callback:Function):void {
			
			Post.send({
				'ctr':'invites',
				'act':'accept',
				'uID':App.user.id,
				'fID':fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					
					delete requested[fID];
					var friend:Object = response['friend'];
					for (var p:String in requestedProfiles[fID]) {
						friend[p] = requestedProfiles[fID][p];
					}
					App.user.friends.data[fID] = friend;
					callback();
				}
			});
			
		}
		
		public function reject(fID:String, type:int, callback:Function):void {
			
			Post.send({
				'ctr':'invites',
				'act':'reject',
				'uID':App.user.id,
				'fID':fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					
					if (type == 1) {//Приглашенные
						delete requested[fID];
						delete requestedProfiles[fID];
					}else if (type == 2) { //Приглащающие
						delete invited[fID];
						delete invitedProfiles[fID];
					}else if (type == 3) { //Сосед
						delete App.user.friends.data[fID];
						//App.ui.bottomPanel.searchFriends();
					}
					
					callback();
				}
			});
			
		}
		
	}

}