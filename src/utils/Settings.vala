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

public void createSchema()
{
    print("Schema doesn't exist, creating one...\n");
}