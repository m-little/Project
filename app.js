// Global Vars
MYSQL_VALS = {host: 'localhost', port: 3306, user: 'student', password: 'student', database: 'project'};
// date values are for formatting dates in all files
DATE_MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
DATE_DAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
CHEF_TITLES = ["Dish Washer", "Kitchen Assistant", "Chef de Partie", "Executive Chef", "Head Chef"];

website_title = 'Website Name';

// Turn on debug mode if you want to view:
//      - amount of database connections left open
debug_mode = false;

database_connections = 0;

var express = require('express')
	, routes = require('./routes')
	, http = require('http')
	, path = require('path')
	, user = require('./routes/user')
	, recipe = require('./routes/recipe')
	, wiki = require('./routes/wiki');

var app = express();

app.configure(function(){
	app.set('port', process.env.PORT || 80);
	app.set('views', __dirname + '/views');
	app.set('view engine', 'jade');
	app.use(express.favicon());
	app.use(express.logger('dev'));
	app.use(express.bodyParser());
	app.use(express.methodOverride());
	app.use(express.cookieParser());
	app.use(express.session({secret: 'Woawoawoawoah'}));
	app.use(app.router);
	app.use(express.static(path.join(__dirname, 'public'), {maxAge: 100*60*5}));

	// Error handling
	// plenty of room for expansion.
	// 500 Page
	app.use(function(err, req, res, next){
		console.error("###############################################################\033[31m\n" + (new Date()).toLocaleString() + "\n" + err.stack + "\033[0m");
		res.render('500error', { title: website_title, error: 500, location: req.url });
		});

	// 404 Page
	app.use(function(req, res, next){
		res.render('400error', { title: website_title, error: 404, location: req.headers.host + req.url });
		console.error("###############################################################\033[31m\n" + (new Date()).toLocaleString() + "\nCould not handle request to " + req.url + "\033[0m");
		});
});

// This block makes express give pretty error handling to the client, but it leaks environment info.
// app.configure('development', function(){
//	 app.use(express.errorHandler());
// });

app.get('*', function(req, res, next) {
	if (req.session.logged_in == undefined)
	{
		req.session.logged_in = 0;
		req.session.error_message = {code: '', message: ''};
	}
	global.session = req.session;
	next();
	});

app.post('*', function(req, res, next) {
	if (req.session.logged_in == undefined)
	{
		req.session.logged_in = 0;
		req.session.error_message = {code: '', message: ''};
	}
	global.session = req.session;
	next();
	});

app.get('/', routes.index);
app.post('/', routes.index);

app.get('/login', routes.login);
app.post('/login', routes.login);

app.get('/sign_up', routes.sign_up);
app.post('/user/new', user.create);
app.post('/user/lookup', user.lookup);
app.get('/user/validate', user.validate);
app.get('/user/profile', user.show_profile);
app.post('/user/update_follow', user.update_follow);
app.post('/user/update_notifications', user.update_notifications);

app.get('/recipe/create', recipe.display_create);
app.post('/recipe/submit', recipe.submit_recipe);
app.post('/recipe/pictures', recipe.load_pictures);
app.get('/recipe/edit', recipe.display_edit);
app.get('/recipe/view', recipe.display_view);
app.post('/recipe/comment_on', recipe.comment_on);
app.post('/recipe/set_rank', recipe.set_rank);
app.post('/recipe/edit_comment', recipe.edit_comment);
app.get('/recipe/my', recipe.my);

app.get('/wiki/view', wiki.display_view);
app.get('/wiki/home', wiki.home_view);

app.get('/error', function(req, res){
	res.render('error', { title: website_title, error: global.session.error_message });
	});
app.get('/500error', function(req, res){
    res.render('500error', { title: website_title, error: 500, location: req.url });
	});

http.createServer(app).listen(app.get('port'), function(){
	console.log("Express server listening on port " + app.get('port'));
	console.error("###############################################################\n" + "Non-Error: Express server listening on port " + app.get('port'));
});
