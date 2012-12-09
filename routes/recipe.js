var obj_dao = require('../objects/database');
var obj_recipe = require('../objects/recipe');
var obj_ingredient = require('../objects/ingredient');
var obj_comment = require('../objects/comment');
var obj_picture = require('../objects/picture');
var obj_user = require('../objects/user');
var obj_preview = require('../objects/preview');


exports.home_view = function(req, res) {
	var dao = new obj_dao.DAO();

	//dao.query("select r.recipe_id, r.recipe_name, r.description from recipe r where r.public = 1 ORDER BY recipe_id DESC LIMIT 5;", output1);
	dao.query("select r.recipe_id, r.recipe_name, r.description, p.picture_id, p.caption, p.location from recipe r JOIN recipe_picture rp, picture p where r.public = 1 AND rp.recipe_id = r.recipe_id AND p.picture_id=rp.picture_id ORDER BY recipe_id DESC LIMIT 5 ;", output1);

	
	function output1(success, result, fields)
	{
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}

		var preview_array = new Array();


		// get the first row (should be the only row) from the results returned by the database
		for(var i in result)
		{
			
			var row = result[i];
			var new_picture = new obj_picture.Picture(row.picture_id, row.caption, row.location);
			var new_prev = new obj_preview.preview(row.recipe_id,row.recipe_name, row.description);
			new_prev.set_picture(new_picture);
			preview_array.push(new_prev);
		}
		
		//console.log(preview_array);
		dao.die();
		finished(preview_array);
	}

	function finished(new_recipe_home) 
	{
		console.log(new_recipe_home);
		res.render('recipe/recipe_home', { title: website_title, topFive: new_recipe_home});

	}

}

