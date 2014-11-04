public string getResponce (string host) 
{
    var session = new Soup.Session ();
    var message = new Soup.Message ("GET", host);

    session.send_message (message);
    return (string) message.response_body.data;
}

public string getUserFeed()
{
	stdout.printf("https://api.instagram.com/v1/users/self/feed?access_token=" + PhotoStream.App.appToken + "\n");
    return getResponce("https://api.instagram.com/v1/users/self/feed?access_token=" + PhotoStream.App.appToken);
}
public string getImageWithPeople()
{
    return getResponce("https://api.instagram.com/v1/users/self/media/recent?access_token=" + PhotoStream.App.appToken);
}