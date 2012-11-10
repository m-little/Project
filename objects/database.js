var _mysql = require('mysql');

exports.DAO = function()
{
	this.client = _mysql.createClient({host: MYSQL_VALS.host,	port: MYSQL_VALS.port, user: MYSQL_VALS.user, password: MYSQL_VALS.password});

	// use the project database
	this.client.query('use ' + MYSQL_VALS.database);

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Generic query function
	//		carried_vars is optional
	//
	//		carried_vars is a variable you can use to carry variables from one function to another, it transfers right to the callback function.
	//			if you don't know if you should use this, you probably don't need to.
	//			ex. of why to use it: if an object is created and passed through a chain of functions for more use... pass it into carried_vars
	//			ask Sam if you have questions.
	this.query = function(sql_command, callback, carried_vars)
	{
		function output(err, result, fields) 
		{
			if (err)
			{
				//throw err;
				console.error(err.stack);
				callback(false, result, fields, carried_vars);
			}
			else 
			{
				callback(true, result, fields, carried_vars);
			}
		}

		this.client.query(sql_command, output);
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Generic transaction function
	//		carried_vars is optional
	//		^ see this.query for more info
	//
	//		this function uses the above query function for everything but the simple BEGIN, ROLLBACK, COMMIT;
	this.transaction = function(sql_commands, callback, carried_vars)
	{
		if (sql_commands.length == 0)
			callback(true, {});

		this.client.query('BEGIN');
		
		// Run first statement
		this.query(sql_commands[0], output, {sql_commands: sql_commands, i: 0, caller:this, callback: callback, results: [], carried_vars: carried_vars});

		function output(success, result, fields, vars)
		{
			if (!success)
			{
				// a problem occured! so rollback and return some error details
				vars.caller.client.query('ROLLBACK');
				vars.callback(false, {error_line:vars.i}, vars.carried_vars);
			}
			else 
			{
				// add this result set to the complete set results
				vars.results.push(result);
				// Move onto the next sql statement
				vars.i += 1;
				if (vars.i < vars.sql_commands.length)
				{
					vars.caller.query(vars.sql_commands[vars.i], output, vars);
				}
				else // No more statements so finish and return details
				{
					vars.caller.client.query('COMMIT');
					vars.callback(true, {results: vars.results}, vars.carried_vars);
				}
			}
		}
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Call this when you are done with the object
	this.die = function()
	{
		this.client.end();
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}