exports.display_create = function(req, res)
{
	if(!global.session.logged_in) {
		res.redirect('/login');
	}

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

		dao.query("SELECT unit_name, unit_id FROM unit", output2, c);
	}

	function output2(success, result, fields, category) 
	{
		var units = [];
		var units_id = [];
		for (var i in result)
		{
			var row = result[i];
			if(row.unit_name == '')
			{
				units.push("Select One");
				units.push("None");
				units_id.push(0);
				units_id.push(1);
			}
			else
			{
				units.push(row.unit_name);
				units_id.push(row.unit_id);
			}
		}
		dao.die();
		finished(category, units, units_id)
	}

	function finished(categories_, units, units_id)
	{
		res.render('recipe/recipe_create', { title: website_title, categories: categories_, units: units, units_id: units_id});
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
		global.session.error_message.message = "The recipe could not be found at the location given.";
		res.redirect('/error');
		return;
	}

	var dao = new obj_dao.DAO();

	// Command to start the whole chain of events of loading
	dao.query("SELECT recipe_name, owner_id, c.category_name, r.public, r.serving_size, r.prep_time, r.ready_time, directions, DATE_FORMAT(date_added, '%c/%e/%Y %H:%i:%S') as date_added, DATE_FORMAT(date_edited, '%c/%e/%Y %H:%i:%S') as date_edited FROM recipe r JOIN category c ON r.category_id = c.category_id WHERE recipe_id = " + req.query.r_id + " AND active = 1", output1);

	// first return for basic recipe info
	function output1(success, result, fields)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		if (result.length == 0) // no recipe found
		{
			global.session.error_message.code = "recipe_none";
			global.session.error_message.message = "That recipe does not seem to exist.";
			res.redirect('/error');
			return;
		}

		var row = result[0];
		if (row.public == '0' && (!global.session.logged_in || row.owner_id != global.session.user.id))
		{
			global.session.error_message.code = "recipe_private";
			global.session.error_message.message = "That recipe is currently private.";
			res.redirect('/error');
			return;
		}
		
		var new_recipe = new obj_recipe.Recipe(req.query.r_id, row.owner_id, row.public, row.recipe_name, row.category_name, row.serving_size, row.prep_time, row.ready_time, row.directions, row.date_added, row.date_edited);
		
		dao.query("SELECT p.picture_id, p.caption, p.location FROM recipe_picture rp JOIN picture p ON rp.picture_id = p.picture_id WHERE rp.recipe_id = " + req.query.r_id, output2, new_recipe);
	}

	// next: pictures
	function output2(success, result, fields, new_recipe)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		var pictures = [];
		for (var i in result) 
		{
			var row = result[i];
			pictures.push(new obj_picture.Picture(row.picture_id, row.caption, row.location))
		}
		new_recipe.set_pictures(pictures);

		dao.query("SELECT i.ingr_id, w.wiki_id, p.picture_id, p.caption, p.location, i.ingr_name, i.use_count, u.unit_name, u.abrev, r.unit_amount FROM ingredient i JOIN recipe_ingredient r ON i.ingr_id = r.ingr_id JOIN unit u ON r.unit_id = u.unit_id JOIN wiki w ON i.wiki_id = w.wiki_id JOIN picture p ON w.picture_id = p.picture_id WHERE r.recipe_id = " + req.query.r_id, output3, new_recipe);
	}

	// next: ingredients
	function output3(success, result, fields, new_recipe)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		var ingredients = [];
		for (var i in result) 
		{
			var row = result[i];
			ingredients.push(new obj_ingredient.Ingredient(row.ingr_id, new obj_picture.Picture(row.picture_id, row.caption, row.location), row.ingr_name, row.unit_name, row.abrev, row.unit_amount, row.use_count, row.wiki_id))
		}
		new_recipe.set_ingredients(ingredients);

		dao.query("SELECT comment_id, reply_comment_id, owner_id, user_points, content, seen, DATE_FORMAT(c.date_added, '%c/%e/%Y %H:%i:%S') AS date_added, DATE_FORMAT(c.date_edited, '%c/%e/%Y %H:%i:%S') as date_edited, p.picture_id, p.caption, p.location FROM recipe_comment c JOIN user u ON c.owner_id = u.user_id JOIN picture p ON u.picture_id = p.picture_id WHERE recipe_id = " + req.query.r_id + " ORDER BY comment_id, date_added", output4, new_recipe);
	}

	// next: comments
	function output4(success, result, fields, new_recipe)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

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
						comment_id.add_reply(new obj_comment.Comment(row.comment_id, {id: row.owner_id, points: row.user_points}, new obj_picture.Picture(row.picture_id, row.caption, row.location), row.content, row.date_added, row.date_edited, row.seen));
						was_reply = true;
						break;
					}
				}

			if (!was_reply)
				comments.push(new obj_comment.Comment(row.comment_id, {id: row.owner_id, points: row.user_points}, new obj_picture.Picture(row.picture_id, row.caption, row.location), row.content, row.date_added, row.date_edited, row.seen))
		}
		new_recipe.set_comments(comments);
		// Now flatten the comment/reply tree so it can be seen correctly on the page.
		new_recipe.flatten_comments();

		if (global.session.logged_in)
			if (new_recipe.owner == global.session.user.id)
				dao.query("UPDATE recipe_comment SET seen = 1 WHERE recipe_id = " + new_recipe.id, output5a, new_recipe);
			else
				dao.query("UPDATE recipe_shared SET seen = 1 WHERE recipe_id = " + new_recipe.id + " AND follower_id = '" + dao.safen(global.session.user.id) + "'", output5b, new_recipe);
		else
			dao.query("SELECT AVG(rank) as avg, COUNT(rank) as count FROM recipe_ranking WHERE recipe_id = " + req.query.r_id, output6, new_recipe);
	}

	// function returned when comments have been seen 
	function output5a(success, result, fields, new_recipe)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		for (var i in global.session.notifications.new_items)
		{
			var item = global.session.notifications.new_items[i];
			if (item.type == 0 && item.recipe_id == new_recipe.id)
			{
				delete global.session.notifications.new_items[i];
				global.session.notifications.actual_count -= 1;
			}
		}
		
		dao.query("UPDATE recipe_shared SET seen = 1 WHERE recipe_id = " + new_recipe.id + " AND follower_id = '" + dao.safen(global.session.user.id) + "'", output5b, new_recipe);
	}

	// function returned when recipe has been seen 
	function output5b(success, result, fields, new_recipe)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		for (var i in global.session.notifications.new_items)
		{
			var item = global.session.notifications.new_items[i];
			if (item.type == 2 && item.recipe_id == new_recipe.id)
			{
				delete global.session.notifications.new_items[i];
				global.session.notifications.actual_count -= 1;
			}
		}
		dao.query("SELECT AVG(rank) as avg, COUNT(rank) as count FROM recipe_ranking WHERE recipe_id = " + req.query.r_id, output6, new_recipe);
	}

	// next: rank
	function output6(success, result, fields, new_recipe)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}
		
		var row = result[0];
		new_recipe.set_rank(row.avg, row.count);

		global.session.user_recipe_rank = -1;
		if (global.session.logged_in)
		{
			dao.query("SELECT rank FROM recipe_ranking WHERE recipe_id = " + req.query.r_id + " AND BINARY owner_id = '" + global.session.user.id + "'", output7, new_recipe);
		}
		else
		{
			dao.die();
			finished(new_recipe);
		}
	}

	function output7(success, result, fields, new_recipe)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		if (result.length != 0)
		{
			var row = result[0];
			global.session.user_recipe_rank = row.rank;
		}

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
		global.session.error_message.message = "An error occured when linking to the recipe.";
		res.redirect('/error');
		return;
	}

	req.body.recipe_id = parseInt(req.body.recipe_id);
	if (isNaN(req.body.recipe_id))
	{
		global.session.error_message.message = "The recipe could not be found at the location given.";
		res.redirect('/error');
		return;
	}

	req.body.reply_comment = parseInt(req.body.reply_comment);
	if (isNaN(req.body.reply_comment))
	{
		global.session.error_message.message = "The comment could not be found at the location given.";
		res.redirect('/error');
		return;
	}

	var dao = new obj_dao.DAO();

	dao.query("INSERT INTO recipe_comment(owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('" + dao.safen(global.session.user.id) + "', " + req.body.recipe_id + ", " + req.body.reply_comment + ", '" + dao.safen(req.body.comment_content) + "', NOW())", output);

	function output(success, result, fields)
	{
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}
		else
		{
			dao.die();
			var date = new Date();
			res.send({new_id: result.insertId, date: date.toDateString() + " at " + (date.getHours() > 12 ? date.getHours() - 12 : date.getHours()) + ":" + (date.getMinutes() < 10 ? 0 : "") + date.getMinutes() + ":" + (date.getSeconds() < 10 ? 0 : "") + date.getSeconds() + (date.getHours() > 12 ? " pm" : " am"), user_pic: global.session.user.picture});
		}
	}
}

