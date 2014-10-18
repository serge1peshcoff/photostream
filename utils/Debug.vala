using PhotoStream.Utils;

public void printFeed()
{
	foreach(MediaInfo post in PhotoStream.App.feedPosts)
    {
        print("Type: %s\n", post.type == PhotoStream.MediaType.IMAGE ? "image" : "video");
        print("Tags: ");
        foreach (string tag in post.tags)
            print("%s ", tag);

        print("\nComments:\n ");
        foreach (Comment comment in post.comments)
        {
            print("\tCreation time: %lld\n", comment.creationTime);
            print("\tText: %s\n", comment.text);      
			print("\tComment ID: %lld\n", comment.id);
			print("\tUser:\n");
			print("\t\tusername: %s\n", comment.user.username);
			print("\t\tprofilePicture: %s\n", comment.user.profilePicture);
			print("\t\tid: %lld\n", comment.user.id);
			print("\t\tfullName: %s\n\n", comment.user.fullName);
        }
        print("\nFilter: %s\n", post.filter);
        print("Creation time: %lld\n", post.creationTime);
        print("Likes: \n");
        print("Images: \n");
        print("Tagged users: \n");
        print("Title: %s\n", post.title == "" ? "<no title>" : post.title);
        print("User: \n");

        /*print("\tusername: %s\n", post.postedUser.username);
		print("\tprofilePicture: %s\n", post.postedUser.profilePicture);
		print("\tid: %lld\n", post.postedUser.id);
		print("\tfullName: %s\n\n", post.postedUser.fullName);*/
		print("id: %lld\n", post.id);
		print("didILikeThis: %s\n\n", post.didILikeThis ? "true" : "false");

    }

}