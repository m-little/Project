// Global Vars
mysql_vals = {host: 'localhost', port: 3306, user: 'student', password: 'student', database: 'project'};
website_title = 'Website Name';

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
  app.use(express.static(path.join(__dirname, 'public')));

  // Error handling
  // plenty of room for expansion.
  // 500 Page
  app.use(function(err, req, res, next){
    console.error(err.stack);
    res.render('500error', { title: website_title, error: 500, location: req.url });
    });

  // 404 Page
  app.use(function(req, res, next){
    res.render('400error', { title: website_title, error: 404, location: req.headers.host + req.url });
    console.error("Could not handle request to " + req.url);
    });
});

// This block makes express give pretty error handling to the client, but it leaks environment info.
// app.configure('development', function(){
//   app.use(express.errorHandler());
// });

app.get('*', function(req, res, next) {
  if (req.session.logged_in == undefined)
    req.session.logged_in = 0;
  global.session = req.session;
  next();
  });

app.post('*', function(req, res, next) {
  global.session = req.session;
  next();
  });

app.get('/', routes.index);
app.get('/login', routes.login);
app.post('/login', routes.login);

app.get('/sign_up', routes.sign_up);
app.post('/user/new', user.create);

app.get('/recipe/create', recipe.display_create);
app.get('/recipe/view', recipe.display_view);
app.post('/recipe/comment_on', recipe.comment_on);

app.get('/wiki/view', wiki.display_view);

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});