exports.edit_comment = function(req, res)
{
	req.body.edit_comment = parseInt(req.body.edit_comment);
	if (isNaN(req.body.edit_comment))
	{
		global.session.error_message.message = "The comment could not be found at the location given.";
		res.redirect('/error');
		return;
	}

	var dao = new obj_dao.DAO();

	dao.query("UPDATE recipe_comment SET content = '" + dao.safen(req.body.comment_content) + "', date_edited = NOW() WHERE comment_id = " + req.body.edit_comment, output);

	function output(success, result, fields)
	{
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}
		else
		{
			dao.die();
			var date = new Date();
			res.send({date: date.toDateString() + " at " + (date.getHours() > 12 ? date.getHours() - 12 : date.getHours()) + ":" + (date.getMinutes() < 10 ? 0 : "") + date.getMinutes() + ":" + (date.getSeconds() < 10 ? 0 : "") + date.getSeconds() + (date.getHours() > 12 ? " pm" : " am")});
		}
	}
}

exports.set_rank = function(req, res)
{
	if (req.body.recipe_id == undefined)
	{
		global.session.error_message.message = "An error occured when linking to the recipe.";
		res.redirect('/error');
		return;
	}

	req.body.recipe_id = parseInt(req.body.recipe_id);
	if (isNaN(req.body.recipe_id))
	{
		global.session.error_message.message = "The recipe could not be found at the location given.";
		res.redirect('/error');
		return;
	}

	req.body.rank = parseInt(req.body.rank);
	if (isNaN(req.body.rank))
	{
		global.session.error_message.message = "Unable to read new rank request.";
		res.redirect('/error');
		return;
	}

	if (req.body.rank < 0 || req.body.rank > 10)
	{
		global.session.error_message.message = "Rank value was out of bounds.";
		res.redirect('/error');
		return;
	}

	var dao = new obj_dao.DAO();

	// make sure theres no funny business of ranking your own recipe
	dao.query("SELECT recipe_id FROM recipe WHERE BINARY owner_id = '" + global.session.user.id + "' AND recipe_id = " + req.body.recipe_id, output1);

	function output1(success, result, fields)
	{
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}
		else
		{
			if (result.length != 0)
			{
				dao.die();
				global.session.error_message.message = "Sorry, you can not rank your own recipe.";
				res.redirect('/error');
				return;
			}
			// Set or update ranking
			if (global.session.user_recipe_rank != -1)
				dao.query("UPDATE recipe_ranking SET rank = " + req.body.rank + " WHERE BINARY owner_id = '" + global.session.user.id + "' AND recipe_id = " + req.body.recipe_id, output2);
			else
				dao.query("INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES ('" + global.session.user.id + "', " + req.body.recipe_id + ", " + req.body.rank + ", NOW())", output2);
		}
	}

	function output2(success, result, fields)
	{
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}
		else
		{
			// get new rank stats for recipe
			dao.query("SELECT AVG(rank) as avg, COUNT(rank) as count FROM recipe_ranking WHERE recipe_id = " + req.body.recipe_id, output3);
			global.session.user_recipe_rank = req.body.rank;
		}
	}

	function output3(success, result, fields)
	{
		if (!success || result.length == 0)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}
		else
		{
			var row = result[0];
			global.session.user_recipe_rank = req.body.rank;
			res.send({rank: req.body.rank, rank_avg: row.avg, rank_count: row.count});
			dao.die();
		}
	}
}

