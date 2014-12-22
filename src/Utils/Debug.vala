using PhotoStream.Utils;

public void printFeed(List<MediaInfo> list)
{
	foreach(MediaInfo post in list)
        printPost(post);

}

public void printPost(MediaInfo post)
{
    print("Tags: ");
    foreach (string tag in post.tags)
        print("%s ", tag);

    print("Type: %s\n", post.type == PhotoStream.MediaType.IMAGE ? "image" : "video");
    print("Location: %s\n", post.location == null ? "(null)" : "");
    if (post.location != null)
        printLocation(post.location);

    print("Likes: %" + uint64.FORMAT_MODIFIER + "d\n ", post.likesCount);
    foreach (User user in post.likes)
    {
        print("\tusername: %s\n", user.username);
        print("\tprofilePicture: %s\n", user.profilePicture);
        print("\tid: %s\n", user.id);
        print("\tfullName: %s\n\n", user.fullName);
    }

    print("Image: \n");
    print("\turl: %s\n", post.media.url);
    print("\twidth: %" + uint64.FORMAT_MODIFIER + "d\n", post.media.width);
    print("\theight: %" + uint64.FORMAT_MODIFIER + "d\n", post.media.height);

    print("Users in photo: \n");
    foreach (TaggedUser user in post.taggedUsers)
    {
        print("\tPosition: %f %f\n", user.x, user.y);
        print("\tUser: \n");
        print("\t\tusername: %s\n", user.user.username);
        print("\t\tprofilePicture: %s\n", user.user.profilePicture);
        print("\t\tid: %s\n", user.user.id);
        print("\t\tfullName: %s\n\n", user.user.fullName);
    }
    

    print("\nComments:\n ");
    foreach (Comment comment in post.comments)
        printComment(comment);

    print("Filter: %s\n", post.filter);
    print("Creation time: %" + uint64.FORMAT_MODIFIER + "d\n", post.creationTime);
    print("Tagged users: \n");
    print("Title: %s\n", post.title == "" ? "<no title>" : post.title);
    print("User: \n");

    print("\tusername: %s\n", post.postedUser.username);
    print("\tprofilePicture: %s\n", post.postedUser.profilePicture);
    print("\tid: %s\n", post.postedUser.id);
    print("\tfullName: %s\n\n", post.postedUser.fullName);
    print("\tbio: %s\n", post.postedUser.bio);
    print("\twebsite: %s\n\n", post.postedUser.website);

    print("id: %s\n", post.id);
    print("didILikeThis: %s\n\n", post.didILikeThis ? "true" : "false");
}

public void printLocation(Location location)
{
    print("\tLatitude: %f\n", location.latitude);
    print("\tlongitude: %f\n", location.longitude);
    print("\tid: %" + uint64.FORMAT_MODIFIER + "d\n", location.id);
    print("\tname: %s\n\n", location.name);
}

public void printComment(Comment comment)
{
    print("\tCreation time: %" + uint64.FORMAT_MODIFIER + "d\n", comment.creationTime);
    print("\tText: %s\n", comment.text);      
    print("\tComment ID: %" + uint64.FORMAT_MODIFIER + "d\n", comment.id);
    print("\tUser:\n");
    print("\t\tusername: %s\n", comment.user.username);
    print("\t\tprofilePicture: %s\n", comment.user.profilePicture);
    print("\t\tid: %" + uint64.FORMAT_MODIFIER + "d\n", comment.user.id);
    print("\t\tfullName: %s\n\n", comment.user.fullName);
}

public void printActivityList(List<NewsActivity> activityList)
{
    foreach(NewsActivity activity in activityList)
        printActivity(activity);
}

public void printActivity(NewsActivity activity)
{
    print("Type: %s\n", activity.activityType);
    print("Username: %s\n", activity.username);
    print("User profile pic: %s\n", activity.userProfilePicture);
    print("Post id: %s\n", activity.postId);
    print("Date: %" + uint64.FORMAT_MODIFIER + "d\n", activity.time);
    print("Comment: %s\n\n", activity.comment);
}

public void printHistory (List<HistoryEntry> history)
{
    print("===\n");
    foreach(HistoryEntry entry in history)
        printHistoryEntry(entry);
    print("===\n");
}

public void printHistoryEntry (HistoryEntry entry)
{
    print("Type: %s\n", entry.type);
    print("Id: %s\n", entry.id);
}