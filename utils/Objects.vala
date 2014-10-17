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
		public User posteduser;
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

	}
	public class Like
	{

	}
	public class Image
	{

	}
	public class User
	{

	}
}

class PhotoStream.MediaType
{
	public const int IMAGE = 1;
	public const int VIDEO = 2;
}