exports.my = function(req, res)
{
	if (!global.session.logged_in)
	{
		res.redirect('/login');
		return;
	}

	var load_recipes = obj_user.load_recipes.bind(global.session.user);
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
		for (var i in global.session.user.recipes)
		{
			if (global.session.user.recipes[i].public == 1)
				public_recipes.push(global.session.user.recipes[i]);
			else
				private_recipes.push(global.session.user.recipes[i]);
		}
		res.render('recipe/recipe_my', { title: website_title, public_recipes: public_recipes, private_recipes: private_recipes });
	}
}

exports.submit_recipe = function(req, res)
{
	var dao = new obj_dao.DAO();

	var recipe_obj = new Object();
	recipe_obj = (JSON.parse(req.body.recipe));

	var varification_success = "true";
	var recipe_id = "";

	validation();

	// Check for valid info 
	function validation() {
		var not_valid = new Array();

		if(recipe_obj.recipe_name == "") {
			varification_success = "false";
			not_valid.push("Recipe Name");
		}

		if(recipe_obj.category == "Select One") {
			varification_success = "false";
			not_valid.push("Category");
		}

		if(recipe_obj.ingredients == "") {
			varification_success = "false";
			not_valid.push("Ingredient");
		}

		if(recipe_obj.ingredient_unit_id == 0) {
			varification_success = "false";
			not_valid.push("Ingredient Unit");
		}

		if(recipe_obj.unit_amount == "") {
			varification_success = "false";
			not_valid.push("Ingredient Amount");
		}

		if(recipe_obj.ready_time == "00:00") {
			varification_success = "false";
			not_valid.push("Ready Time");
		}

		if(recipe_obj.directions == "") {
			varification_success = "false";
			not_valid.push("Directions");
		}

		// Send array of must enter inputs to user
		if(varification_success == "false") {
			dao.die();
			res.json(not_valid);
		}
		else {
			//insert recipe into recipe table
			dao.query("SELECT category_id FROM category WHERE LOWER(category_name) = LOWER('" + dao.safen(recipe_obj.category) + "')", output);
		}
	}

	function output(success, result, fields) {
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}
		else {		
			var row = result[0];
			dao.query("INSERT INTO recipe(owner_id, category_id, recipe_name, public, serving_size, prep_time, ready_time, directions, date_added) VALUES('" + global.session.user.id + "', " + row.category_id + ", '" + recipe_obj.recipe_name + "', " + recipe_obj.privacy_status + ", '" + recipe_obj.serving_size + "', '" + recipe_obj.preparation_time + "', '" + recipe_obj.ready_time + "', '" + recipe_obj.directions + "', NOW())", output2);
		}
    }

    function output2(success, result, fields) {
		if(!success) {
			dao.die();
			res.redirect('/500error');
			return;
		}

		dao.query("SELECT recipe_id FROM recipe WHERE LOWER(recipe_name) = LOWER('" + dao.safen(recipe_obj.recipe_name) + "')", set_recipe_id);
    }

    function set_recipe_id(success, result, fields) {
		if(!success) {
			dao.die();
			res.redirect('/500error');
			return;
		}

		var row = result[0];
		recipe_id = row.recipe_id;
    
	    //add ingredients to recipe
	    for(var i = 0; i < recipe_obj.ingredients.length; i++) {
	    	if(recipe_obj.ingredients[i] != "") {
		    	ingredient_name = recipe_obj.ingredients[i];
			    unit_id = recipe_obj.ingredient_unit_id[i];
	    		closure(i, ingredient_name, unit_id);
	    	}

		    function closure(i, ingredient, unit) {

		    	dao.query("SELECT ingr_name FROM ingredient WHERE LOWER(ingr_name) = LOWER('" + dao.safen(ingredient) + "')", output3);	    	

			   function output3(success, result, fields) {
					if(!success) {
						dao.die();
						res.redirect('/500error');
						return;
					}

					if(result.length == 0) {
						dao.query("INSERT INTO ingredient(ingr_name) VALUES('" + dao.safen(ingredient) + "')", output4);
					}
					else {
						get_ingredient_id();
					}
			    }

			    function output4(success, result, fields) {
					if(!success) {
						dao.die();
						res.redirect('/500error');
						return;
					}

					get_ingredient_id();
			    }

			    function get_ingredient_id() {
			    	dao.query("SELECT ingr_id FROM ingredient WHERE LOWER(ingr_name) = LOWER('" + dao.safen(ingredient) + "')", output5);
			    }

			    function output5(success, result, fields) {
					if(!success) {
						dao.die();
						res.redirect('/500error');
						return;
					}

					var row = result[0];
					add_recipe_ingredient(row.ingr_id);
			    }   

			    function add_recipe_ingredient(ingr_id) {
			    	dao.query("INSERT INTO recipe_ingredient(recipe_id, ingr_id, unit_id, unit_amount) VALUES(" + dao.safen(recipe_id) + ", " + dao.safen(ingr_id) + ", " + dao.safen(unit) + ", " + dao.safen(recipe_obj.unit_amount[i]) + ")", output6);
			    }

			    function output6(success, result, fields) {
					if(!success) {
						dao.die();
						res.redirect('/500error');
						return;
					}

					if(i == recipe_obj.ingredients.length - 1) {
						end();
					}
				}
	    	}
	    }
	}

    function end() {
		dao.die();
		res.writeHead(200, {"Content-Type": "text/html"});
		res.write(varification_success);
		res.end();
	}
}

