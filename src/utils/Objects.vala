namespace PhotoStream.Utils
{
	public class MediaInfo
	{
		public int type;
		public List<string> tags;
		public List<Comment> comments;
		public string filter;
		public DateTime creationTime;
		public Location location = null;
		public string link;
		public List<User> likes;
		public int64 likesCount;
		public Image image;
		public List<TaggedUser> taggedUsers;
		public string title;
		public User postedUser;
		public string id;
		public bool didILikeThis;
		
		public MediaInfo()
		{
			tags = new List<string>();
			comments = new List<Comment>();
			likes = new List<User>();
			image = new Image();
			taggedUsers = new List<TaggedUser>();
		}
	}
	public class Comment
	{
		public DateTime creationTime;
		public string text;
		public User user;
		public string id;
	}

	public class Image
	{
		public string url;
		public int64 width;
		public int64 height;
	}
	public class User
	{
		public string username;
		public string profilePicture;
		public string fullName;
		public string id;
		public string website = ""; //this is not in all requests
		public string bio = ""; //this is too;
		public int64 mediaCount = 0;
		public int64 followers = 0;
		public int64 followed = 0; //these 3 are only in user page
	}
	public class Location
	{
		public double latitude;
		public double longitude;
		public int64 id;
		public string name;
	}
	public class TaggedUser
	{
		public double x;
		public double y;
		public User user;
	}
}

class PhotoStream.MediaType
{
	public const int IMAGE = 1;
	public const int VIDEO = 2;
}