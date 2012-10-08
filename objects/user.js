var obj_dao = require('./database');

function User(user_id, user_group)
{
	this.id = user_id;
	this.group = user_group;
	this.picture = undefined;

	// load user things
	// var dao = new obj_dao.DAO();

	// dao.query("SELECT u.picture_id, caption, location FROM picture p JOIN user u ON p.picture_id = u.picture_id WHERE u.user_id = '"+this.id+"' LIMIT 1", this.output1, this.picture);

	// this.output1 = function(result, fields, picture)
	// {
	// 	var row = result[0];

	// 	this.picture = new obj_picture.Picture(row.picture_id, row.caption, row.location);
	// 	dao.die();
	// }

	this.set_picture = function(new_picture)
	{
		this.picture = new_picture;
	}
}

exports.User = User;