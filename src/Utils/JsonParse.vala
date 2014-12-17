using PhotoStream.Utils;

public List<MediaInfo> parseFeed(string message) throws Error
{
    List<MediaInfo> list = new List<MediaInfo>();

	var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
    var response = root_object.get_array_member ("data");

    foreach (var mediaPost in response.get_elements ())  	
        list.append(parseMediaPostFromObject(mediaPost));

    return list;
}

public MediaInfo parseMediaPostFromObject(Json.Node mediaPost) throws Error
{
    MediaInfo info = new MediaInfo();
    var mediaPostObject = mediaPost.get_object();

    var tags = mediaPostObject.get_array_member ("tags"); //getting tags
    foreach (var tag in tags.get_elements())
        info.tags.append(tag.get_string());

    var type = mediaPostObject.get_string_member("type"); //media type
    if (type == "image")
        info.type = PhotoStream.MediaType.IMAGE;
    else if (type == "video")
        info.type = PhotoStream.MediaType.VIDEO;

    var locationObject = mediaPostObject.get_member("location"); //location
    if (!locationObject.is_null()) //if has location
        info.location = parseLocationFromObject(locationObject.get_object());        

    var commentObject = mediaPostObject.get_member("comments").get_object(); //getting comments
    if ((info.commentsCount = commentObject.get_int_member("count")) != 0) //if there are any
        info.comments = parseCommentsFromObject(commentObject);


    info.filter = mediaPostObject.get_string_member("filter");
    info.creationTime = new DateTime.from_unix_local(int64.parse(mediaPostObject.get_string_member("created_time"))); //getting creation time
    info.link = mediaPostObject.get_string_member("link");

    var likeObject = mediaPostObject.get_member("likes").get_object(); //getting likes
    info.likesCount = likeObject.get_int_member("count");
    if (likeObject.get_int_member("count") != 0) //if there are any
        foreach(var like in likeObject.get_array_member("data").get_elements())
            info.likes.append(parseUserFromObject(like.get_object()));

    if (info.type == PhotoStream.MediaType.IMAGE) //if image
    {
        var imagesObject = mediaPostObject.get_member("images").get_object(); //getting image data
        var imageHiResObject = imagesObject.get_member("standard_resolution").get_object();
        info.media = new Media();
        info.media.url = imageHiResObject.get_string_member("url");
        info.media.width = imageHiResObject.get_int_member("width");
        info.media.height = imageHiResObject.get_int_member("height");
    }
    else if (info.type == PhotoStream.MediaType.VIDEO) // if video, loading one
    {
        var videosObject = mediaPostObject.get_member("videos").get_object();
        var videoHiResObject = videosObject.get_member("standard_resolution").get_object();
        info.media = new Media();
        info.media.url = videoHiResObject.get_string_member("url");
        info.media.width = videoHiResObject.get_int_member("width");
        info.media.height = videoHiResObject.get_int_member("height");

        var imagesObject = mediaPostObject.get_member("images").get_object(); //getting image data
        var imageHiResObject = imagesObject.get_member("standard_resolution").get_object();
        info.media.previewUrl = imageHiResObject.get_string_member("url");
    }


    var usersInPhoto = mediaPostObject.get_array_member("users_in_photo");
    if (usersInPhoto.get_length() > 0) //if there are any users
        foreach (var taggedUser in usersInPhoto.get_elements())
        {
            TaggedUser tu = new TaggedUser();
            tu.x = taggedUser.get_object().get_member("position").get_object().get_double_member("x");
            tu.y = taggedUser.get_object().get_member("position").get_object().get_double_member("y");
            tu.user = parseUserFromObject(taggedUser.get_object().get_member("user").get_object());
            info.taggedUsers.append(tu);
        }

    var captionObject = mediaPostObject.get_member("caption");
    if (!captionObject.is_null()) //if there's a caption            
        info.title = captionObject.get_object().get_string_member("text"); //getting title text
    else //if no caption
        info.title = "";
    
    info.didILikeThis = mediaPostObject.get_boolean_member("user_has_liked"); //getting if I liked this or not
    info.id = mediaPostObject.get_string_member("id");
    
    info.postedUser = parseUserFromObject(mediaPostObject.get_member("user").get_object()); //getting user data

    return info;
}  

public Location parseLocationFromObject(Json.Object locationObject) throws Error
{
    var location = new Location();
    location.latitude = (locationObject.has_member("latitude") && !locationObject.get_member("latitude").is_null()) 
                                    ? locationObject.get_double_member("latitude") 
                                    : 0;
    location.longitude = (locationObject.has_member("longitude") && !locationObject.get_member("longitude").is_null()) 
                                    ? locationObject.get_double_member("longitude") 
                                    : 0;
    location.name = (locationObject.has_member("name")) ? locationObject.get_string_member("name") : "";
    location.id = (locationObject.has_member("id")) ? locationObject.get_int_member("id") : 0;
    return location;
} 

public List<Comment> parseCommentsFromObject(Json.Object commentObject) throws Error 
{
    List<Comment> commentsList = new List<Comment>();
    foreach(var comment in commentObject.get_array_member("data").get_elements())       
        commentsList.append(parseCommentFromObject(comment.get_object()));              
    return commentsList;
}

