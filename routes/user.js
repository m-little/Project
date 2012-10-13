var crypto = require('crypto');
var obj_dao = require('../objects/database');
var obj_user = require('../objects/user');

exports.create = function(req, res)
{
	if (req.body.username == undefined || req.body.username == '') // incorrect post data received. redirect. should never happen
	{
		res.redirect('/');
		return;
	}

	var user_data = {user: req.body.username, pass: req.body.password, pass_c: req.body.password_confirm, fname: req.body.first_name, lname: req.body.last_name, email: req.body.email};

	if (user_data.pass != user_data.pass_c)
	{
		res.redirect('/sign_up?miss=1');
		return;
	}

	var dao = new obj_dao.DAO();

	// Create salt for new user
	var shasum = crypto.createHash('sha1');
	shasum.update(Math.random().toString());
	var salt = shasum.digest('hex');

	// Create hashed password
	shasum = crypto.createHash('sha1');
	shasum.update(user_data.pass + salt);
	user_data.pass = shasum.digest('hex');

	// query 1
	// check to make sure user_id is not used (we should do this client side too)
	dao.query("SELECT user_id FROM passkeys WHERE user_id = '" + user_data.user + "' LIMIT 1", user_check);

	function user_check(success, result, fields) 
	{
		if (result.length != 0)
		{
			mysql.query('ROLLBACK', complete(false));
			res.redirect('/sign_up?miss=2');
			return;
		}
		else
			dao.transaction(["INSERT INTO passkeys (user_id, pass, salt) VALUES ('" + user_data.user + "', '" + user_data.pass + "', '" + salt + "')",
				"INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added) VALUES ('" + user_data.user + "', 'user', '" + user_data.fname + "', '" + user_data.lname + "', '" + user_data.email + "', NOW())"], output, user_data.user);
	}

	function output(success, results, user_id)
	{
		global.session.user = new obj_user.User(user_id, 'user', user_created);
	}

	function user_created(success)
	{
		global.session.logged_in = 1;
		res.redirect('/');
	}
}