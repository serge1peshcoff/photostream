public string getResponse (string host) 
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("GET", host);

    session.send_message (message);
    return (string) message.response_body.data;
}

//users
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

public string getImageData(string id)
{
	return getResponse("https://api.instagram.com/v1/media/" + id + "?access_token=" + PhotoStream.App.appToken);
}


public string getImageWithPeople()
{
    return getResponse("https://api.instagram.com/v1/users/self/media/recent?access_token=" + PhotoStream.App.appToken);
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
