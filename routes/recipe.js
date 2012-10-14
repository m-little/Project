var obj_dao = require('../objects/database');
var obj_recipe = require('../objects/recipe');
var obj_ingredient = require('../objects/ingredient');
var obj_comment = require('../objects/comment');
var obj_picture = require('../objects/picture');

exports.display_create = function(req, res)
{
	var dao = new obj_dao.DAO();

	dao.query("SELECT category_name FROM category ORDER BY category_name = '' DESC, use_count DESC", output);

	function output(success, result, fields)
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
		dao.die();
		finished(c)
	}

	function finished(categories_)
	{
		res.render('recipe/recipe_create', { title: website_title, categories: categories_ });
	}
}

exports.display_view = function(req, res)
{
	if (req.query.r_id == undefined) // No info on what recipe to show
	{
		res.redirect('/');
		return;
	}

	req.query.r_id = parseInt(req.query.r_id);
	if (isNaN(req.query.r_id))
	{
		res.redirect('/');
		return;
	}

	var dao = new obj_dao.DAO();

	// Command to start the whole chain of events of loading
	dao.query("SELECT recipe_name, owner_id, c.category_name, r.public, r.serving_size, r.prep_time, r.ready_time, directions, DATE_FORMAT(date_added, '%c/%e/%Y %H:%i:%S') as date_added, DATE_FORMAT(date_edited, '%c/%e/%Y %H:%i:%S') as date_edited FROM recipe r JOIN category c ON r.category_id = c.category_id WHERE recipe_id = " + req.query.r_id, output1);

	// first return for basic recipe info
	function output1(success, result, fields)
	{
		if (result.length == 0) // no recipe found; should make this better later
		{
			res.redirect('/');
			return;
		}

		var row = result[0];
		if (row.public == '0' && (!global.session.logged_in || row.owner_id != global.session.user.id))
		{
			res.redirect('/');
			return;
		}
		
		var new_recipe = new obj_recipe.Recipe(req.query.r_id, row.owner_id, row.public, row.recipe_name, row.category_name, row.serving_size, row.prep_time, row.ready_time, row.directions, row.date_added, row.date_edited);
		
		dao.query("SELECT p.picture_id, p.caption, p.location FROM recipe_picture rp JOIN picture p ON rp.picture_id = p.picture_id WHERE rp.recipe_id = " + req.query.r_id, output2, new_recipe);
	}

	// next: pictures
	function output2(success, result, fields, new_recipe)
	{
		var pictures = [];
		for (var i in result) 
		{
			var row = result[i];
			pictures.push(new obj_picture.Picture(row.picture_id, row.caption, row.location))
		}
		new_recipe.set_pictures(pictures);

		dao.query("SELECT i.ingr_id, i.picture_id, p.caption, p.location, i.ingr_name, u.unit_name, u.abrev, r.unit_amount FROM ingredient i JOIN recipe_ingredient r ON i.ingr_id = r.ingr_id JOIN unit u ON r.unit_id = u.unit_id JOIN picture p ON i.picture_id = p.picture_id WHERE r.recipe_id = " + req.query.r_id, output3, new_recipe);
	}

	// next: ingredients
	function output3(success, result, fields, new_recipe)
	{
		var ingredients = [];
		for (var i in result) 
		{
			var row = result[i];
			ingredients.push(new obj_ingredient.Ingredient(row.ingr_id, new obj_picture.Picture(row.picture_id, row.caption, row.location), row.ingr_name, row.unit_name, row.abrev, row.unit_amount))
		}
		new_recipe.set_ingredients(ingredients);

		dao.query("SELECT comment_id, reply_comment_id, owner_id, content, DATE_FORMAT(c.date_added, '%c/%e/%Y %H:%i:%S') AS date_added, DATE_FORMAT(c.date_edited, '%c/%e/%Y %H:%i:%S') as date_edited, p.picture_id, p.caption, p.location FROM recipe_comment c JOIN user u ON c.owner_id = u.user_id JOIN picture p ON u.picture_id = p.picture_id WHERE recipe_id = " + req.query.r_id + " ORDER BY comment_id, date_added", output4, new_recipe);
	}

	// next: comments
	function output4(success, result, fields, new_recipe)
	{
		var comments = [];
		for (var i in result) 
		{
			var row = result[i];

			var was_reply = false;
			// Recursively add replies to their rightful comments
			if (row.reply_comment_id != 0)
				for (var i = 0; i < comments.length; i++)
				{
					var comment_id;
					comment_id = comments[i].find_reply(row.reply_comment_id);
					if (comment_id != undefined)
					{
						comment_id.add_reply(new obj_comment.Comment(row.comment_id, row.owner_id, new obj_picture.Picture(row.picture_id, row.caption, row.location), row.content, row.date_added, row.date_edited));
						was_reply = true;
						break;
					}
				}

			if (!was_reply)
				comments.push(new obj_comment.Comment(row.comment_id, row.owner_id, new obj_picture.Picture(row.picture_id, row.caption, row.location), row.content, row.date_added, row.date_edited))
		}
		new_recipe.set_comments(comments);
		// Now flatten the comment/reply tree so it can be seen correctly on the page.
		new_recipe.flatten_comments();

		dao.query("SELECT AVG(rank) as avg, COUNT(rank) as count FROM recipe_ranking WHERE recipe_id = " + req.query.r_id, output5, new_recipe);
	}

	// next: rank
	function output5(success, result, fields, new_recipe)
	{
		var row = result[0];
		new_recipe.set_rank(row.avg, row.count);

		dao.die();
		finished(new_recipe);
	}
	
	function finished(new_recipe)
	{
		res.render('recipe/recipe_view', { title: website_title, recipe: new_recipe });
	}
}

exports.comment_on = function(req, res)
{
	if (req.body.recipe_id == undefined)
	{
		res.redirect('/');
		return;
	}

	req.body.recipe_id = parseInt(req.body.recipe_id);
	if (isNaN(req.body.recipe_id))
	{
		res.redirect('/');
		return;
	}

	req.body.reply_comment = parseInt(req.body.reply_comment);
	if (isNaN(req.body.reply_comment))
	{
		res.redirect('/');
		return;
	}

	var dao = new obj_dao.DAO();

	dao.query("INSERT INTO recipe_comment(owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('" + global.session.user.id + "', " + req.body.recipe_id + ", " + req.body.reply_comment + ", '" + req.body.comment_content + "', NOW())", output, req.body.recipe_id);

	function output(success, result, fields, recipe_id)
	{
		if (!success)
		{
			res.redirect('/');
			return;
		}
		else
			res.redirect('/recipe/view?r_id=' + recipe_id);
	}
}