USE project;

-- This sql script will flush the database!!!
-- to update database with this script:
-- run command: mysql -u student -p
-- enter password student
-- run command: \. /usr/local/node/docs/project/database.sql

-- or ...

-- mysql --user=student --password=student < /usr/local/node/docs/project/database.sql
-- ^ this doesn't give you any feedback though...

DROP TRIGGER IF EXISTS tri_category_counter1;
DROP TRIGGER IF EXISTS tri_category_counter2;
DROP TRIGGER IF EXISTS tri_unit_ingr_counter1;
DROP TRIGGER IF EXISTS tri_unit_ingr_counter2;
DROP TRIGGER IF EXISTS tri_user_rank_counter1;
DROP TRIGGER IF EXISTS tri_user_rank_counter2;
DROP TRIGGER IF EXISTS tri_user_rank_counter3;
DROP TRIGGER IF EXISTS tri_user_rank_counter4;
DROP TRIGGER IF EXISTS tri_user_rank_counter5;
DROP TRIGGER IF EXISTS tri_user_rank_counter6;

DROP TABLE IF EXISTS recipe_ingredient;
DROP TABLE IF EXISTS ingredient;
DROP TABLE IF EXISTS unit;
DROP TABLE IF EXISTS recipe_comment;
DROP TABLE IF EXISTS recipe_ranking;
DROP TABLE IF EXISTS recipe_picture;
DROP TABLE IF EXISTS recipe;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS user_connections;
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS wiki_content;
DROP TABLE IF EXISTS wiki;
DROP TABLE IF EXISTS wiki_category;
DROP TABLE IF EXISTS picture;
DROP TABLE IF EXISTS passkeys;
DROP TABLE IF EXISTS video;

CREATE TABLE passkeys
(
user_id VARCHAR(40) NOT NULL,
pass VARCHAR(40) NOT NULL,
salt VARCHAR(40) NOT NULL,
CONSTRAINT pk_passkeys PRIMARY KEY(user_id)
);

CREATE TABLE picture
(
picture_id SERIAL NOT NULL AUTO_INCREMENT,
name VARCHAR(40) NOT NULL,
caption VARCHAR(50),
location VARCHAR(100),
CONSTRAINT pk_picture PRIMARY KEY(picture_id)
);

CREATE TABLE video
(
video_id SERIAL NOT NULL AUTO_INCREMENT,
name VARCHAR(40) NOT NULL,
caption VARCHAR(50),
address VARCHAR(100),
CONSTRAINT pk_video PRIMARY KEY(video_id)
);

CREATE TABLE wiki
(
wiki_id SERIAL,
video_id BIGINT UNSIGNED,
wiki_cat_id BIGINT UNSIGNED,
wiki_title VARCHAR(40) NOT NULL,
CONSTRAINT pk_wiki PRIMARY KEY(wiki_id),
CONSTRAINT fk_wiki_video FOREIGN KEY(video_id) REFERENCES video(video_id)
);

CREATE TABLE wiki_category
(
wiki_cat_id SERIAL NOT NULL AUTO_INCREMENT,
category_name VARCHAR(40) NOT NULL,
use_count INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_wiki_cat PRIMARY KEY(wiki_cat_id)
);

CREATE TABLE wiki_content
(
wiki_cont_id SERIAL,
wiki_id BIGINT UNSIGNED NOT NULL,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
title VARCHAR(40),
content TEXT NOT NULL,
CONSTRAINT pk_wiki_cont PRIMARY KEY(wiki_cont_id),
CONSTRAINT fk_wiki FOREIGN KEY(wiki_id) REFERENCES wiki(wiki_id),
CONSTRAINT fk_cont_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
);

CREATE TABLE user
(
user_id VARCHAR(40) NOT NULL UNIQUE,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
user_group VARCHAR(20) NOT NULL,
user_fname VARCHAR(40) NOT NULL,
user_lname VARCHAR(40) NOT NULL,
email VARCHAR(50) NOT NULL,
date_added DATETIME NOT NULL,
user_points INT UNSIGNED NOT NULL DEFAULT 0,
active TINYINT(1) DEFAULT 1,
show_email TINYINT(1) DEFAULT 0,
validation_value VARCHAR(40) DEFAULT '',
validation_date DATETIME NOT NULL DEFAULT 0,
CONSTRAINT pk_user PRIMARY KEY(user_id),
CONSTRAINT fk_user_passkeys FOREIGN KEY(user_id) REFERENCES passkeys(user_id),
CONSTRAINT fk_user_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
);

CREATE TABLE user_connections
(
connection_id SERIAL,
user_id_1 VARCHAR(40) NOT NULL,
user_id_2 VARCHAR(40) NOT NULL,
accepted TINYINT(1) NOT NULL DEFAULT 0,
active TINYINT(1) NOT NULL DEFAULT 1,
CONSTRAINT pk_user_connections PRIMARY KEY(connection_id),
CONSTRAINT fk_user_1 FOREIGN KEY(user_id_1) REFERENCES user(user_id),
CONSTRAINT fk_user_2 FOREIGN KEY(user_id_2) REFERENCES user(user_id)
);

