public string getResponce (string host) 
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("GET", host);

    session.send_message (message);
    return (string) message.response_body.data;
}

public string getUserFeed()
{
    return getResponce("https://api.instagram.com/v1/users/self/feed?access_token=" + PhotoStream.App.appToken);
}
public string getImageWithPeople()
{
    return getResponce("https://api.instagram.com/v1/users/self/media/recent?access_token=" + PhotoStream.App.appToken);
}

public string downloadFile(string url, string filename)
{
	var session = new Soup.Session ();
    var message = new Soup.Message ("GET", url);
    session.send_message (message);

    size_t bytes;

    var file = File.new_for_path(filename);
    if (file.query_exists())  
    	file.delete();  
    	
    var stream = file.create_readwrite(FileCreateFlags.PRIVATE);

    FileOutputStream os = stream.output_stream as FileOutputStream;

    os.write_all(message.response_body.data, out bytes);    
    return (string) message.response_body.data;
}
