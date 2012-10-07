// var _mysql = require('mysql');
var crypto = require('crypto');
var obj_dao = require('../objects/database');
var obj_user = require('../objects/user');

exports.check_credentials = function check_credentials(user, pass, callback)
{
	var logged_in = false;

	var dao = new obj_dao.DAO();

	function output(result, fields)
	{
		if (result.length == 0)
		{
			callback(0, '', '');
			return;
		}

		var row = result[0];

		// Create a hashed pass to compare with the stored one.
		var shasum = crypto.createHash('sha1');
		shasum.update(pass + row.salt);
		var new_pass = shasum.digest('hex');

		if (new_pass == row.pass)
		{
			logged_in = true;
			global.session.user = new obj_user.User(user, row.user_group);
			global.session.logged_in = 1;
		}

		callback(logged_in, user, row.user_group);
		dao.die();
	}

	dao.query("select p.user_id, pass, salt, user_group from passkeys p JOIN user u ON p.user_id = u.user_id WHERE p.user_id = '" + user + "' LIMIT 1", output);

	return logged_in;
}