CREATE TABLE category
(
category_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
category_name VARCHAR(40) NOT NULL,
use_count INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_category PRIMARY KEY(category_id)
);

CREATE TABLE recipe
(
recipe_id SERIAL,
owner_id VARCHAR(40) NOT NULL,
category_id SMALLINT UNSIGNED NOT NULL,
recipe_name VARCHAR(40) NOT NULL,
public TINYINT(1) NOT NULL DEFAULT 1,
serving_size VARCHAR(10) DEFAULT '0-0',
prep_time TIME DEFAULT 0,
ready_time TIME DEFAULT 0,
directions TEXT NOT NULL,
date_added DATETIME NOT NULL,
date_edited DATETIME,
active TINYINT(1) NOT NULL DEFAULT 1,
CONSTRAINT pk_recipe PRIMARY KEY(recipe_id),
CONSTRAINT fk_recipe_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_category FOREIGN KEY(category_id) REFERENCES category(category_id)
);

CREATE TABLE recipe_picture
(
recipe_picture_id SERIAL,
recipe_id BIGINT UNSIGNED NOT NULL,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
CONSTRAINT pk_recipe_picture PRIMARY KEY(recipe_picture_id),
CONSTRAINT fk_recipe_picture_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id),
CONSTRAINT fk_recipe_picture_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
);

CREATE TABLE recipe_comment
(
comment_id SERIAL,
owner_id VARCHAR(40) NOT NULL,
recipe_id BIGINT UNSIGNED NOT NULL,
reply_comment_id BIGINT UNSIGNED DEFAULT 0,
content VARCHAR(500) NOT NULL,
date_added DATETIME NOT NULL,
date_edited DATETIME,
seen TINYINT(1) NOT NULL DEFAULT 0,
CONSTRAINT pk_comment PRIMARY KEY(comment_id),
CONSTRAINT fk_recipe_comment_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_comment_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id)
);

CREATE TABLE recipe_ranking
(
rank_id SERIAL,
owner_id VARCHAR(40) NOT NULL,
recipe_id BIGINT UNSIGNED NOT NULL,
rank TINYINT UNSIGNED DEFAULT 0,
date_added DATETIME NOT NULL,
date_edited DATETIME,
CONSTRAINT pk_recipe_ranking PRIMARY KEY(rank_id),
CONSTRAINT fk_recipe_ranking_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_ranking_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id)
);

CREATE TABLE unit
(
unit_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
unit_name VARCHAR(20) NOT NULL,
abrev VARCHAR(10) DEFAULT '',
use_count INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_unit PRIMARY KEY(unit_id)
);

CREATE TABLE ingredient
(
ingr_id SERIAL,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
ingr_name VARCHAR(40) NOT NULL,
use_count INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_ingredient PRIMARY KEY(ingr_id),
CONSTRAINT fk_ingredient_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
);

CREATE TABLE recipe_ingredient
(
recipe_ingr_id SERIAL,
recipe_id BIGINT UNSIGNED NOT NULL,
ingr_id BIGINT UNSIGNED NOT NULL,
unit_id SMALLINT UNSIGNED NOT NULL,
unit_amount DOUBLE(7,4) NOT NULL,
CONSTRAINT fk_rec_ingr_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id),
CONSTRAINT fk_rec_ingr_ingr FOREIGN KEY(ingr_id) REFERENCES ingredient(ingr_id),
CONSTRAINT fk_rec_ingr_unit FOREIGN KEY(unit_id) REFERENCES unit(unit_id),
CONSTRAINT pk_rec_ingr PRIMARY KEY(recipe_ingr_id)
);

-- Triggers

delimiter |

CREATE TRIGGER tri_category_counter1 AFTER INSERT ON recipe
	FOR EACH ROW BEGIN
		UPDATE category SET use_count = use_count + 1 WHERE category_id = NEW.category_id;
		IF NEW.public = 1 THEN
			UPDATE user SET user_points = user_points + 10 WHERE user_id = NEW.owner_id;
		END IF;
	END;
|

CREATE TRIGGER tri_category_counter2 AFTER DELETE ON recipe
	FOR EACH ROW BEGIN
		UPDATE category SET use_count = use_count - 1 WHERE category_id = OLD.category_id;
		IF OLD.public = 1 AND OLD.active = 1 THEN
			UPDATE user SET user_points = user_points - 10 WHERE user_id = OLD.owner_id;
		END IF;
	END;
|

CREATE TRIGGER tri_unit_ingr_counter1 AFTER INSERT ON recipe_ingredient
	FOR EACH ROW BEGIN
		UPDATE unit SET use_count = use_count + 1 WHERE unit_id = NEW.unit_id;
		UPDATE ingredient SET use_count = use_count + 1 WHERE ingr_id = NEW.ingr_id;
	END;
|

