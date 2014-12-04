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

public int64 loadDate()
{
	Settings settings = new GLib.Settings (PhotoStream.App.SCHEMA_URI);
    int64 date = (int64)settings.get_int(PhotoStream.App.SCHEMA_LAST_CHECKED);

    return date;
}

public void setCurrentDate()
{
	Settings settings = new GLib.Settings (PhotoStream.App.SCHEMA_URI);
    settings.set_int(PhotoStream.App.SCHEMA_LAST_CHECKED, (int)new GLib.DateTime.now_local().to_unix());
}

public void createSchema()
{
    error("Schema doesn't exist, exiting...\n");
}