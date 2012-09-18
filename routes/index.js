var login = require('./login.js');

// in app.js too
var website_title = 'Website Name';

// Handling GET and POST data...
// req.query.blah = the GET variable named blah
// req.body.blah = the POST variable named blah

exports.index = function(req, res)
{
	if (req.query.logout == '1')
	{
		global.session.user = 'guest';
		req.session.user = 'guest';
		global.session.destroy();
	}

	res.render('index', { title: website_title });
};

exports.login = function(req, res)
{
	var success = -1; //-1 = hasn't tried logging in yet; 0 = fail; 1 = pass;

	function result(success, user, group)
	{
		if (success == 1)
			res.redirect('/');
		else
			res.render('login', { title: website_title, logged_in: success, username: user, user_group: group});
	}

	if (req.body.username != undefined || req.body.password != undefined)
	{
		login.check_credentials(req.body.username, req.body.password, result)
	}
	else //user hasn't tried to login yet. logged_in should = -1 still
		result(success)
};

exports.sign_up = function(req, res)
{
	res.render('sign_up', { title: website_title });
};