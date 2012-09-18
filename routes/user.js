var _mysql = require('mysql');
var crypto = require('crypto');

exports.create = function(req, res)
{
	if (req.body.username == undefined || req.body.username == '') // incorrect post data received. redirect. should never happen so be suspicious if it does...
	{
		res.redirect('/');
		return;
	}

	var user_data = {user: req.body.username, pass: req.body.password, fname: req.body.first_name, lname: req.body.last_name, email: req.body.email};

	// Create salt for new user
	var shasum = crypto.createHash('sha1');
	shasum.update(Math.random().toString());
	var salt = shasum.digest('hex');

	// Create hashed password
	shasum = crypto.createHash('sha1');
	shasum.update(user_data.pass + salt);
	user_data.pass = shasum.digest('hex');

	var mysql = _mysql.createClient({host: mysql_vals.host,	port: mysql_vals.port, user: mysql_vals.user, password: mysql_vals.password});
	// use the project database
	mysql.query('USE ' + mysql_vals.database);
	mysql.query('BEGIN');

	// query 1
	mysql.query("INSERT INTO passkeys (user_id, pass, salt) VALUES ('" + user_data.user + "', '" + user_data.pass + "', '" + salt + "')", 
		function(err) 
		{
			if (err) 
			{
				mysql.query('ROLLBACK', complete(false));
				throw err;
			}
			else 
			{
				query2();
			}
		});

	function query2()
	{
		mysql.query("INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added) VALUES ('" + user_data.user + "', 'user', '" + user_data.fname + "', '" + user_data.lname + "', '" + user_data.email + "', NOW())", 
			function(err) 
			{
				if (err) 
				{
					mysql.query('ROLLBACK', complete(false));
					throw err;
				}
				else 
				{
					commit();
				}
			});
	}

	function commit()
	{
		mysql.query('COMMIT', complete(true));
		global.session.user = user_data.user;
		global.session.user_group = 'user';
	}

	function complete(success)
	{

		res.redirect('/');
	}
}