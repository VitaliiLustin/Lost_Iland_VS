package  
{
	import api.ExternalApi;
	import core.Log;
	import core.Post;
	import wins.HistoryWindow;
	import flash.external.ExternalInterface;
	public class Payments 
	{		
		
		public static var history:Array = [];
		
		public function Payments() 
		{
			
		}
		
		public static function getHistory(show:Boolean = true):void {
			
			Post.send({
				'ctr':'orders',
				'act':'get',
				'uID':App.user.id
			}, function(error:*, result:*, params:*):void {
				
				if (error) {
					trace(error);
					return;
				}
				
				for each(var item:Object in result.history) {
					history.push(item);
				}
				history.sortOn('transaction_time', Array.DESCENDING);
				
				App.self.setOffTimer(onExpirePayment);
				App.self.setOnTimer(onExpirePayment);
				
				if(show){
					new HistoryWindow( { content:history } ).show();
				}
			});
		}
		
		public static function onExpirePayment():void {
			for each(var item:Object in history) {
				//txnid
				if (item.status == 0 && item.transaction_end < App.time) {
					Post.send({
						'ctr':'orders',
						'act':'expire',
						'uID':App.user.id
					}, function(error:*, result:*, params:*):void {
						if (!error) {
							for each(var txnid:String in result.orders) {
								for(var id:* in history) {
									if (history[id].txnid == txnid) {
										history[id].status = 1;
									}
								}	
							}
							if(result[Stock.FANT] != undefined){
								App.user.stock.put(Stock.FANT, result[Stock.FANT]);
							}
						}
					});
					break;
				}
			}
			
		}
		
	}

}