CREATE TRIGGER tri_unit_ingr_counter2 AFTER DELETE ON recipe_ingredient
	FOR EACH ROW BEGIN
		UPDATE unit SET use_count = use_count - 1 WHERE unit_id = OLD.unit_id;
		UPDATE ingredient SET use_count = use_count - 1 WHERE ingr_id = OLD.ingr_id;
	END;
|

CREATE TRIGGER tri_user_rank_counter1 AFTER INSERT ON recipe_ranking
	FOR EACH ROW BEGIN
		UPDATE user SET user_points = user_points + (NEW.rank * 3) WHERE user_id = (SELECT r.owner_id FROM recipe r JOIN recipe_ranking rr ON r.recipe_id = rr.recipe_id WHERE r.recipe_id = NEW.recipe_id LIMIT 1);
	END;

CREATE TRIGGER tri_user_rank_counter2 AFTER UPDATE ON recipe_ranking
	FOR EACH ROW BEGIN
		UPDATE user SET user_points = user_points + (NEW.rank * 3) - (OLD.rank * 3) WHERE user_id = (SELECT r.owner_id FROM recipe r JOIN recipe_ranking rr ON r.recipe_id = rr.recipe_id WHERE r.recipe_id = NEW.recipe_id LIMIT 1);
	END;

CREATE TRIGGER tri_user_rank_counter3 AFTER DELETE ON recipe_ranking
	FOR EACH ROW BEGIN
		UPDATE user SET user_points = user_points - (OLD.rank * 3) WHERE user_id = (SELECT r.owner_id FROM recipe r JOIN recipe_ranking rr ON r.recipe_id = rr.recipe_id WHERE r.recipe_id = OLD.recipe_id LIMIT 1);
	END;

CREATE TRIGGER tri_user_rank_counter4 AFTER INSERT ON user_connections
	FOR EACH ROW BEGIN
		IF NEW.accepted = 1 
			THEN UPDATE user SET user_points = user_points + 1 WHERE user_id = NEW.user_id_2;
		END IF;
	END;

CREATE TRIGGER tri_user_rank_counter5 AFTER UPDATE ON user_connections
	FOR EACH ROW BEGIN
		IF NEW.active = 0 AND OLD.accepted = 1 THEN 
			UPDATE user SET user_points = user_points - 1 WHERE user_id = NEW.user_id_2;
		END IF;
		IF NEW.active = 1 AND NEW.accepted = 1 THEN 
			UPDATE user SET user_points = user_points + 1 WHERE user_id = NEW.user_id_2;
		END IF;
	END;

CREATE TRIGGER tri_user_rank_counter6 AFTER UPDATE ON recipe
	FOR EACH ROW BEGIN
		IF OLD.public = 1 AND OLD.active = 1 THEN
			IF NEW.public = 0 OR NEW.active = 0 THEN
				UPDATE user SET user_points = user_points - 10 WHERE user_id = NEW.owner_id;
			END IF;
		ELSEIF NEW.public = 1 AND NEW.active = 1 THEN
			UPDATE user SET user_points = user_points + 10 WHERE user_id = NEW.owner_id;
		END IF;
	END;
|

delimiter ;

INSERT INTO passkeys (user_id, pass, salt) VALUES('Sam', 'e233560939c66735c503f136f32a431cb203db78', 'aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Mike', '4d00564fd19d74efff6ba1f392f757f33fca273b', '4196ce6a9377e11ecc9f01517e8a118c4b596646');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Julia', '9bb9949ea212c05242d0110858987af879c84041', '5fc0d6f9d1b18a1a28738a9834ef6bf12c2716f9');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Curtis', '041b2e52b42326af4c9ac9c63504dd623ab51895', '1019078d1d90533aed697b1e94fbdba9bf3f4d4a');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Mona', 'eb99762e96c220d67e6683c25fcd3666ea67041b', 'aecbe931addcaba9bf8eaeaa92606fc6d1b35857');
INSERT INTO passkeys (user_id, pass, salt) VALUES('James', '047281f78707c60625a3c16b5c23daa664e0b09d', '81bb94396ea3e8ff99b9fc3d9ffcd0510d979e0c');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Catherine', 'e540334e5f07b9b136c5b0b489df7a2efa736947', '73e8a8b5c53e648b2ce978a499edba4e64482d99');
INSERT INTO passkeys (user_id, pass, salt) VALUES('John', '2eb605c2fcd4b05b709bef4cad5ecd289139a143', 'a8f474ca1460e5670c1f0756b99f4d9a01ffbab9');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Felicia', 'bcf3f218b57a5362e3162b77d1dfb54167923618', 'c031c0deb66133614c85bdc40a8019ec90c01b98');

