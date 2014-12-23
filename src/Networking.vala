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
    var idTruncated = id.substring(0, id.index_of("_"));
    var url = "http://instagram.com/web/comments/" + idTruncated + "/add/";

    var session = new Soup.Session ();
    var message = new Soup.Message ("POST", url);  
    session.user_agent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36";  

    var cookieJarText = new Soup.CookieJarText(PhotoStream.App.CACHE_URL + "cookie.txt", false);
    Soup.cookies_to_request(cookieJarText.all_cookies(), message);

    message.request_headers.append("Host", "instagram.com");
    message.request_headers.append("Connection", "keep-alive");
    message.request_headers.append("Origin", "http://instagram.com");
    message.request_headers.append("X-Instagram-AJAX", "1");
    message.request_headers.append("X-Requested-With", "XMLHttpRequest");
    message.request_headers.append("DNT", "1");
    message.request_headers.append("Referer", "instagram.com");
    message.request_headers.append("Accept-Encoding", "gzip, deflate");            // without all this headers it won't pass.
    message.request_headers.append("Accept-Language", "ru,en-US;q=0.8,en;q=0.6");  // thanks a lot to Wireshark, awesome thing.

    var cookies = cookieJarText.all_cookies();
    string csrftoken = "";

    foreach (Soup.Cookie cookie in cookies)
        if (cookie.get_name() == "csrftoken")
        {
            csrftoken = cookie.get_value();
            break; // don't ask.
        }

    message.request_headers.append("X-CSRFToken", csrftoken);


    uint8[] requestString = ("comment_text="  + Soup.URI.encode(comment, null)).data;

    message.request_body.append_take(requestString);
    session.send_message (message);

    return (string)message.response_body.data;
}
public string deleteComment(string mediaId, string commentId)
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("DELETE", "https://api.instagram.com/v1/media/" 
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
public string getLocationInfo(string id)
{
    return getResponse("https://api.instagram.com/v1/locations/" + id.to_string() + "?access_token=" + PhotoStream.App.appToken);
}
public string getLocationRecent(string id)
{
    return getResponse("https://api.instagram.com/v1/locations/" + id.to_string() + "/media/recent?access_token=" + PhotoStream.App.appToken);
}
public string searchLocation(double latitude, double longitude, int distance = 1000)
{
    return getResponse("https://api.instagram.com/v1/locations/search?lat=%f&lng=%f&distance=%f&access_token=%s" 
                    .printf(latitude, 
                            longitude,
                            distance , 
                            PhotoStream.App.appToken));
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

public string getUserSettings()
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("GET", "http://instagram.com/accounts/edit");

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

public string postPicture(string fileUrl)
{
    var url = "http://i.instagram.com/api/v1/upload/photo/";
    var boundary = "7qkvEgAJ8y7NzsBpKQ0Y8BsfJLse2C";

    var session = new Soup.Session ();
    var message = new Soup.Message ("POST", url);  
    session.user_agent = "Instagram 6.11.2 Android (15/4.0.4; 240dpi; 480x800; HTC/htc_wwe; HTC Incredible S; vivo; vivo; en_US)";  

    var cookieJarText = new Soup.CookieJarText(PhotoStream.App.CACHE_URL + "cookie.txt", false);
    var cookies = cookieJarText.all_cookies();

    cookies.append(new Soup.Cookie("ccode", "RU", "i.instagram.com", null, -1));
    cookies.append(new Soup.Cookie("igfl", PhotoStream.App.selfUser.username, "i.instagram.com", null, -1));
    cookies.append(new Soup.Cookie("ds_user_id", PhotoStream.App.selfUser.id, "i.instagram.com", null, -1));
    cookies.append(new Soup.Cookie("ds_user", PhotoStream.App.selfUser.username, "i.instagram.com", null, -1));
    cookies.append(new Soup.Cookie("is_starred_enabled", "yes", "i.instagram.com", null, -1));

    Soup.cookies_to_request(cookies, message);

    message.request_headers.append("Content-Type", "multipart/form-data; boundary=" + boundary);
    message.request_headers.append("Host", "i.instagram.com");
    message.request_headers.append("X-IG-Connection-Type", "USBNET");
    message.request_headers.append("X-IG-Capabilities", "AQ==");
    message.request_headers.append("Accept-Encoding", "gzip");

    string csrftoken = "";

    foreach (Soup.Cookie cookie in cookies)
        if (cookie.get_name() == "csrftoken")
        {
            csrftoken = cookie.get_value();
            break; // don't ask.
        }

    GLib.DateTime now = new GLib.DateTime.now_local();
    string uploadId = now.to_unix().to_string() + (now.get_microsecond() / 1000).to_string();

    string request = "";
    request += "--" + boundary + "\r\n";
    request += "Content-Disposition: form-data; name=\"_csrftoken\"\r\n\r\n";
    request += csrftoken;
    request += "\r\n--" + boundary + "\r\n";
    request += "Content-Disposition: form-data; name=\"upload_id\"\r\n\r\n";
    request += uploadId;
    request += "\r\n--" + boundary + "\r\n";
    request += "Content-Disposition: form-data; name=\"photo\"; filename=\"file\"\r\n";
    request += "Content-Type: application/octet-stream\r\n";
    request += "Content-Transfer-Encoding: binary\r\n\r\n";
    uint8[] requestString = request.data;

    var file = File.new_for_path (fileUrl);

    if (!file.query_exists ())
        error("File '%s' doesn't exist.\n", file.get_path ());

    message.request_headers.foreach((key, value) => {
        print("%s: %s\n", key, value);
    });

    try 
    {
        var dis = new DataInputStream (file.read ());
        int64 size = file.query_info ("*", FileQueryInfoFlags.NONE).get_size();
        for (int64 i = 0; i < size; i++)
            requestString += dis.read_byte();
    } 
    catch (Error e) 
    {
        error ("%s", e.message);
    }

    uint8[] lastBoundary = ("\r\n--" + boundary + "--\n").data;

    for (int i = 0; i < lastBoundary.length; i++)
        requestString += lastBoundary[i];

    print((string)requestString + "\n");


    message.request_body.append_take(requestString);
    session.send_message (message);

    print("\n\n Response\n");
    print("Status: %s\n", message.status_code.to_string());
    message.response_headers.foreach((key, value) => {
        print("%s: %s\n", key, value);
    });


    return (string)message.response_body.data;
}

public string postSettings(PhotoStream.Utils.Settings settings, PhotoStream.Utils.User user)
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("POST", "https://instagram.com/accounts/edit");

    var cookieJarText = new Soup.CookieJarText(PhotoStream.App.CACHE_URL + "cookie.txt", false);
    Soup.cookies_to_request(cookieJarText.all_cookies(), message);

    string csrftoken = "";

    foreach (Soup.Cookie cookie in cookieJarText.all_cookies())
        if (cookie.get_name() == "csrftoken")
        {
            csrftoken = cookie.get_value();
            break; // don't ask.
        }

    string request = "csrfmiddlewaretoken=" + csrftoken;
    request += "&first_name=" + user.fullName;
    request += "&email=" + settings.email;
    request += "&username=" + user.username;
    request += "&phone_number=" + settings.phoneNumber.replace(" ", "").replace("-", "");
    if (settings.sex == "male")
        request += "&gender=1";
    else if (settings.sex == "female")
        request += "&gender=2";
    else if (settings.sex == "")
        request += "&gender=3";
    else
        error ("Should've not reached here: %s", settings.sex);

    request += "&biography=" + user.bio;
    request += "&external_url_section=" + user.website;
    request += "&chaining_enabled=" + (settings.recommend ? "true" : "false");

    print(request + "\n");

    uint8[] requestString = request.data;

    message.request_body.append_take(requestString);
    session.send_message (message);

    return (string)message.response_body.data;
}