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
        list.append(parseMediaPost(mediaPost));

    return list;
}

public MediaInfo parseMediaPost(Json.Node mediaPost) throws Error
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
    {
        info.location = new Location();
        info.location.latitude = (locationObject.get_object().has_member("latitude")) ? locationObject.get_object().get_double_member("latitude") : 0;
        info.location.longitude = (locationObject.get_object().has_member("longitude")) ? locationObject.get_object().get_double_member("longitude") : 0;
        info.location.name = (locationObject.get_object().has_member("name")) ? locationObject.get_object().get_string_member("name") : "";
        info.location.id = (locationObject.get_object().has_member("id")) ? locationObject.get_object().get_int_member("id") : 0;
    }

    var commentObject = mediaPostObject.get_member("comments").get_object(); //getting comments
    if (commentObject.get_int_member("count") != 0) //if there are any
        info.comments = parseComments(commentObject);
        

    info.filter = mediaPostObject.get_string_member("filter");
    info.creationTime = new DateTime.from_unix_utc(mediaPostObject.get_int_member("created_time")); //getting creation time
    info.link = mediaPostObject.get_string_member("link");


    var likeObject = mediaPostObject.get_member("likes").get_object(); //getting likes
    info.likesCount = likeObject.get_int_member("count");
    if (likeObject.get_int_member("count") != 0) //if there are any
        foreach(var like in likeObject.get_array_member("data").get_elements())
            info.likes.append(parseUserFromNode(like.get_object()));

    var imagesObject = mediaPostObject.get_member("images").get_object(); //getting image data
    var imageHiResObject = imagesObject.get_member("standard_resolution").get_object();
    info.image = new Image();
    info.image.url = imageHiResObject.get_string_member("url");
    info.image.width = imageHiResObject.get_int_member("width");
    info.image.height = imageHiResObject.get_int_member("height");


    var usersInPhoto = mediaPostObject.get_array_member("users_in_photo");
    if (usersInPhoto.get_length() > 0) //if there are any users
        foreach (var taggedUser in usersInPhoto.get_elements())
        {
            TaggedUser tu = new TaggedUser();
            tu.x = taggedUser.get_object().get_member("position").get_object().get_double_member("x");
            tu.y = taggedUser.get_object().get_member("position").get_object().get_double_member("y");
            //stdout.printf("%f %f\n", tu.x, tu.y);
            tu.user = new User();
            tu.user.username = taggedUser.get_object().get_member("user").get_object().get_string_member("username");
            tu.user.profilePicture = taggedUser.get_object().get_member("user").get_object().get_string_member("profile_picture");
            tu.user.id = taggedUser.get_object().get_member("user").get_object().get_string_member("id");
            tu.user.fullName = taggedUser.get_object().get_member("user").get_object().get_string_member("full_name");

            info.taggedUsers.append(tu);
        }

    var captionObject = mediaPostObject.get_member("caption");
    if (!captionObject.is_null()) //if there's a caption            
        info.title = captionObject.get_object().get_string_member("text"); //getting title text
    else //if no caption
        info.title = "";
    
    info.didILikeThis = mediaPostObject.get_boolean_member("user_has_liked"); //getting if I liked this or not
    info.id = mediaPostObject.get_string_member("id");
    
    var userObject = mediaPostObject.get_member("user").get_object(); //getting user data
    info.postedUser = new User();
    info.postedUser.username = userObject.get_string_member("username");
    info.postedUser.website = userObject.get_string_member("website");
    info.postedUser.profilePicture = userObject.get_string_member("profile_picture");
    info.postedUser.fullName = userObject.get_string_member("full_name");
    info.postedUser.bio = userObject.get_string_member("bio");
    info.postedUser.id = userObject.get_string_member("id");

    return info;
}   

public List<Comment> parseComments(Json.Object commentObject)
{
    List<Comment> commentsList = new List<Comment>();
    foreach(var comment in commentObject.get_array_member("data").get_elements())
    {
        
        Comment infoComment = new Comment();
        infoComment.creationTime = new DateTime.from_unix_utc(comment.get_object().get_int_member("created_time"));
        infoComment.text = comment.get_object().get_string_member("text");
        infoComment.id = (int64)comment.get_object().get_string_member("id");
        
        var commentedUser = comment.get_object().get_member("from").get_object();
        infoComment.user = new User();
        infoComment.user.username = commentedUser.get_string_member("username");
        infoComment.user.profilePicture = commentedUser.get_string_member("profile_picture");
        infoComment.user.id = commentedUser.get_string_member("id");
        infoComment.user.fullName = commentedUser.get_string_member("full_name");

        commentsList.append(infoComment);              
    }
    return commentsList;
}

public User parseUserFromNode(Json.Object userObject) throws Error
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
    return parseUserFromNode(response.get_object());
}

public string parseToken(string responce)
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

public MediaInfo parseImage(string message) throws Error
{
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);
    var response = root_object.get_member ("data");
    return parseMediaPost(response);
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
public void tryLoadMessage(Json.Parser parser, string message)
{
    try 
    {
        parser.load_from_data (message);
    }
    catch (Error e)
    {
        GLib.error("Something wrong with JSON parsing.\n");
    }
}

public string parsePagination(string message) throws Error
{
    var parser = new Json.Parser ();
    tryLoadMessage(parser, message);

    var root_object = parser.get_root().get_object();
    checkErrors(root_object);

    var paginationObject = root_object.get_member("pagination") .get_object();
    return paginationObject.get_string_member("next_url");  
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
        userList.append(parseUserFromNode(userNode.get_object()));        

    return userList;
}