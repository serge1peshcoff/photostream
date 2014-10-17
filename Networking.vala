public string getResponce (string host) 
{
    // create an HTTP session to twitter
    var session = new Soup.Session ();
    var message = new Soup.Message ("GET", host);

    // send the HTTP request and wait for response
    session.send_message (message);

    // output the XML result to stdout 
    return (string) message.response_body.data;
}

public string getUserFeed()
{
    return getResponce("https://api.instagram.com/v1/users/self/feed?access_token=" + PhotoStream.App.appToken);
}