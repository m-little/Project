var _mysql = require('mysql');

exports.display_create = function(req, res)
{
	var mysql = _mysql.createClient({host: mysql_vals.host,	port: mysql_vals.port, user: mysql_vals.user, password: mysql_vals.password});
	mysql.query('use ' + mysql_vals.database);

	mysql.query("SELECT category_name FROM category ORDER BY category_name = '' DESC, use_count DESC", 
		function(err, result, fields) 
		{
			if (err) throw err;
			else 
			{
				var c = [];
				for (var i in result) 
				{
					var row = result[i];
					if (row.category_name == '')
						c.push("Select One");
					else
						c.push(row.category_name);
				}
				finished(c)
			}
		});
	
	function finished(categories_)
	{
		res.render('recipe/recipe_create', { title: website_title, categories: categories_ });

		mysql.end();
	}
}