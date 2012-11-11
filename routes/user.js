var crypto = require('crypto');
var obj_system = require('../objects/system');
var obj_dao = require('../objects/database');
var obj_user = require('../objects/user');
var obj_notify = require('../objects/notifications');

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
			dao.transaction(["INSERT INTO passkeys (user_id, pass, salt) VALUES ('" + dao.safen(user_data.user) + "', '" + dao.safen(user_data.pass) + "', '" + salt + "')",
				"INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added, validation_value, validation_date) VALUES ('" + dao.safen(user_data.user) + "', 'user', '" + dao.safen(user_data.fname) + "', '" + dao.safen(user_data.lname) + "', '" + dao.safen(user_data.email) + "', NOW(), '" + validation_value + "', STR_TO_DATE('" + validation_date + "', '%a %b %e %Y %H:%i:%s'))"], output, {val_value: validation_value, val_date: validation_date});
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

exports.show_profile = function(req, res)
{
	if (req.query.u == undefined || req.query.u == '') // incorrect data received.
	{
		global.session.error_message.message = "User was undefined.";
		res.redirect('/error');
		return;
	}

	var user = undefined;
	var dao = new obj_dao.DAO();
	dao.query("SELECT user_id, user_group, user_fname, user_lname, show_email, email, user_points, date_added FROM user WHERE user_id = '" + dao.safen(req.query.u) + "'", output1);

	function output1(success, result, fields)
	{
		if (!success)
		{
			res.redirect('/500error');
			dao.die();
			return;
		}
		if (result.length != 1)
		{
			global.session.error_message.message = "Could not find user " + req.query.u + ".";
			dao.die();
			res.redirect('/error');
			return;
		}

		var row = result[0];
		user = new obj_user.User(row.user_id, row.user_group, row.user_fname, row.user_lname, row.user_points, load_recipes);
		user.date_added = row.date_added;
		user.show_email = row.show_email;
		if (row.show_email)
			user.email = row.email;
	}

	function load_recipes()
	{
		var load_recipes = obj_user.load_recipes.bind(user);
		load_recipes(finished);

		function finished(success)
		{
			if (!success)
			{
				dao.die();
				res.redirect('/500error');
				return;
			}

			var public_recipes = [];
			var private_recipes = [];
			for (var i in user.recipes)
			{
				if (user.recipes[i].public == 1)
					public_recipes.push(user.recipes[i]);
			}
			complete(public_recipes);
		}
	}

	function complete(public_recipes)
	{
		var follows = [false, false]; //follows and accepted

		if (global.session.logged_in)
		{
			for (var n in global.session.user.following)
			{
				if (global.session.user.following[n] != null && global.session.user.following[n].id == user.id)
				{
					follows = [true, global.session.user.following[n].accepted];
					break;
				}
			}
		}
		res.render('user/profile', { title: website_title, user: user, public_recipes: public_recipes, follows: follows });
	}
}

exports.update_follow = function(req, res)
{
	if (req.body.user == undefined || req.body.user == '') // incorrect data received.
	{
		global.session.error_message.message = "User was undefined.";
		res.redirect('/error');
		return;
	}

	var dao = new obj_dao.DAO();

	// Check for status
	dao.query("SELECT accepted, active FROM user_connections WHERE user_id_1 = '" + dao.safen(global.session.user.id) + "' and user_id_2 = '" + dao.safen(req.body.user) + "'", output1);

	function output1(success, result, fields)
	{
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}

		if (result.length == 0)
		{
			// Create new entry
			dao.query("INSERT INTO user_connections(user_id_1, user_id_2, date_added) VALUES ('" + dao.safen(global.session.user.id) + "', '" + dao.safen(req.body.user) + "', NOW())", complete1, 1);
		}
		else
		{
			var row = result[0];

			if (row.active == 1)
			{
				// "Remove" entry by setting active = 0
				dao.query("UPDATE user_connections SET active = 0 WHERE user_id_1 = '" + dao.safen(global.session.user.id) + "' and user_id_2 = '" + dao.safen(req.body.user) + "' LIMIT 1", complete1, 2);
			}
			else
			{
				// "Create" new entry from undoing active = 0
				dao.query("UPDATE user_connections SET active = 1, accepted = 0, date_created = NOW() WHERE user_id_1 = '" + dao.safen(global.session.user.id) + "' and user_id_2 = '" + dao.safen(req.body.user) + "' LIMIT 1", complete1, 1);
			}
		}
	}

	function complete1(success, result, fields, status)
	{
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}

		if (status == 2) // Removed
		{
			for (var n in global.session.user.following)
			{
				if (global.session.user.following[n] != null && global.session.user.following[n].id == req.body.user)
				{
					delete global.session.user.following[n];
					break;
				}
			}
		}
		else
		{
			var i = global.session.user.following.indexOf(null);
			if (i != -1)
			{
				global.session.user.following[i] = {id: req.body.user, accepted: false};
			}
			else
			{
				global.session.user.following.push({id: req.body.user, accepted: false});
			}
		}

		dao.die();
		res.send({status: status});
	}
}

exports.update_notifications = function(req, res)
{
	if (!global.session.logged_in)
	{
		res.redirect('/500error');
		return;
	}
	var check_all = obj_notify.check_all.bind(global.session.notifications);
	check_all(callback);

	function callback(success)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}
		res.send(global.session.notifications);
	}
}