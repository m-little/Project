var crypto = require('crypto');
var obj_dao = require('../objects/database');
var obj_user = require('../objects/user');
var obj_picture = require('../objects/picture');
var obj_notify = require('../objects/notifications');

// location argument allows us to return to the page we were on when we tried to logon.

exports.check_credentials = function check_credentials(user, pass, callback, res, location)
{
	var logged_in = false;

	var dao = new obj_dao.DAO();

	function output(success, result, fields, vars)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		if (result.length == 0)
		{
			callback(0, '', '');
			return;
		}

		var row = result[0];

		if (row.active == 0) // user not validated yet
		{
			global.session.error_message.message = "It looks like you have not yet validated your email.";
			vars.res.redirect('/error');
			return;
		}

		// Create a hashed pass to compare with the stored one.
		var shasum = crypto.createHash('sha1');
		shasum.update(pass + row.salt);
		var new_pass = shasum.digest('hex');

		if (new_pass == row.pass)
		{
			logged_in = true;
			global.session.user = new obj_user.User(user, row.user_group, row.user_fname, row.user_lname, row.user_points, user_created);
			global.session.notifications = new obj_notify.Notifications(user);
			dao.die();
		}
		else
		{
			callback(logged_in, user, row.user_group, vars.location);
			dao.die();
		}

		function user_created(success)
		{
			if (!success)
			{
				res.redirect('/500error');
				return;
			}
			
			global.session.notifications.check_all(finished);
		}

		function finished(success)
		{
			if (!success)
			{
				res.redirect('/500error');
				return;
			}
			
			global.session.logged_in = 1;
			callback(logged_in, user, row.user_group, vars.location);
		}

	}

	dao.query("select p.user_id, pass, salt, user_group, user_fname, user_lname, user_points active from passkeys p JOIN user u ON p.user_id = u.user_id WHERE BINARY p.user_id = '" + dao.safen(user) + "' LIMIT 1", output, {res: res, location: location});

	return logged_in;
}