INSERT INTO picture (name, caption, location) VALUES('unknown', 'No Picture', 'unknown.png'); -- 1
INSERT INTO picture (name, caption, location) VALUES('sam1', 'Sam Luebbert', 'sam1.png'); -- 2
INSERT INTO picture (name, caption, location) VALUES('Potato Salad', 'Potato Salad Yum!', 'pre_1.jpg'); -- 3
INSERT INTO picture (name, caption, location) VALUES('Grandmas Pumpkin Pie', 'Pumpkin Pie! - It has pumpkin in it.', 'pre_2.jpg'); -- 4
INSERT INTO picture (name, caption, location) VALUES('Raspberry Cheesecake Bars', 'Raspberry Cheesecake Bars; They are good for you!', 'pre_3.jpg'); -- 5
INSERT INTO picture (name, caption, location) VALUES('curtis', 'Curtis Sydnor', 'curtis_sydnor.jpg'); -- 6
INSERT INTO picture (name, caption, location) VALUES('mona', 'Mona Lisa', 'mona_lisa.jpg'); -- 7
INSERT INTO picture (name, caption, location) VALUES('james', 'James "Sawyer" Ford', 'james_ford.jpg'); -- 8
INSERT INTO picture (name, caption, location) VALUES('kate', 'Kate Middleton', 'kate_middleton.jpg'); -- 9
INSERT INTO picture (name, caption, location) VALUES('john', 'Johnny Depp', 'johnny_depp.jpg'); -- 10
INSERT INTO picture (name, caption, location) VALUES('felicia', 'Falicia Day', 'felicia_day.jpg'); -- 11
INSERT INTO picture (name, caption, location) VALUES('Grandmas Pumpkin Pie', 'Just out of the oven.', 'pre_2_2.jpg'); -- 12
INSERT INTO picture (name, caption, location) VALUES('Ginger', 'Gingers!', 'pre_ing1.jpg'); -- 13
INSERT INTO picture (name, caption, location) VALUES('Egg', 'Eggs', 'pre_ing2.jpg'); -- 14
INSERT INTO picture (name, caption, location) VALUES('Sugar', 'Sugar', 'pre_ing3.jpg'); -- 15
INSERT INTO picture (name, caption, location) VALUES('Evaporated Milk', 'Evaporated Milk', 'pre_ing4.jpg'); -- 16
INSERT INTO picture (name, caption, location) VALUES('Solid Packed Pumpkin', 'Solid Packed Pumpkin', 'pre_ing5.jpg'); -- 17
INSERT INTO picture (name, caption, location) VALUES('Unbaked Pie Shells', 'Unbaked Pie Shells', 'pre_ing6.jpg'); -- 18
INSERT INTO picture (name, caption, location) VALUES('Salt', 'Salt', 'pre_ing7.jpg'); -- 19
INSERT INTO picture (name, caption, location) VALUES('Cinnamon', 'Cinnamon', 'pre_ing8.jpg'); -- 20
INSERT INTO picture (name, caption, location) VALUES('Nutmeg', 'Nutmeg', 'pre_ing9.jpg'); -- 21
INSERT INTO picture (name, caption, location) VALUES('Simple White Cake', 'CAKE!', 'simple_white.jpg'); -- 22
INSERT INTO picture (name, caption, location) VALUES('Oven-Friend Pork Chops', 'pork chops', 'pork_chops.jpg'); -- 23
INSERT INTO picture (name, caption, location) VALUES('Ranch Burgers', 'ranch burgers', 'ranch_burgers.jpg'); -- 24
INSERT INTO picture (name, caption, location) VALUES('Pepper', 'pepper', 'pepper.jpg'); -- 25
INSERT INTO picture (name, caption, location) VALUES('Flour', 'flour', 'flour.jpg'); -- 26
INSERT INTO picture (name, caption, location) VALUES('Butter', 'butter','butter.jpg'); -- 27
INSERT INTO picture (name, caption, location) VALUES('Chicken', 'chicken','chicken.jpg'); -- 28

INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Sam', 2, 'admin', 'Sam', 'Luebbert', 'sgluebbert1@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Mike', 'admin', 'Mike', 'Little', 'malittle3@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Julia', 'admin', 'Julia', 'Collins', 'jlcollins4@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Curtis', 6, 'admin', 'Curtis', 'Sydnor', 'casydnor1@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Mona', 7, 'user', 'Mona', 'Lisa', 'mglisa@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('James', 8, 'user', 'James', 'Ford', 'jsford@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Catherine', 9, 'user', 'Catherine', 'Middleton', 'cemiddleton@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('John', 10, 'user', 'John', 'Depp', 'jcdepp@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Felicia', 11, 'user', 'Felicia', 'Day', 'fkday@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);

-- Read as user_id_1 follows user_id_2...
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Sam', 'Julia', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Sam', 'Curtis', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Sam', 'Felicia', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Sam', 'John', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, active) VALUES('Sam', 'James', 1);
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Sam', 'Catherine', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, active) VALUES('Sam', 'John', 0);
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Julia', 'Mike', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Julia', 'Curtis', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, active) VALUES('Julia', 'Catherine', 1);
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Mike', 'Curtis', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Mike', 'Felicia', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Curtis', 'Felicia', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active) VALUES('Curtis', 'John', 0, 0);
INSERT INTO user_connections (user_id_1, user_id_2, active) VALUES('Curtis', 'Mona', 1);