exports.load_pictures = function(req, res)
{
	var dao = new obj_dao.DAO();
	var recipe_id = "";
	console.log(req.files);

	//get and set the recipe id
	dao.query("SELECT recipe_id FROM recipe WHERE LOWER(recipe_name) = LOWER('" + dao.safen(req.body.recipe_name) + "')", set_recipe_id);

	function set_recipe_id(success, result, fields) {
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}
		else {		
			var row = result[0];
			recipe_id = row.recipe_id;   

			// If no picture has been uploaded, make picture unknown
			if(req.files.recipe_pictures.size == 0) {
				var picture_id = 1;  //This is the id of the unknown picture
				insert_into_recipe_picture(picture_id);
			}
			else {
				var fs = require('fs');
				fs.readFile(req.files.recipe_pictures.path, function (err, data) {
					var newPath = "public/images/user_images/" + dao.safen(req.files.recipe_pictures.name);
					fs.writeFile(newPath, data, function (err) {
						if(err) {
							console.log(err);
							dao.die();
							res.redirect('/500error');
							return;
						}
						else {
							var picture_caption = set_picture_caption();

							//After the picture is stored in the user_images file, get recipe id.  
							dao.query("INSERT INTO picture(caption, location) VALUES('" + dao.safen(picture_caption) + "', '" + dao.safen(req.files.recipe_pictures.name) + "')", output);
						}
					});
				});
			}

			function output(success, result, fields) {
				if(!success) {
					dao.die();
					res.redirect('/500error');
					return;
				}
				else {		
					dao.query("SELECT picture_id FROM picture WHERE location = '" + dao.safen(req.files.recipe_pictures.name) + "'", output2);			
				}
		    }

		    function output2(success, result, fields) {
		    	if(!success) {
		    		dao.die();
					res.redirect('/500error');
					return;
				}
				else {		
					var row = result[0];
					var picture_id = row.picture_id;
					insert_into_recipe_picture(picture_id)
				}
		    }

		    function insert_into_recipe_picture(picture_id) {
				dao.query("INSERT INTO recipe_picture(recipe_id, picture_id) VALUES(" + dao.safen(recipe_id) + ", " + dao.safen(picture_id) + ")", output3);
		    }

		    function output3(success, result, fields) {
		    	if(!success) {
		    		dao.die();
					res.redirect('/500error');
					return;
				}
				else {
					dao.die();
					res.redirect('/recipe/view?r_id=' + recipe_id)
				}
		    }

		    function set_picture_caption() {
		    	var pic_caption = "";

				if(req.body.picture_caption == "") {
					pic_caption = "unknown";
				}
				else {
					pic_caption = req.body.picture_caption;
				}

				return pic_caption;
		    }
		}
	}
}

