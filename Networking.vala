public void getResponce (string host) 
{

    // "https://api.instagram.com/oauth/authorize/?client_id=6e7283f612c645a5a22846d79cab54c3&redirect_uri=http://itprogramming1.tk/photostream&response_type=token&scope=basic+comments+relationships+likes"

    //token:       1528631860.6e7283f.c07dd07350b14b64945d6212593486e1

    //https://api.instagram.com/v1/users/self/feed?access_token=ACCESS-TOKEN
    try 
    {
        // Resolve hostname to IP address
        var resolver = Resolver.get_default ();
        var addresses = resolver.lookup_by_name (host, null);
        var address = addresses.nth_data (1);
        //stdout.printf(@"Resolved $host to $address\n");

        // Connect
        var client = new SocketClient ();
        client.set_tls(true);
        client.set_tls_validation_flags(TlsCertificateFlags.VALIDATE_ALL);
        client.event.connect(socketEvent);

        var conn = client.connect (new InetSocketAddress (address, 443));
        //print (@"Connected to $host\n");

        // Send HTTP GET request
        var message = 
            "GET /v1/users/self/feed?access_token=1528631860.1fb234f.e72be2d22ad444d594026ac9e4012cf7 HTTP/1.1\r\nHost: api.instagram.com\r\nX-Target-URI: https://api.instagram.com\r\n\r\n";
        conn.output_stream.write (message.data);
        //print ("Wrote request\n");


        // Receive response
        var response = new DataInputStream (conn.input_stream);
        string status_line;

        while ((status_line = response.read_line (null)) != null) 
            if(status_line.length > 5)               
                print ("%s\n", status_line);                  

    }
    catch (Error e) 
    {
        stderr.printf ("Error: %s\n", e.message);
    }
}

public void socketEvent (SocketClientEvent event, SocketConnectable connectable, IOStream connection)
{
    if (event != SocketClientEvent.TLS_HANDSHAKING)
        return;

    TlsClientConnection conn = (TlsClientConnection) connection;
    conn.accept_certificate.connect(acceptCert);
    conn.set_validation_flags(TlsCertificateFlags.VALIDATE_ALL);
}

public bool acceptCert (TlsCertificate peer_cert, TlsCertificateFlags errors)
{
    return true;
}