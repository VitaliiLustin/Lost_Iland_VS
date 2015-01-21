package api
{
	public class flashVarsGenerator
	{
		public static function take(userID:String):Object
		{
			var flashVars:Object = new Object();
			
			flashVars['api_id'] = 3388852;// 4293650;//3388852;//3539072; // 2786285; // 3539072;
			flashVars['viewer_id'] = String(userID);
			
					
			flashVars['social']	= 'VK'	
			flashVars['sid'] = "5017d3dfa6796033bc0624c2850cdbe3d3074d7d2832eae64b69f383a705243b33c5f51d66f38a839cc8f";
			flashVars['secret'] = "5a4784aaee";//"ujGqlGjaeGzoIrS9q9YS"//"5a4784aaee";
			flashVars['group'] = "http://vk.com/dreams_legends";
			
			flashVars['profile'] = {
				first_name:"Дмитрий",
				last_name:"Ташенко",
				sex:"m",
				photo:'http://cs316618.userapi.com/u174971289/e_29f86101.jpg'
			};
			
			flashVars['wallServer'] = {
				aid: -14,
				mid:174971289,
				upload_url:"http://cs417630.vk.com/upload.php?act=do_add&mid=174971289&aid=-14&gid=0&hash=d17731e9bb6b9180adaebf25b8bea035&rhash=e40e4a122e2b3e7238ec8cc98f7417a5&swfupload=1&api=1&wallphoto=1"
			};
			flashVars['appFriends'] = [];
			//flashVars['appFriends'] = [9490649,151695597,159185922, 226063581, 174971289, 22606358, 226063581, 2322590, 5800812, 2329711, 226063582, 226063583, 226063584, 226063585,226063586,226063587,226063588,226063589, 2914315, 15918592212222, 5221363, 9490649, 183267076, 2260635821, 222, 131760631, 159185922221, 2260635812, 2260635821, 2914313, 3083653, 2329711, 11956380, 1];
			//flashVars['appFriends'] = [9490649, 1];
			return flashVars;
		}
	}
}