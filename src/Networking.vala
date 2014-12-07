public string getResponse (string host) 
{ 
    var ip = loadAddress();
    if (ip == "")
        ip = resolveHost();

    var newHost = replaceHostWithIp(host, ip);

    var session = new Soup.Session ();
    session.ssl_strict = false;
    session.user_agent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36";

    var message = new Soup.Message ("GET", newHost);
    message.tls_errors = GLib.TlsCertificateFlags.VALIDATE_ALL;  

    message.request_headers.append("Host", "api.instagram.com");

    session.send_message (message);

    if (loadAddress() == "")
        setAddress(ip);

    return (string) message.response_body.data;
}

// users
public string getUserInfo(string id)
{
    return getResponse("https://api.instagram.com/v1/users/" + id + "?access_token=" + PhotoStream.App.appToken);
}
public string getUserFeed(string minId = "")
{
    if (minId == "")
        return getResponse("https://api.instagram.com/v1/users/self/feed?access_token=" + PhotoStream.App.appToken);
    else
        return getResponse("https://api.instagram.com/v1/users/self/feed?access_token=" 
                                                                + PhotoStream.App.appToken
                                                                + "&min_id=" + minId);
}
public string getUserMedia(string id)
{
    return getResponse("https://api.instagram.com/v1/users/" + id + "/media/recent/?access_token=" + PhotoStream.App.appToken);
}
public string getLikedPosts()
{
    return getResponse("https://api.instagram.com/v1/users/self/media/liked?access_token=" + PhotoStream.App.appToken);
}
public string getOlderUserFeed(string olderFeedLink)
{
	return getResponse(olderFeedLink);
}
public string searchUsers(string user)
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
    // UPD: they rejected me. don't know what to do.
    return "";
}
public string deleteComment(string mediaId, string commentId)
{
    var ip = loadAddress();
    var session = new Soup.Session ();
    var message = new Soup.Message ("DELETE", "https://" + ip + "/v1/media/" 
                    + mediaId + "/comments/" + commentId + "?access_token=" + PhotoStream.App.appToken);
    message.request_headers.append("Host", "api.instagram.com");

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
    message.request_headers.append("Host", "api.instagram.com");

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
public string searchTags(string tag)
{
    return getResponse("https://api.instagram.com/v1/tags/search?q=" + tag + "&access_token=" + PhotoStream.App.appToken);
}

// locations
public string getLocationInfo(int64 id)
{
    return getResponse("https://api.instagram.com/v1/locations/" + id.to_string() + "?access_token=" + PhotoStream.App.appToken);
}
public string getLocationRecent(int64 id)
{
    return getResponse("https://api.instagram.com/v1/locations/" + id.to_string() + "/media/recent?access_token=" + PhotoStream.App.appToken);
}
public string searchLocation(double latitude, double longitude, int distance = 1000)
{
    return getResponse("https://api.instagram.com/v1/locations/search"
                                                    + "?lat=" + latitude.to_string() 
                                                    + "&lng=" + longitude.to_string() 
                                                    + "&distance=" + distance.to_string() 
                                                    + "&access_token=" + PhotoStream.App.appToken);
}


public void downloadFile(string url, string filename) throws Error
{
	var session = new Soup.Session ();
    session.ssl_strict = false;

    var message = new Soup.Message ("GET", url);
    message.tls_errors = GLib.TlsCertificateFlags.VALIDATE_ALL;

    session.send_message (message);

    size_t bytes;

    File file;
    FileIOStream stream;

    if (message.status_code != Soup.Status.OK)
        error("Something wrong with downloading: " + Soup.Status.get_phrase(message.status_code));

    try 
    {
	    file = File.new_for_path(filename);
	    if (file.query_exists())  
	    	//file.delete();
            return;

	    stream = file.create_readwrite(FileCreateFlags.PRIVATE);
	    FileOutputStream os = stream.output_stream as FileOutputStream;

    	os.write_all(message.response_body.data, out bytes);
	}
	catch (Error e)
	{
		GLib.error("Something wrong with file writing: \"%s\". Do the ~/.cache/ and ~/.cache/photostream directories belong to you?\n", e.message);
    }
}


public string getUserNews()
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("GET", "http://instagram.com/api/v1/news/inbox/");

    var cookieJarText = new Soup.CookieJarText(PhotoStream.App.CACHE_URL + "cookie.txt", false);
    Soup.cookies_to_request(cookieJarText.all_cookies(), message);

    session.send_message (message);
    return (string) message.response_body.data;
}

public string resolveHost()
{
    Soup.Address apiAddress = new Soup.Address("api.instagram.com", 443);
    apiAddress.resolve_sync();
    return apiAddress.get_physical();
}