exports.display_edit = function(req, res)
{
	req.query.r_id = parseInt(req.query.r_id);
	if (isNaN(req.query.r_id))
	{
		global.session.error_message.message = "The recipe could not be found at the location given.";
		res.redirect('/error');
		return;
	}

	var dao = new obj_dao.DAO();

	var categories_list = new Array();
	var category_ids_list = new Array();
	var units_list = new Array();
	var unit_ids_list = new Array();

	dao.query("SELECT category_id, category_name FROM category ORDER BY category_name = '' DESC, use_count DESC", output);

	function output(success, result, fields)
	{
		for (var i in result) 
		{
			var row = result[i];
			if (row.category_name == '') {
				categories_list.push("Select One");
				category_ids_list.push(0);
			}
			else {
				categories_list.push(row.category_name);
				category_ids_list.push(row.category_id);
			}
		}

		dao.query("SELECT unit_name, unit_id FROM unit", output2);
	}

	function output2(success, result, fields) 
	{
		for (var i in result)
		{
			var row = result[i];
			if(row.unit_name == '')
			{
				units_list.push("Select One");
				units_list.push("None");
				unit_ids_list.push(0);
				unit_ids_list.push(1);
			}
			else
			{
				units_list.push(row.unit_name);
				unit_ids_list.push(row.unit_id);
			}
		}

		dao.query("SELECT recipe_name, owner_id, c.category_name, r.public, r.serving_size, r.prep_time, r.ready_time, directions, DATE_FORMAT(date_added, '%c/%e/%Y %H:%i:%S') as date_added, DATE_FORMAT(date_edited, '%c/%e/%Y %H:%i:%S') as date_edited FROM recipe r JOIN category c ON r.category_id = c.category_id WHERE recipe_id = " + req.query.r_id, output3);
	}

	// first return for basic recipe info
	function output3(success, result, fields)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		if (result.length == 0) // no recipe found
		{
			global.session.error_message.code = "recipe_none";
			global.session.error_message.message = "That recipe does not seem to exist.";
			res.redirect('/error');
			return;
		}

		var row = result[0];
		if (global.session.logged_in) {
			if (row.owner_id != global.session.user.id) {
				res.redirect('/login');
			}
		}
		else {
			res.redirect('/login');
		}
		
		var new_recipe = new obj_recipe.Recipe(req.query.r_id, row.owner_id, row.public, row.recipe_name, row.category_name, row.serving_size, row.prep_time, row.ready_time, row.directions, row.date_added, row.date_edited);
		
		dao.query("SELECT p.picture_id, p.caption, p.location FROM recipe_picture rp JOIN picture p ON rp.picture_id = p.picture_id WHERE rp.recipe_id = " + req.query.r_id, output4, new_recipe);
	}

	// next: pictures
	function output4(success, result, fields, new_recipe)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		var pictures = [];
		for (var i in result) 
		{
			var row = result[i];
			pictures.push(new obj_picture.Picture(row.picture_id, row.caption, row.location))
		}
		new_recipe.set_pictures(pictures);

		dao.query("SELECT i.ingr_id, w.wiki_id, p.picture_id, p.caption, p.location, i.ingr_name, i.use_count, u.unit_name, u.abrev, r.unit_amount FROM ingredient i JOIN recipe_ingredient r ON i.ingr_id = r.ingr_id JOIN unit u ON r.unit_id = u.unit_id JOIN wiki w ON i.wiki_id = w.wiki_id JOIN picture p ON w.picture_id = p.picture_id WHERE r.recipe_id = " + req.query.r_id, output5, new_recipe);
	}

	// next: ingredients
	function output5(success, result, fields, new_recipe)
	{
		if (!success)
		{
			res.redirect('/500error');
			return;
		}

		var ingredients = [];
		for (var i in result) 
		{
			var row = result[i];
			ingredients.push(new obj_ingredient.Ingredient(row.ingr_id, new obj_picture.Picture(row.picture_id, row.caption, row.location), row.ingr_name, row.unit_name, row.abrev, row.unit_amount, row.use_count))
		}

		new_recipe.set_ingredients(ingredients);
		dao.die();
		finished(new_recipe);
	}

	function finished(new_recipe)
	{
		res.render('recipe/recipe_edit', { title: website_title, recipe: new_recipe, categories: categories_list, category_ids: category_ids_list, units: units_list, unit_ids: unit_ids_list});
	}
}	