INSERT INTO unit (unit_name) VALUES(''); -- used for no unit ex: "4 eggs" 1
INSERT INTO unit (unit_name, abrev) VALUES('Teaspoon', 'tsp');  -- 2
INSERT INTO unit (unit_name, abrev) VALUES('Tablespoon', 'tbsp'); -- 3
INSERT INTO unit (unit_name, abrev) VALUES('Dessertspoon', 'dstspn');  -- 4
INSERT INTO unit (unit_name) VALUES('Cup'); -- 5
INSERT INTO unit (unit_name) VALUES('Drop');  -- 6
INSERT INTO unit (unit_name, abrev) VALUES('Pinch', 'pn');  -- 7
INSERT INTO unit (unit_name) VALUES('Dash');  -- 8
INSERT INTO unit (unit_name) VALUES('Smidgen');  -- 9
INSERT INTO unit (unit_name) VALUES('Handfull');  -- 10
INSERT INTO unit (unit_name, abrev) VALUES('Gill', 'gi');  -- 11
INSERT INTO unit (unit_name, abrev) VALUES('Ounce', 'oz');  -- 12
INSERT INTO unit (unit_name, abrev) VALUES('Fluid Ounces', 'fl oz');  -- 13
INSERT INTO unit (unit_name, abrev) VALUES('Pound', 'lb');  -- 14
INSERT INTO unit (unit_name, abrev) VALUES('Pint', 'pt');  -- 15
INSERT INTO unit (unit_name, abrev) VALUES('Quart', 'qt');  -- 16
INSERT INTO unit (unit_name, abrev) VALUES('Gallon', 'gal');  -- 17
INSERT INTO unit (unit_name) VALUES('Jigger');  -- 18
INSERT INTO unit (unit_name, abrev) VALUES('Peck', 'pk');  -- 19
INSERT INTO unit (unit_name, abrev) VALUES('Bushel', 'bu'); -- 20
INSERT INTO unit (unit_name) VALUES('Firkin');  -- 21
INSERT INTO unit (unit_name) VALUES('Hogshead');  -- 22
INSERT INTO unit (unit_name, abrev) VALUES('Mililiter', 'ml');  -- 23
INSERT INTO unit (unit_name, abrev) VALUES('Cubic Centimeter', 'cc');  -- 24
INSERT INTO unit (unit_name) VALUES('Cubic Foot');  -- 25
INSERT INTO unit (unit_name) VALUES('Cubic Inch');  -- 26
INSERT INTO unit (unit_name, abrev) VALUES('Liter', 'l');  --  27
INSERT INTO unit (unit_name) VALUES('Fifth');  -- 28
INSERT INTO unit (unit_name) VALUES('Shot');  -- 29
INSERT INTO unit (unit_name, abrev) VALUES('Gram', 'g');  -- 30
INSERT INTO unit (unit_name, abrev) VALUES('Kilogram', 'kg');  -- 31
INSERT INTO unit (unit_name, abrev) VALUES('Inch', 'in');  --  32
INSERT INTO unit (unit_name, abrev) VALUES('Truckload', 'tl');  -- 33
INSERT INTO unit (unit_name, abrev) VALUES('Partial Truckload', 'ltl');  -- 34
INSERT INTO unit (unit_name) VALUES('Crate');  -- 35
INSERT INTO unit (unit_name) VALUES('Bucket');  -- 36

INSERT INTO category (category_name) VALUES(''); -- 1
INSERT INTO category (category_name) VALUES('Side Dishes'); -- 2
INSERT INTO category (category_name) VALUES('Fall Desserts'); -- 3
INSERT INTO category (category_name) VALUES('Cake'); -- 4
INSERT INTO category (category_name) VALUES('Pie'); -- 5
INSERT INTO category (category_name) VALUES('Beef'); -- 6
INSERT INTO category (category_name) VALUES('Chicken'); -- 7
INSERT INTO category (category_name) VALUES('Pork'); -- 8
INSERT INTO category (category_name) VALUES('Breakfast'); -- 9
INSERT INTO category (category_name) VALUES('Desserts'); -- 10

INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES('Curtis', 2, 'Potato Salad', '4-6', STR_TO_DATE('00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), '1. Do this\n2. Do that\n3. Maybe your done?', STR_TO_DATE('9,29,2012 19:00', '%m,%d,%Y %H:%i'));  -- 1
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES('Sam', 3, 'Grandmas Pumpkin Pie', '5-6', STR_TO_DATE('00:10', '%H:%i'), STR_TO_DATE('02:00', '%H:%i'), 'directions', STR_TO_DATE('9,30,2012 11:00', '%m,%d,%Y %H:%i'));  -- 2
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES('Julia', 10, 'Raspberry Cheesecake Bars', '3-5', STR_TO_DATE('00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), 'directions', STR_TO_DATE('9,28,2012 19:00', '%m,%d,%Y %H:%i')); -- 3
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES ( 'Mike', 4, 'Simple White Cake', '6-10', STR_TO_DATE( '00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), 'directions', STR_TO_DATE('10,25,2012 19:00', '%m,%d,%Y %H:%i')); -- 4
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES ( 'Curtis', 8, 'Oven-fried Pork Chops', '4', STR_TO_DATE( '00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), 'directions', STR_TO_DATE('10,28,2012 19:00', '%m,%d,%Y %H:%i')); -- 5
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added, public) VALUES ( 'Sam', 6, 'Ranch Burgers', '8', STR_TO_DATE( '00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), 'directions', STR_TO_DATE('10,28,2012 19:05', '%m,%d,%Y %H:%i'), 0); -- 6

INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(1, 3);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(2, 4);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(2, 12);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(3, 5);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(4, 22);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(5, 23);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(6, 24);

INSERT INTO recipe_comment (owner_id, recipe_id, content, date_added) VALUES('Curtis', 2, "Hey, this recipe seems good!", STR_TO_DATE('10,1,2012 16:34:21', '%m,%d,%Y %H:%i:%s')); -- 1
INSERT INTO recipe_comment (owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('Sam', 2, 1, "Thanks! Try it out sometime soon.", STR_TO_DATE('10,1,2012 19:04:54', '%m,%d,%Y %H:%i:%s')); -- 2
INSERT INTO recipe_comment (owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('Julia', 2, 2, "I bet it is not that good.", STR_TO_DATE('10,1,2012 19:43:24', '%m,%d,%Y %H:%i:%s')); -- 3
INSERT INTO recipe_comment (owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('Mike', 2, 3, "Ha!", STR_TO_DATE('10,1,2012 19:44:05', '%m,%d,%Y %H:%i:%s')); -- 4
INSERT INTO recipe_comment (owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('Sam', 2, 3, "Oh thaaanks.", STR_TO_DATE('10,1,2012 20:45:35', '%m,%d,%Y %H:%i:%s')); -- 4
INSERT INTO recipe_comment (owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('Curtis', 2, 2, "Ok, I will", STR_TO_DATE('10,1,2012 19:47:45', '%m,%d,%Y %H:%i:%s')); -- 5

INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Sam', 1, 6, STR_TO_DATE('9,28,2012 13:49:04', '%m,%d,%Y %H:%i:%s')); -- 1
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Julia', 1, 3, STR_TO_DATE('9,28,2012 17:43:34', '%m,%d,%Y %H:%i:%s')); -- 2
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Mike', 2, 10, STR_TO_DATE('9,30,2012 11:42:14', '%m,%d,%Y %H:%i:%s')); -- 3
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Julia', 2, 5, STR_TO_DATE('9,30,2012 15:23:45', '%m,%d,%Y %H:%i:%s')); -- 4
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Sam', 4, 10, STR_TO_DATE('10,2,2012 19:34:02', '%m,%d,%Y %H:%i:%s')); -- 4
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Curtis', 5, 6, STR_TO_DATE('10,28,2012 05:13:02', '%m,%d,%Y %H:%i:%s')); -- 6
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Sam', 3, 8, STR_TO_DATE('10,28,2012 05:13:02', '%m,%d,%Y %H:%i:%s')); -- 6

INSERT INTO ingredient (ingr_name) VALUES('Potatoes'); --  1
INSERT INTO ingredient (ingr_name) VALUES('Italian Salad Dressing');  -- 2
INSERT INTO ingredient (ingr_name) VALUES('Mayonnaise');  -- 3
INSERT INTO ingredient (ingr_name) VALUES('Chopped Green Onions');  -- 4
INSERT INTO ingredient (ingr_name) VALUES('Chopped Fresh Dill');  -- 5
INSERT INTO ingredient (ingr_name) VALUES('Dijon Mustard');  -- 6
INSERT INTO ingredient (ingr_name) VALUES('Lemon Juice');  -- 7
INSERT INTO ingredient (ingr_name) VALUES('Pepper');  -- 8
INSERT INTO ingredient (ingr_name, picture_id) VALUES('Unbaked Pie Shells', 18);  -- 9
INSERT INTO ingredient (ingr_name, picture_id) VALUES('Sugar', 15);  -- 10
INSERT INTO ingredient (ingr_name, picture_id) VALUES('Salt', 19);  -- 11
INSERT INTO ingredient (ingr_name, picture_id) VALUES('Cinnamon', 20);  -- 12
INSERT INTO ingredient (ingr_name, picture_id) VALUES('Ginger', 13);  -- 13
INSERT INTO ingredient (ingr_name, picture_id) VALUES('Nutmeg', 21);  -- 14
INSERT INTO ingredient (ingr_name, picture_id) VALUES('Eggs', 14);  -- 15
INSERT INTO ingredient (ingr_name, picture_id) VALUES('Solid Pack Pumpkin', 17);  -- 16
INSERT INTO ingredient (ingr_name, picture_id) VALUES('Evaporated Milk', 16);  -- 17
INSERT INTO ingredient (ingr_name) VALUES('All Purpose Flour');  -- 18
INSERT INTO ingredient (ingr_name) VALUES('Brown Sugar');  -- 19
INSERT INTO ingredient (ingr_name) VALUES('Finely Chopped Sliced Almonds');  -- 20
INSERT INTO ingredient (ingr_name) VALUES('Butter Flavored Shortening');  -- 21
INSERT INTO ingredient (ingr_name) VALUES('Softened Cream Cheese');  -- 22
INSERT INTO ingredient (ingr_name) VALUES('Granulated Sugar');  -- 23
INSERT INTO ingredient (ingr_name) VALUES('Almond Extract');  -- 24
INSERT INTO ingredient (ingr_name) VALUES('Seedless Raspberry Preserves');  -- 25
INSERT INTO ingredient (ingr_name) VALUES('Flaked Coconut');  -- 26
INSERT INTO ingredient (ingr_name) VALUES('Sliced Almonds');  -- 27
INSERT INTO ingredient (ingr_name) VALUES('Butter'); -- 28
INSERT INTO ingredient (ingr_name) VALUES('Vanilla Extract'); -- 29
INSERT INTO ingredient (ingr_name) VALUES('Baking Powder'); -- 30
INSERT INTO ingredient (ingr_name) VALUES('Milk'); -- 31
INSERT INTO ingredient (ingr_name) VALUES('Pork Chops'); -- 32
INSERT INTO ingredient (ingr_name) VALUES('Seasoned dry stuffing'); -- 33
INSERT INTO ingredient (ingr_name) VALUES('Ground Beef'); -- 34
INSERT INTO ingredient (ingr_name) VALUES('1 ounce Package of Ranch Dressing Mix'); -- 35
INSERT INTO ingredient (ingr_name) VALUES('Crushed Saltine Crackers'); -- 36
INSERT INTO ingredient (ingr_name) VALUES('Chopped Onion'); -- 37



INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 1, 1, 3); -- Potato Salad, 3 pounds potatoes scrubbed and quartered
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 2, 5, .5); -- Potato Salad, Italian Style Dressing 3/4 cup
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 3, 5, .75); -- Potato Salad, 3/4 cup mayonnaise
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 4, 5, .25); -- Potato Salad, 1/4 chopped green onions
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 5, 2, 2); -- Potato Salad, 2 teaspoons chopped fresh dill
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 6, 2, 1); -- Potato Salad, 1 teaspoon digjon mustard (optional)
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 7, 2, 1); -- Potato Salad, 1 teaspoon lemon juice
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 8, 2, .125); -- Potato Salad, 1/8 teaspoon pepper
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 9, 1, 2); -- Grandmas Pumpkin Pie, 2 (9inch) unbaked pie shells
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 10, 5, 1.5); -- Grandmas Pumpkin Pie, 1 1/2 cups sugar
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 11, 2, 1); -- Grandmas Pumpkin Pie, 1 teaspoon salt
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 12, 2, 1); -- Grandmas Pumpkin Pie, 1 teaspoon cinnamon
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 13, 2, .5); -- Grandmas Pumpkin Pie, 1/2 teaspoon ginger
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 14, 2, .5); -- Grandmas Pumpkin Pie, 1/2 teaspoon nutmeg
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 15, 1, 4); -- Grandmas Pumpkin Pie, 4 eggs
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 16, 1, 3.5); -- Grandmas Pumpkin Pie, 3 1/2 solid pack pumpkin
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 17, 5, 1.5); -- Grandmas Pumpkin Pie, 1 1/2 cups evaporated milk
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 18, 5, 1.25); -- Respberry Cheesecake Bars, 1 1/4 cup all purpose flour
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 19, 5, .5); -- Respberry Cheesecake Bars, 1/2 cup packed brown sugar
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 20, 5, .5); -- Respberry Cheesecake Bars, 1/2 cup finly chopped sliced almonds
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 21, 5, 1.5); -- Respberry Cheesecake Bars, Butter Flavored Shortening
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 22, 12, 16); -- Respberry Cheesecake Bars, 2 8-ounce packagesCream Cheese, Softended
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 23, 5, 2/3); -- Respberry Cheesecake Bars, 2/3 cup Granulated Sugar
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 15, 1, 2); -- Respberry Cheesecake Bars, 2 eggs
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 24, 2, .75); -- Respberry Cheesecake Bars, 3/4 teaspoon almond extract
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 25, 5, 1); -- Respberry Cheesecake Bars, 1 cup seedless raspberry preserves or other  preserves or jam
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 26, 5, .5); -- Respberry Cheesecake Bars, 1/2 cup flaked coconut
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 27, 5, .5); -- Respberry Cheesecake Bars, 1/2 cup sliced almonds
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(4, 15, 5, 1); -- Simple White Cake, 1 Cup of White Sugar
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(4, 28, 5, .5); -- Simple White Cake, 1/2 Cup of butter
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(4, 15, 1, 2); -- Simple White Cake, 2 eggs
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(4, 29, 2, 2); -- Simple White Cake, 2 teaspoons vanilla extract
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(4, 18, 5, 1); -- Simple White Cake, 1 cup of flour
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(4, 30, 2, 1.75); -- Simple White Cake, 1 3/4 teaspoons of backing powder
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(4, 31, 5, .5); -- Simple White Cake, 1/2 cup of milk
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(5, 32, 1, 4); -- Oven-Fried Pork Chops 4 Pork Chops, trimmed
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(5, 28, 2, 2); -- Oven-Fried Pork Chops, 12 Tablespoons butter, melted
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(5, 15, 1, 1); -- Oven-Fried Pork Chops, 1 egg
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(5, 31, 2, 2); -- Oven-Fried Pork Chops, 2 Tablespoons of milk
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(5, 33, 5, 1); -- Oven-Fried Pork Chops, 1 Cup Herb Seasoned Dry Stuffing
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(5, 8, 3, .25); -- Oven-Fried Pork Chops, 1/4 Teaspoon of Black Pepper
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(6, 34, 14, 2); -- Ranch Burgers, 2lbs Lean Ground Beef
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(6, 33, 12, 1); -- Ranch Burgers, 1 (1 ounce) package ranch dressing mix
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(6, 15, 1, 1); -- Ranch Burgers, 1 eggs lightly beaten
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(6, 36, 5, .75); -- Ranch Burgers, 3/4 cup crushed saltine crackers
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(6, 37, 1, 1); -- Ranch Burgers, 1 Onion chopped


