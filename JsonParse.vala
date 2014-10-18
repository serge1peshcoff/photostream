using PhotoStream.Utils;

public void parseFeed(string message) 
{
	var parser = new Json.Parser ();

	parser.load_from_data (message);
	var root_object = parser.get_root().get_object();
    var response = root_object.get_array_member ("data");

    foreach (var mediaPost in response.get_elements ())
    {
    	MediaInfo info = new MediaInfo();
    	var mediaPostObject = mediaPost.get_object();

    	var tags = mediaPostObject.get_array_member ("tags"); //getting tags
    	foreach (var tag in tags.get_elements())
    		info.tags.append(tag.get_string());

    	var type = mediaPostObject.get_string_member("type"); //media type
    	if (type == "image")
    		info.type = PhotoStream.MediaType.IMAGE;
    	else if (type == "video")
    		info.type = PhotoStream.MediaType.VIDEO;

    		

    	var commentObject = mediaPostObject.get_member("comments").get_object(); //getting comments
    	if (commentObject.get_int_member("count") != 0) //if there are any
    		foreach(var comment in commentObject.get_array_member("data").get_elements())
    		{
    			
    			Comment infoComment = new Comment();
    			infoComment.creationTime = new DateTime.from_unix_utc(comment.get_object().get_int_member("created_time"));
    			infoComment.text = comment.get_object().get_string_member("text");
    			infoComment.id = comment.get_object().get_int_member("id");
    			
    			var commentedUser = comment.get_object().get_member("from").get_object();
    			infoComment.user = new User();
    			infoComment.user.username = commentedUser.get_string_member("username");
    			infoComment.user.profilePicture = commentedUser.get_string_member("profile_picture");
    			infoComment.user.id = commentedUser.get_int_member("id");
    			infoComment.user.fullName = commentedUser.get_string_member("full_name");

    			info.comments.append(infoComment);    			
    		}
    	info.filter = mediaPostObject.get_string_member("filter");
    	//stub likes and images and users in photo


    	var captionObject = mediaPostObject.get_member("caption");
    	if (!captionObject.is_null()) //if there's a caption	    	
	    	info.title = captionObject.get_object().get_string_member("text"); //getting title text
	    else //if no caption
	    	info.title = "";
    	
    	info.id = mediaPostObject.get_int_member("id");
    	info.creationTime = new DateTime.from_unix_utc(mediaPostObject.get_int_member("created_time")); //getting creation time
    	info.didILikeThis = mediaPostObject.get_boolean_member("user_has_liked"); //getting if I liked this or not

    	PhotoStream.App.feedPosts.append(info);

    }
}
