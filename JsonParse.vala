using PhotoStream.Utils;

public void parseFeed(string message) 
{
	var parser = new Json.Parser ();

	parser.load_from_data (message);
	var root_object = parser.get_root().get_object();
    var response = root_object.get_array_member ("data");
    int64 count = response.get_length ();

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

    	//stub comments
    	info.filter = mediaPostObject.get_string_member("filter");
    	//stub likes and images and users in photo

    	var captionObject = mediaPostObject.get_member("caption").get_object();
    	info.creationTime = new DateTime.from_unix_utc(captionObject.get_int_member("created_time")); //getting creation time
    	info.title = captionObject.get_string_member("text"); //getting title text
    	info.id = captionObject.get_int_member("id"); //getting id

    	info.didILikeThis = mediaPostObject.get_bool_member("user_has_liked"); //getting if I liked this or not

    	PhotoStream.App.feedPosts.append(info);

    }
}
