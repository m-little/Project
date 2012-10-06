var _mysql = require('mysql');
var obj_recipe = require('../objects/recipe');
var obj_ingredient = require('../objects/ingredient');
var obj_comment = require('../objects/comment');
var obj_picture = require('../objects/picture');

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

	req.query.r_id = parseInt(req.query.r_id);
	if (isNaN(req.query.r_id))
	{
		res.redirect('/');
		return;
	}

	var mysql = _mysql.createClient({host: mysql_vals.host,	port: mysql_vals.port, user: mysql_vals.user, password: mysql_vals.password});
	mysql.query('use ' + mysql_vals.database);

	mysql.query("SELECT recipe_name, owner_id, c.category_name, r.public, r.serving_size, r.prep_time, p.picture_id, p.location, p.caption, p.name, directions FROM recipe r JOIN picture p ON r.picture_id = p.picture_id JOIN category c ON r.category_id = c.category_id WHERE recipe_id = " + req.query.r_id, 
		function(err, result, fields) 
		{
			if (err) throw err;
			else 
			{
				if (result.length == 0) // no recipe found; should make this better later
				{
					res.redirect('/');
					mysql.end();
					return;
				}

				var row = result[0];
				if (row.public == '0' && row.owner_id != global.session.user.id)
				{
					res.redirect('/');
					mysql.end();
					return;
				}
				
				var new_picture = new obj_picture.Picture(row.picture_id, row.name, row.caption, row.location);
				var new_recipe = new obj_recipe.Recipe(req.query.id, row.owner_id, row.public, new_picture, row.recipe_name, row.category_name, row.serving_size, row.prep_time, row.directions);
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
					new_recipe.set_ingredients(ingredients);
					query3(new_recipe);
				}
			});
	}

	function query3(new_recipe)
	{
		mysql.query("SELECT comment_id, owner_id, content, c.date_added, c.date_edited, p.location FROM recipe_comment c JOIN user u ON c.owner_id = u.user_id JOIN picture p ON u.picture_id = p.picture_id WHERE recipe_id = " + req.query.r_id, 
			function(err, result, fields) 
			{
				if (err) throw err;
				else 
				{
					var comments = [];
					for (var i in result) 
					{
						var row = result[i];
						comments.push(new obj_comment.Comment(row.comment_id, row.owner_id, row.location, row.content, row.date_added, row.date_edited))
					}
					new_recipe.set_comments(comments);
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