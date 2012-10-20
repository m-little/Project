var obj_dao = require('../objects/database');
var obj_picture = require('../objects/picture');

function User(user_id, user_group, callback)
{
	this.id = user_id;
	this.group = user_group;
	this.picture = undefined;


	var dao = new obj_dao.DAO();

	this.set_picture = function(new_picture)
	{
		this.picture = new_picture;
	}

	load_picture = function(success, result, fields, vars)
	{
		var row = result[0];
		vars.user.set_picture(new obj_picture.Picture(row.picture_id, row.caption, row.location));
		vars.dao.die();
		vars.callback(success);
	}

	dao.query("SELECT u.picture_id, caption, location FROM picture p JOIN user u ON p.picture_id = u.picture_id WHERE u.user_id = '"+this.id+"' LIMIT 1", load_picture, {dao:dao, user:this, callback:callback});

}

exports.User = User;