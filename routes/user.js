var crypto = require('crypto');
var obj_system = require('../objects/system');
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

	// Create validation value for new user
	shasum = crypto.createHash('sha1');
	shasum.update(user_data.user);
	var validation_value = shasum.digest('hex');

	// Create validation date limit for new user
	var validation_date = new Date();
	validation_date.setDate(validation_date.getDate() + 7);

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
			res.redirect('/sign_up?miss=2');
			return;
		}
		else
			dao.transaction(["INSERT INTO passkeys (user_id, pass, salt) VALUES ('" + user_data.user + "', '" + user_data.pass + "', '" + salt + "')",
				"INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added, validation_value, validation_date) VALUES ('" + user_data.user + "', 'user', '" + user_data.fname + "', '" + user_data.lname + "', '" + user_data.email + "', NOW(), '" + validation_value + "', STR_TO_DATE('" + validation_date + "', '%a %b %e %Y %H:%i:%s'))"], output, {val_value: validation_value, val_date: validation_date});
	}

	function output(success, results, vals)
	{
		if (success)
		{
			var body = "<h1>Thank you for registering!</h1>Please follow the link below to validate you email and start using the site.  You have <b> until " + vals.val_date.toDateString() + ' ' + vals.val_date.toLocaleTimeString() + " to do so before the request expires.</b> <p><a href='localhost/user/validate?v=" + vals.val_value + "'>Click here to validate your email</a></p>";
			obj_system.email('sgluebbert1@cougars.ccis.edu', 'Test', false, body, complete);
		}
		else
		{
			// error occured in transaction
			res.redirect('/500error');
		}
	}

	function complete(success)
	{
		if (success)
		{
			// email sent page
			res.redirect('/');
		}
		else
		{
			// email not sent page
			res.redirect('/500error');
		}
	}
}

exports.validate = function(req, res)
{
	if (req.query.v == undefined)
	{
		res.redirect('/');
		return;
	}

	var val_value = req.query.v.match(/[a-z0-9]+/gi)[0];

	var dao = new obj_dao.DAO();
	dao.query("SELECT user_id, validation_date FROM user WHERE validation_value = '" + val_value + "' LIMIT 1", output1);

	function output1(success, result, fields)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		if (result.length == 1)
		{
			var row = result[0];

			var today = new Date()
			var val_date = new Date(row.validation_date);

			if (today > val_date)
			{
				global.session.error_message.message = "Your validation period has elapsed.";
				res.redirect('/error');
				return;
			}

			dao.query("UPDATE user SET active = 1 WHERE user_id = '" + row.user_id + "' LIMIT 1", output2);
		}
	}

	function output2(success, result, fields)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		res.redirect('/login?v=1');
	}
}