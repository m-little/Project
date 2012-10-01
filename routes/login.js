var _mysql = require('mysql');
var crypto = require('crypto');

exports.check_credentials = function check_credentials(user, pass, callback)
{
	var logged_in = false;

	var mysql = _mysql.createClient({host: mysql_vals.host,	port: mysql_vals.port, user: mysql_vals.user, password: mysql_vals.password});

	// use the project database
	mysql.query('use ' + mysql_vals.database);

	mysql.query("select p.user_id, pass, salt, user_group from passkeys p JOIN user u ON p.user_id = u.user_id WHERE p.user_id = '" + user + "' LIMIT 1", 
		function(err, result, fields) 
		{
			if (err) throw err;
			else 
			{
				if (result.length == 0)
				{
					callback(0, '', '');
					return;
				}
				for (var i in result) 
				{
					var row = result[i];

					// Create a hashed pass to compare with the stored one.
					var shasum = crypto.createHash('sha1');
					shasum.update(pass + row.salt);
					var new_pass = shasum.digest('hex');

					if (new_pass == row.pass)
					{
						logged_in = true;
						global.session.user = user;
						global.session.user_group = row.user_group;
					}

					callback(logged_in, user, row.user_group);
				}
			}
		});

	mysql.end();

	return logged_in;
}