-- Wiki data
INSERT INTO video (name, caption, address) VALUES("Test Video", "Test Caption", "http://www.youtube.com/embed/ghb6eDopW8I"); -- test video 1
INSERT INTO video (name, caption, address) VALUES("Test Video", "Test Caption", "http://www.youtube.com/embed/ghb6eDopW8I"); -- 2

-- Wiki categories
INSERT INTO wiki_category (category_name) VALUES ("Ingredients"); -- 1
INSERT INTO wiki_category (category_name) VALUES ("Poultry"); -- 2
-- Wiki pages
INSERT INTO wiki (video_id, wiki_title, wiki_cat_id) VALUES(1, "Salt",1);  -- 1
INSERT INTO wiki (video_id, wiki_title, wiki_cat_id) VALUES(1, "Sugar", 1); -- 2
INSERT INTO wiki (video_id, wiki_title, wiki_cat_id) VALUES(1, "Pepper", 1); -- 3
INSERT INTO wiki (video_id, wiki_title, wiki_cat_id) VALUES(1, "Butter", 1); -- 4
INSERT INTO wiki (video_id, wiki_title, wiki_cat_id) VALUES(1, "Flour", 1); -- 5
INSERT INTO wiki (video_id, wiki_title, wiki_cat_id) VALUES(1, "Chicken", 1);  -- 6

