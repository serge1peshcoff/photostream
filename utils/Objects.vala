namespace PhotoStream.Utils
{
	public class MediaInfo
	{
		public int type;
		public List<string> tags;
		public List<Comment> comments;
		public string filter;
		public DateTime creationTime;
		public string link;
		public List<Like> likes;
		public List<Image> images;
		public List<User> taggedUsers;
		public string title;
		public User postedUser;
		public int64 id;
		public bool didILikeThis;
		
		public MediaInfo()
		{
			tags = new List<string>();
			comments = new List<Comment>();
			likes = new List<Like>();
			images = new List<Image>();
			taggedUsers = new List<User>();
		}
	}
	public class Comment
	{
		public DateTime creationTime;
		public string text;
		public User user;
		public int64 id;
	}
	public class Like
	{

	}
	public class Image
	{

	}
	public class User
	{
		public string username;
		public string profilePicture;
		public string fullName;
		public int64 id;
		public string website = ""; //this is not in all requests
		public string bio = ""; //this is too;
		public int64 mediaCount = 0;
		public int64 followers = 0;
		public int64 followed = 0; //this 3 are only in user page
	}
}

class PhotoStream.MediaType
{
	public const int IMAGE = 1;
	public const int VIDEO = 2;
}