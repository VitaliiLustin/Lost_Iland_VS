package core 
{
	public class Numbers 
	{
		
		public function Numbers() 
		{
			
		}	
	
		public static function moneyFormat(count:int):String {
			var r:RegExp = /\d\d\d$/g;
			var s:String = count.toString();
			var a:Array = new Array();
			var res:String ='';

			while (s.length > 3){
				a.push(' '+s.match(r));
				s = s.replace(r,'');
			}

			for (var i:int = a.length; i > 0; i--) {
				res = res+a[i-1];
			}

			res = s + res;
			return res;
		}
	
	}

}