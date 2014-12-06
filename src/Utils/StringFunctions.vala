public string getFileName(string url)
{
    var indexStart = url.last_index_of("/") + 1;
    return url.substring(indexStart, url.length - indexStart);
}

public string replaceHostWithIp(string host, string ip)
{
	return host.replace("api.instagram.com", ip);
}