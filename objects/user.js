function User(user_id, user_group)
{
	this.id = user_id;
	this.group = user_group;
	this.picture = undefined;

	this.set_picture = function(new_picture)
	{
		this.picture = new_picture;
	}
}

exports.User = User;