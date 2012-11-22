var obj_dao = require('../objects/database');
var obj_picture = require('../objects/picture');
var obj_recipe = require('../objects/recipe');

function User(user_id, user_group, user_fname, user_lname, user_points, callback)
{
	this.id = user_id;
	this.group = user_group;
	this.picture = undefined;
	this.points = user_points;
	this.recipes = [];
	this.fname = user_fname;
	this.lname = user_lname;
	this.date_added = undefined;
	this.followers = [];
	this.confirmed_followers = 0;
	this.following = [];
	this.show_email = false;
	this.email = '';

	this.title = '';
	if (user_points < 100)
		this.title = CHEF_TITLES[0];
	else if (user_points < 200)
		this.title = CHEF_TITLES[1];
	else if (user_points < 400)
		this.title = CHEF_TITLES[2];
	else if (user_points < 800)
		this.title = CHEF_TITLES[3];
	else
		this.title = CHEF_TITLES[4];

	var dao = new obj_dao.DAO();

	this.set_picture = function(new_picture)
	{
		this.picture = new_picture;
	}

	load_followers = function(success, result, fields, vars)
	{
		if (!success)
		{
			vars.dao.die();
			vars.callback(0);
			return;
		}

		for (var i in result)
		{
			var row = result[i];
			if (row.user_id_1 == vars.user.id) // this follows
				vars.user.following.push({id: row.user_id_2, accepted: row.accepted, picture: new obj_picture.Picture(row.picture_id, row.caption, row.location)});
			else // this has follower
			{
				vars.user.followers.push({id: row.user_id_1, accepted: row.accepted, picture: new obj_picture.Picture(row.picture_id, row.caption, row.location)});
				if (row.accepted)
					vars.user.confirmed_followers += 1;
			}
		}

		vars.dao.die();
		vars.callback(success);
	}

	load_picture = function(success, result, fields, vars)
	{
		if (!success)
		{
			vars.dao.die();
			vars.callback(0);
			return;
		}

		var row = result[0];
		vars.user.set_picture(new obj_picture.Picture(row.picture_id, row.caption, row.location));
		
		// load followers
		dao.query("SELECT user_id_1, user_id_2, accepted, p.picture_id, p.location, p.caption FROM user_connections uc JOIN user u ON ((uc.user_id_1 = u.user_id AND NOT BINARY u.user_id = '"+dao.safen(vars.user.id)+"') OR (uc.user_id_2 = u.user_id AND NOT BINARY u.user_id = '"+dao.safen(vars.user.id)+"')) JOIN picture p ON u.picture_id = p.picture_id WHERE uc.active = 1 and (BINARY user_id_1 = '"+dao.safen(vars.user.id)+"' or BINARY user_id_2 = '"+dao.safen(vars.user.id)+"')", load_followers, vars);
	}

	dao.query("SELECT u.picture_id, caption, location FROM picture p JOIN user u ON p.picture_id = u.picture_id WHERE BINARY u.user_id = '"+dao.safen(this.id)+"' LIMIT 1", load_picture, {dao:dao, user:this, callback:callback});
}

exports.load_recipes = function(callback)
{
	var dao = new obj_dao.DAO();
	this.recipes = [];

	dao.query("SELECT r.recipe_id, recipe_name, c.category_name, r.public, r.serving_size, r.prep_time, r.ready_time, directions, DATE_FORMAT(date_added, '%c/%e/%Y %H:%i:%S') as date_added, DATE_FORMAT(date_edited, '%c/%e/%Y %H:%i:%S') as date_edited FROM recipe r JOIN category c ON r.category_id = c.category_id WHERE BINARY owner_id = '" + dao.safen(this.id) + "'", output1, {callback: callback, user: this});

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
			dao.query("SELECT COUNT(seen) as unseen_count FROM recipe_comment WHERE recipe_id = " + vars.user.recipes[vars.i].id + " AND seen = 0 AND NOT BINARY owner_id = '" + dao.safen(vars.user.id) + "'", output3, vars);
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
			dao.query("SELECT COUNT(seen) as unseen_count FROM recipe_comment WHERE recipe_id = " + dao.safen(vars.user.recipes[vars.i].id) + " AND seen = 0", output3, vars);
		else
		{
			vars.i = 0;
			dao.query("SELECT AVG(rank) as avg, COUNT(rank) as count FROM recipe_ranking WHERE recipe_id = " + dao.safen(vars.user.recipes[vars.i].id), output4, vars);
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
			dao.query("SELECT AVG(rank) as avg, COUNT(rank) as count FROM recipe_ranking WHERE recipe_id = " + dao.safen(vars.user.recipes[vars.i].id), output4, vars);		
		else
		{
			dao.die();
			vars.callback(true);
		}
	}
}

exports.User = User;