-- Wiki content
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES(1,19, "Salt", "Salt, also known as rock salt, is a crystalline mineral that is composed primarily of sodium chloride (NaCl), a chemical compound belonging to the larger class of ionic salts."); -- 1 
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES(2,15, "Sugar", "Sugar is the generalised name for a class of sweet flavored substances used as food. They are carbohydrates and as this name implies, are composed of carbon, hydrogen and oxygen."); -- 2
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES(3,25, "Pepper", "<a href='?w_id=1'>Black pepper</a> (Piper nigrum) is a flowering vine in the family Piperaceae, cultivated for its fruit, which is usually dried and used as a spice and seasoning. The fruit, known as a peppercorn when dried, is approximately 5 millimetres (0.20 in) in diameter, dark red when fully mature, and, like all drupes, contains a single seed"); -- 3
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES(4,27, "Butter", "Butter is a dairy product made by churning fresh or fermented cream or milk. It is generally used as a spread and a condiment, as well as in cooking, such as baking, sauce making, and pan frying. Butter consists of butterfat, milk proteins and water."); -- 4
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES(5,26, "Flour", "Flour is a powder which is made by grinding cereal grains, other seeds or roots (like Cassava). It is the main ingredient of bread, which is a staple food for many cultures, making the availability of adequate supplies of flour a major economic and political issue at various times throughout history. Wheat flour is one of the most important foods in European, North American, Middle Eastern, Indian and North African cultures, and is the defining ingredient in most of their styles of breads and pastries. Maize flour has been important in Mesoamerican cuisine since ancient times, and remains a staple in much of Latin American cuisine.[citation needed] Rye flour is an important constituent of bread in much of central/northern Europe."); -- 5
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES(6,28, "Chicken", "The chicken (Gallus gallus domesticus is a domesticated fowl, a subspecies of the Red Junglefowl. As one of the most common and widespread domestic animals, and with a population of more than 24 billion in 2003,[1] there are more chickens in the world than any other species of bird. Humans keep chickens primarily as a source of food, consuming both their meat and their eggs. The chicken's cultural and culinary dominance could be considered amazing to some in view of its believed domestic origin and purpose and it has inspired contributions to culture, art, cuisine, science and religion [2] from antiquity to the present."); -- 5