public Comment parseCommentFromObject(Json.Object comment) throws Error 
{   
    Comment infoComment = new Comment();
    infoComment.creationTime = new DateTime.from_unix_utc((int)comment.get_string_member("created_time"));
    infoComment.text = comment.get_string_member("text");
    infoComment.id = comment.get_string_member("id");
    
    var commentedUser = comment.get_member("from").get_object();
    infoComment.user = new User();
    infoComment.user.username = commentedUser.get_string_member("username");
    infoComment.user.profilePicture = commentedUser.get_string_member("profile_picture");
    infoComment.user.id = commentedUser.get_string_member("id");
    infoComment.user.fullName = commentedUser.get_string_member("full_name");

    return infoComment;          
}


public List<Comment> parseComments(string message) throws Error
{
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);

    return parseCommentsFromObject(root_object);  
}

public Comment parseCommentFromReply(string message) throws Error
{
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();

    return parseCommentFromObject(root_object);  
}

public User parseUserFromObject(Json.Object userObject) throws Error
{
    User user = new User();
            
    user.username = userObject.get_string_member("username");    
    user.profilePicture = userObject.get_string_member("profile_picture");
    user.id = userObject.get_string_member("id");    
    user.fullName = userObject.get_string_member("full_name");
    user.website = (userObject.has_member("website")) ? userObject.get_string_member("website") : "";
    user.bio = (userObject.has_member("bio")) ? userObject.get_string_member("bio") : "";
    if (userObject.has_member("counts"))
    {
        Json.Object countsObject = userObject.get_member("counts").get_object();
        user.mediaCount = countsObject.get_int_member("media");
        user.followers = countsObject.get_int_member("followed_by");
        user.followed = countsObject.get_int_member("follows");
    }

    return user;
}

public User parseUser(string message) throws Error
{
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
    var response = root_object.get_member ("data");
    return parseUserFromObject(response.get_object());
}

public string parseToken(string responce) throws Error
{
    var parser = new Json.Parser ();
    try 
    {
        parser.load_from_data (responce);
    }
    catch (Error e)
    {

    }    

    var root_object = parser.get_root().get_object();
    var token = root_object.get_string_member ("access_token");

    return token;
}

public MediaInfo parseMediaPost(string message) throws Error
{
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
    var response = root_object.get_member ("data");
    return parseMediaPostFromObject(response);
}

public void checkErrors(Json.Object root_object) throws Error
{   
    //parsing errors, if any
    var metaObject = root_object.get_member ("meta").get_object();
    if (metaObject.get_int_member("code") != 200)
    {
        string errorMessage = metaObject.get_string_member("error_message");
        throw new Error(Quark.from_string(errorMessage), (int)metaObject.get_int_member("code"), errorMessage);
    }    
}
public void tryLoadMessage(Json.Parser parser, string message) throws Error
{
    try 
    {
        parser.load_from_data (message);
    }
    catch (Error e)
    {
        GLib.error("Something wrong with JSON parsing: %s.\n", e.message);
    }
}

public string parsePagination(string message) throws Error
{
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);

    var paginationObject = root_object.get_member("pagination") .get_object();
    return paginationObject.has_member("next_url") ? paginationObject.get_string_member("next_url") : "";  
} 

public List<User> parseUserList(string message) throws Error
{
    List<User> userList = new List<User>();
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
    var response = root_object.get_array_member ("data");

    foreach(var userNode in response.get_elements())
        userList.append(parseUserFromObject(userNode.get_object()));        

    return userList;
}

public List<Tag> parseTagList(string message) throws Error
{
    List<Tag> tagList = new List<Tag>();
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
    var response = root_object.get_array_member ("data");

    foreach(var tagNode in response.get_elements())
        tagList.append(parseTagFromObject(tagNode.get_object()));

    return tagList;
}

public Tag parseTag(string message) throws Error
{
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
    var response = root_object.get_member ("data");

    return parseTagFromObject(response.get_object());
}

public Tag parseTagFromObject(Json.Object tagObject) throws Error
{
    Tag tag = new Tag();
    tag.tag = tagObject.get_string_member("name");
    tag.mediaCount = tagObject.get_int_member("media_count");
    return tag;
}

public Location parseLocation(string message) throws Error
{
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
    var response = root_object.get_member ("data");

    return parseLocationFromObject(response.get_object());
}
public List<Location> parseLocationList(string message) throws Error
{
    List<Location> locationList = new List<Location>();
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
    var response = root_object.get_array_member ("data");
    foreach(var locationNode in response.get_elements())
        locationList.append(parseLocationFromObject(locationNode.get_object()));

    return locationList;
}

public Relationship parseRelationship(string message) throws Error
{
    Relationship relationship = new Relationship();
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
    var response = root_object.get_member ("data").get_object();
    relationship.outcoming = response.has_member("outgoing_status") ? response.get_string_member("outgoing_status") : "";
    relationship.incoming = response.has_member("incoming_status") ? response.get_string_member("incoming_status") : "";

    return relationship;
}

public void parseErrors(string message) throws Error
{
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
}