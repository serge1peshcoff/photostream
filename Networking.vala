public string getResponce (string host) 
{
    // create an HTTP session to twitter
    var session = new Soup.Session ();
    var message = new Soup.Message ("GET", "https://api.instagram.com/v1/users/self/feed?access_token=1528631860.1fb234f.e72be2d22ad444d594026ac9e4012cf7");

    // send the HTTP request and wait for response
    session.send_message (message);

    // output the XML result to stdout 
    return (string) message.response_body.data;
}