exports.submit_edit = function(req, res)
{
	var recipe_obj = new Object();
	var recipe = new Object();

	var x = "";
	var caption_count = 0;
	var new_ingr_count = 0;
	var unit_count = 0;
	var amount_count = 0;
	var deleted_count = 0;
	var category_id = 0;

	recipe_obj = (JSON.parse(req.body.recipe));
	recipe = (JSON.parse(req.body.recipe));

	var dao = new obj_dao.DAO();
	if(recipe_obj.category == "No changes made") {
		edit_check(1, x, x);
	}
	else {
		dao.query("SELECT category_id FROM category WHERE LOWER(category_name) = LOWER('" + dao.safen(recipe_obj.category) + "')", output);
	}

	function output(success, result, fields) {
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}
		else {		
			var row = result[0];
			category_id = row.category_id;
			edit_check(1, x, x);
		}
    }

	function edit_check(success, result, fields) {
		if(!success)
		{
			dao.die()
			res.redirect('/500error');
			return;
		}

		if(recipe_obj.deleted != "No changes made") {
			if(deleted_count >= recipe.deleted_ingredients.length - 1) {
				recipe_obj.deleted = "No changes made";
			}
			deleted_count++;
			dao.query("DELETE FROM recipe_ingredient WHERE recipe_id = " + recipe.recipe_id + " AND ingr_id = " + dao.safen(recipe.deleted_ingredients[deleted_count - 1]) + "", edit_check);
		}

		//Check to see if item need updating
		else if(recipe_obj.category != "No changes made") {
			recipe_obj.category = "No changes made";
			dao.query("UPDATE recipe SET category_id = " + dao.safen(category_id) + " WHERE recipe_id = " + recipe.recipe_id + "", edit_check);
		}

		else if(recipe_obj.recipe_name != "No changes made") {
			recipe_obj.recipe_name = "No changes made";
			dao.query("UPDATE recipe SET recipe_name = '" + dao.safen(recipe.recipe_name) + "' WHERE recipe_id = " + recipe.recipe_id + "", edit_check);
		}

		else if(recipe_obj.privacy != "No changes made") {
			recipe_obj.privacy = "No changes made";
			dao.query("UPDATE recipe SET public = " + dao.safen(recipe.privacy) + " WHERE recipe_id = " + recipe.recipe_id + "", edit_check);
		}

		else if(recipe_obj.caption_check != "No changes made") {
			if(caption_count >= recipe.picture_location.length - 1) {
				recipe_obj.caption_check = "No changes made";
			}
			caption_count++;
			dao.query("UPDATE picture SET caption = '" + dao.safen(recipe.picture_caption[caption_count - 1]) + "' WHERE location = '" + dao.safen(recipe.picture_location[caption_count - 1]) + "'", edit_check);
		}

		else if(recipe_obj.ingr_unit != "No changes made") {
			if(unit_count >= recipe.unit_id.length - 1) {
				recipe_obj.ingr_unit = "No changes made";
			}
			unit_count++;
			dao.query("UPDATE recipe_ingredient SET unit_id = " + dao.safen(recipe.unit_id[unit_count - 1]) + " WHERE recipe_id = " + recipe.recipe_id + " AND ingr_id = " + dao.safen(recipe.unit_ingr_id[unit_count - 1]) + "", edit_check);
		}

		else if(recipe_obj.ingr_amount != "No changes made") {
			if(amount_count >= recipe.amount.length - 1) {
				recipe_obj.ingr_amount = "No changes made";
			}
			amount_count++;
			dao.query("UPDATE recipe_ingredient SET unit_amount = " + dao.safen(recipe.amount[amount_count - 1]) + " WHERE recipe_id = " + recipe.recipe_id + " AND ingr_id = " + dao.safen(recipe.amount_ingr_id[amount_count - 1]) + "", edit_check);
		}

		else if(recipe_obj.new_ingredient != "No changes made") {
			if(new_ingr_count >= recipe.new_ingredient_name.length - 1) {
				recipe_obj.new_ingredient = "No changes made";
			}

			new_ingr_count++;
			dao.query("SELECT ingr_name FROM ingredient WHERE LOWER(ingr_name) = LOWER('" + dao.safen(recipe.new_ingredient_name[new_ingr_count - 1]) + "')", output);	    	

			function output(success, result, fields) {
				if(!success) {
					dao.die();
					res.redirect('/500error');
				return;
			}

				if(result.length == 0) {
					dao.query("INSERT INTO ingredient(ingr_name) VALUES('" + dao.safen(recipe.new_ingredient_name[new_ingr_count - 1]) + "')", output2);
				}
				else {
					get_ingredient_id();
				}
			}

			function output2(success, result, fields) {
				if(!success) {
					dao.die();
					res.redirect('/500error');
					return;
				}

				get_ingredient_id();
			}

			function get_ingredient_id() {
				dao.query("SELECT ingr_id FROM ingredient WHERE LOWER(ingr_name) = LOWER('" + dao.safen(recipe.new_ingredient_name[new_ingr_count - 1]) + "')", output3);
			}

			function output3(success, result, fields) {
				if(!success) {
					dao.die();
					res.redirect('/500error');
					return;
				}

				var row = result[0];
				dao.query("INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(" + recipe.recipe_id + ", " + row.ingr_id + ", " + dao.safen(recipe.new_ingredient_unit[new_ingr_count - 1]) + ", " + dao.safen(recipe.new_ingredient_amount[new_ingr_count - 1]) + ")", edit_check);
			}  
		}

		else if(recipe_obj.prep_time != "No changes made") {
			recipe_obj.prep_time = "No changes made";
			dao.query("UPDATE recipe SET prep_time = '" + dao.safen(recipe.prep_time) + "' WHERE recipe_id = " + recipe_obj.recipe_id + "", edit_check);
		}

		else if(recipe_obj.ready_time != "No changes made") {
			recipe_obj.ready_time = "No changes made";
			dao.query("UPDATE recipe SET ready_time = '" + dao.safen(recipe.ready_time) + "' WHERE recipe_id = " + recipe_obj.recipe_id + "", edit_check);
		}

		else if(recipe_obj.serving_size != "No changes made") {
			recipe_obj.serving_size = "No changes made";
			dao.query("UPDATE recipe SET serving_size = '" + dao.safen(recipe.serving_size) + "' WHERE recipe_id = " + recipe_obj.recipe_id + "", edit_check);
		}

		else if(recipe_obj.directions != "No changes made") {
			recipe_obj.directions = "No changes made";
			dao.query("UPDATE recipe SET directions = '" + dao.safen(recipe.directions) + "' WHERE recipe_id = " + recipe_obj.recipe_id + "", edit_check);
		}

		else {
			end();
		}
	}

	function end() {
		dao.die();
		res.end();	
	}
}	

