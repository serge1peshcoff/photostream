public string getResponse (string host) 
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("GET", host);

    session.send_message (message);
    return (string) message.response_body.data;
}

// users
public string getUserInfo(string id)
{
    return getResponse("https://api.instagram.com/v1/users/" + id + "?access_token=" + PhotoStream.App.appToken);
}
public string getUserFeed()
{
    return getResponse("https://api.instagram.com/v1/users/self/feed?access_token=" + PhotoStream.App.appToken);
}
public string getUserMedia(string id)
{
    return getResponse("https://api.instagram.com/v1/users/" + id + "/media/recent/?access_token=" + PhotoStream.App.appToken);
}
public string getLikedPosts()
{
    return getResponse("https://api.instagram.com/v1/users/self/media/liked?access_token=" + PhotoStream.App.appToken);
}
public string getOlderUserFeed()
{
	return getResponse(PhotoStream.App.olderFeedLink);
}
public string searchUser(string user)
{
    return getResponse("https://api.instagram.com/v1/users/search?q=" + user + "&access_token=" + PhotoStream.App.appToken);
}

// relationships
public string getUserFollows(string user)
{
    return getResponse("https://api.instagram.com/v1/users/" + user + "/follows?access_token=" + PhotoStream.App.appToken);
}
public string getUserFollowers(string user)
{
    return getResponse("https://api.instagram.com/v1/users/" + user + "/followed-by?access_token=" + PhotoStream.App.appToken);
}
public string getRequestedUsers()
{
    return getResponse("https://api.instagram.com/v1/users/self/requested-by?access_token=" + PhotoStream.App.appToken);
}
public string getUsersRelationship(string user)
{
    return getResponse("https://api.instagram.com/v1/users/" + user + "/relationship?access_token=" + PhotoStream.App.appToken);
}
public string relationshipAction(string user, string action) // action - one of "follow/unfollow/block/unblock/approve/ignore"
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("POST", "https://api.instagram.com/v1/users/" + user + "/relationship?access_token="  + PhotoStream.App.appToken);

    uint8[] requestString = ("action=" + action).data;

    message.request_body.append_take(requestString);
    session.send_message (message);

    return (string)message.response_body.data;
}

// media
public string getMediaData(string id)
{
	return getResponse("https://api.instagram.com/v1/media/" + id + "?access_token=" + PhotoStream.App.appToken);
}
public string mediaSearch(double latitude, double longitude, int distance = 1000)
{
    return getResponse("https://api.instagram.com/v1/media/search"
                                                    + "?lat=" + latitude.to_string() 
                                                    + "&lng=" + longitude.to_string() 
                                                    + "&distance=" + distance.to_string() 
                                                    + "&access_token=" + PhotoStream.App.appToken);
}
public string getPopular()
{
    return getResponse("https://api.instagram.com/v1/media/popular?access_token=" + PhotoStream.App.appToken);
}

// comments
public string getComments(string id)
{
    return getResponse("https://api.instagram.com/v1/media/" + id + "/comments?access_token=" + PhotoStream.App.appToken);
}
public string postComment(string id, string comment)
{
    // stub, waiting for Instagram to allow me to use this endpoint.
    return "";
}
public string deleteComment(string mediaId, string commentId)
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("DELETE", "https://api.instagram.com/v1/media/" 
                    + mediaId + "/comments/" + commentId + "?access_token=" + PhotoStream.App.appToken);

    session.send_message (message);
    return (string) message.response_body.data;
}

// likes

public string getMediaLikes(string id)
{
    return getResponse("https://api.instagram.com/v1/media/" + id + "/likes?access_token=" + PhotoStream.App.appToken);
}
public string likeMedia(string id)
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("POST", "https://api.instagram.com/v1/media/" + id + "/likes");

    uint8[] requestString = ("access_token="  + PhotoStream.App.appToken).data;

    message.request_body.append_take(requestString);
    session.send_message (message);

    return (string)message.response_body.data;
}
public string dislikeMedia(string id)
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("DELETE", "https://api.instagram.com/v1/media/" 
                    + id + "/likes?access_token=" + PhotoStream.App.appToken);

    session.send_message (message);

    return (string)message.response_body.data;
}

// tags
public string getTagInfo(string tag)
{
    return getResponse("https://api.instagram.com/v1/tags/" + tag + "?access_token=" + PhotoStream.App.appToken);
}
public string getTagRecent(string tag)
{
    return getResponse("https://api.instagram.com/v1/tags/" + tag + "/media/recent?access_token=" + PhotoStream.App.appToken);
}
public string searchTag(string tag)
{
    return getResponse("https://api.instagram.com/v1/tags/search?q=" + tag + "&access_token=" + PhotoStream.App.appToken);
}

// locations
public string getLocationInfo(string id)
{
    return getResponse("https://api.instagram.com/v1/locations/" + id + "?access_token=" + PhotoStream.App.appToken);
}
public string getLocationRecent(string id)
{
    return getResponse("https://api.instagram.com/v1/locations/" + id + "/media/recent?access_token=" + PhotoStream.App.appToken);
}
public string searchLocation(double latitude, double longitude, int distance = 1000)
{
    return getResponse("https://api.instagram.com/v1/locations/search"
                                                    + "?lat=" + latitude.to_string() 
                                                    + "&lng=" + longitude.to_string() 
                                                    + "&distance=" + distance.to_string() 
                                                    + "&access_token=" + PhotoStream.App.appToken);
}


public void downloadFile(string url, string filename)
{
	var session = new Soup.Session ();
    var message = new Soup.Message ("GET", url);
    session.send_message (message);

    size_t bytes;

    File file;
    FileIOStream stream;

    try 
    {
	    file = File.new_for_path(filename);
	    if (file.query_exists())  
	    	file.delete();  

	    stream = file.create_readwrite(FileCreateFlags.PRIVATE);

	    FileOutputStream os = stream.output_stream as FileOutputStream;

    	os.write_all(message.response_body.data, out bytes);
	}
	catch (Error e)
	{
		GLib.error("Something wrong with file writing. Do the ~/.cache/ and ~/.cache/photostream directories belong to you?\n");
    }
}
