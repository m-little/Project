exports.Comment = function Comment(id_, owner_, owner_pic_, content_, date_added_, date_edited_)
{
	this.id = id_;
	this.owner = owner_;
	this.owner_picture_location = owner_pic;
	this.content = content_;
	this.date_added = date_added_;
	this.date_edited = date_edited_;
}