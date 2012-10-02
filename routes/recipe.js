var _mysql = require('mysql');
var obj_recipe = require('../objects/recipe');
var obj_ingredient = require('../objects/ingredient');

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

exports.display_view = function(req, res)
{
	if (req.query.r_id == undefined) // No info on what recipe to show
	{
		res.redirect('/');
		return;
	}

	if (global.session.logged_in == 0)
	{
		res.redirect('/login');
		return;
	}

	var mysql = _mysql.createClient({host: mysql_vals.host,	port: mysql_vals.port, user: mysql_vals.user, password: mysql_vals.password});
	mysql.query('use ' + mysql_vals.database);

	mysql.query("SELECT recipe_name, owner_id, directions FROM recipe WHERE recipe_id = " + req.query.r_id, 
		function(err, result, fields) 
		{
			if (err) throw err;
			else 
			{
				if (result.length == 0) // no recipe found; should make this better later
				{
					res.redirect('/login');
					return;
				}
				
				var row = result[0];
				var new_recipe = new obj_recipe.Recipe(req.query.id, row.owner_id, row.recipe_name, row.directions);
				query2(new_recipe);
			}
		});

	function query2(new_recipe)
	{
		mysql.query("SELECT i.ingr_id, i.picture_id, i.ingr_name, u.unit_name, u.abrev, r.unit_amount FROM ingredient i JOIN recipe_ingredient r ON i.ingr_id = r.ingr_id JOIN unit u ON r.unit_id = u.unit_id WHERE r.recipe_id = " + req.query.r_id, 
			function(err, result, fields) 
			{
				if (err) throw err;
				else 
				{
					var ingredients = [];
					for (var i in result) 
					{
						var row = result[i];
						ingredients.push(new obj_ingredient.Ingredient(row.ingr_id, row.picture_id, row.ingr_name, row.unit_name, row.abrev, row.unit_amount))
					}
					new_recipe.add_ingredients(ingredients);
					finished(new_recipe);
				}
			});
	}
	
	function finished(new_recipe)
	{
		res.render('recipe/recipe_view', { title: website_title, recipe: new_recipe });

		mysql.end();
	}
}