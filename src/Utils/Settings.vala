public string loadToken()
{        
    string token;

    var source = SettingsSchemaSource.get_default();
    var lookup = source.lookup(PhotoStream.App.SCHEMA_URI, true);

    if (lookup == null) //schema doesn't exist
        createSchema();
    
    Settings settings = new GLib.Settings (PhotoStream.App.SCHEMA_URI);
    token = settings.get_string(PhotoStream.App.SCHEMA_TOKEN);

    return token;
}

public void setToken(string token)
{
    var settings = new GLib.Settings ("tk.itprogramming1.photostream");
    settings.set_string("token", token);
} 

public string loadAddress()
{        
    Settings settings = new GLib.Settings (PhotoStream.App.SCHEMA_URI);
    return settings.get_string(PhotoStream.App.SCHEMA_INSTAGRAM_IP);
}

public void setAddress(string ip)
{
    Settings settings = new GLib.Settings (PhotoStream.App.SCHEMA_URI);
    settings.set_string(PhotoStream.App.SCHEMA_INSTAGRAM_IP, ip);
}

public int64 loadDate()
{
	Settings settings = new GLib.Settings (PhotoStream.App.SCHEMA_URI);
    Variant date = settings.get_value(PhotoStream.App.SCHEMA_LAST_CHECKED);

    return date.get_int64();
}

public int loadRefreshInterval()
{
    Settings settings = new GLib.Settings (PhotoStream.App.SCHEMA_URI);
    return settings.get_int(PhotoStream.App.SCHEMA_REFRESH_INTERVAL);
}

public void setCurrentDate()
{
	Settings settings = new GLib.Settings (PhotoStream.App.SCHEMA_URI);
    settings.set_value(PhotoStream.App.SCHEMA_LAST_CHECKED, new Variant.int64(new GLib.DateTime.now_local().to_unix()));
}

public bool loadPostsOrImages()
{
    Settings settings = new GLib.Settings (PhotoStream.App.SCHEMA_URI);
    return settings.get_boolean(PhotoStream.App.SCHEMA_POSTS_OR_IMAGES);
}

public void setPostsOrImages(bool value)
{
    Settings settings = new GLib.Settings (PhotoStream.App.SCHEMA_URI);
    settings.set_boolean(PhotoStream.App.SCHEMA_POSTS_OR_IMAGES, value);
}

public void createSchema()
{
    error("Schema doesn't exist, exiting...\n");
}