exports.update_delete = function(req, res)
{
	var recipe_id = req.body.recipe_id
	var dao = new obj_dao.DAO();

	// delete recipe ingredients
	dao.query("UPDATE recipe SET active = 0 WHERE recipe_id = " + dao.safen(recipe_id) + "", output);

	function output(success, result, fields) {
		if (!success)
		{
			res.redirect('/500error');
			return;
		}	

		end();
	}

	function end() {
		dao.die();
		res.end();	
	}
}

exports.delete_picture = function(req, res)
{
	var recipe_obj = new Object();
	recipe_obj = (JSON.parse(req.body.recipe));

	var dao = new obj_dao.DAO();
	if(!(recipe_obj.picture_locations.length === undefined)) {
		for(var i = 0; i < recipe_obj.picture_locations.length; i++) {

			function delete_pic(i, picture_location) {
				dao.query("SELECT picture_id FROM picture WHERE location = '" + dao.safen(picture_location) + "'", output);

				// delete picture ingredients
				function output(success, result, fields) {
					if (!success)
					{
						res.redirect('/500error');
						return;
					}	

					var row = result[0];
					dao.query("DELETE FROM recipe_picture WHERE picture_id = " + dao.safen(row.picture_id) + " AND recipe_id = " + dao.safen(recipe_obj.recipe_id) + "", output2);
				}

				function output2(success, result, fields) {
					if (!success)
					{
						res.redirect('/500error');
						return;
					}	

					if(i == recipe_obj.picture_locations.length - 1) {
						end();
					}
				}
			}

			delete_pic(i, recipe_obj.picture_locations[i]);
		}
	}

	function end() {
		dao.die();
		res.end();	
	}
}
