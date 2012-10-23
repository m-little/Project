var obj_dao = require('../objects/database');
var obj_picture = require('../objects/picture');
var obj_recipe = require('../objects/recipe');

function User(user_id, user_group, callback)
{
	this.id = user_id;
	this.group = user_group;
	this.picture = undefined;
	this.recipes = [];

	var dao = new obj_dao.DAO();

	this.set_picture = function(new_picture)
	{
		this.picture = new_picture;
	}

	load_picture = function(success, result, fields, vars)
	{
		var row = result[0];
		vars.user.set_picture(new obj_picture.Picture(row.picture_id, row.caption, row.location));
		vars.dao.die();
		vars.callback(success);
	}

	dao.query("SELECT u.picture_id, caption, location FROM picture p JOIN user u ON p.picture_id = u.picture_id WHERE u.user_id = '"+this.id+"' LIMIT 1", load_picture, {dao:dao, user:this, callback:callback});

}

exports.load_recipes = function(callback)
{
	var dao = new obj_dao.DAO();
	this.recipes = [];

	dao.query("SELECT r.recipe_id, recipe_name, c.category_name, r.public, r.serving_size, r.prep_time, r.ready_time, directions, DATE_FORMAT(date_added, '%c/%e/%Y %H:%i:%S') as date_added, DATE_FORMAT(date_edited, '%c/%e/%Y %H:%i:%S') as date_edited FROM recipe r JOIN category c ON r.category_id = c.category_id WHERE owner_id = '" + this.id + "'", output1, {callback: callback, user: this});

	function output1(success, result, fields, vars)
	{
		if (!success)
		{
			vars.callback(false);
			return;
		}

		for (var i in result)
		{
			var row = result[i];
			vars.user.recipes.push(new obj_recipe.Recipe(row.recipe_id, undefined, row.public, row.recipe_name, row.category_name, row.serving_size, row.prep_time, row.ready_time, row.directions, row.date_added, row.date_edited));
		}

		// value to loop through recipes to get pictures
		if (vars.user.recipes.length != 0)
		{
			vars.i = 0;
			dao.query("SELECT p.picture_id, p.caption, p.location FROM recipe_picture rp JOIN picture p ON rp.picture_id = p.picture_id WHERE rp.recipe_id = " + vars.user.recipes[vars.i].id, output2, vars);
		}
		else
		{
			dao.die();
			vars.callback(true);
		}
	}

	// next: pictures
	function output2(success, result, fields, vars)
	{
		if (!success)
		{
			vars.callback(false);
			return;
		}

		for (var i in result)
		{
			var row = result[i];
			vars.user.recipes[vars.i].pictures.push(new obj_picture.Picture(row.picture_id, row.caption, row.location));
		}

		vars.i++;
		if (vars.i < vars.user.recipes.length)
			dao.query("SELECT p.picture_id, p.caption, p.location FROM recipe_picture rp JOIN picture p ON rp.picture_id = p.picture_id WHERE rp.recipe_id = " + vars.user.recipes[vars.i].id, output2, vars);
		else
		{
			vars.i = 0;
			dao.query("SELECT COUNT(seen) as unseen_count FROM recipe_comment WHERE recipe_id = " + vars.user.recipes[vars.i].id + " AND seen = 0", output3, vars);
		}
	}

	// next: new comments
	function output3(success, result, fields, vars)
	{
		if (!success)
		{
			vars.callback(false);
			return;
		}

		for (var i in result)
		{
			var row = result[i];
			vars.user.recipes[vars.i].unseen_comment_count = row.unseen_count;
		}

		vars.i++;
		if (vars.i < vars.user.recipes.length)
			dao.query("SELECT COUNT(seen) as unseen_count FROM recipe_comment WHERE recipe_id = " + vars.user.recipes[vars.i].id + " AND seen = 0", output3, vars);
		else
		{
			vars.i = 0;
			dao.query("SELECT AVG(rank) as avg, COUNT(rank) as count FROM recipe_ranking WHERE recipe_id = " + vars.user.recipes[vars.i].id, output4, vars);
		}
	}

	// next: ranks
	function output4(success, result, fields, vars)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}
		
		var row = result[0];
		vars.user.recipes[vars.i].set_rank(row.avg, row.count);

		vars.i++;
		if (vars.i < vars.user.recipes.length)
			dao.query("SELECT AVG(rank) as avg, COUNT(rank) as count FROM recipe_ranking WHERE recipe_id = " + vars.user.recipes[vars.i].id, output4, vars);		
		else
		{
			dao.die();
			vars.callback(true);
		}
	}
}

exports.User = User;