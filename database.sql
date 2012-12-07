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
DROP TRIGGER IF EXISTS tri_wiki_category_counter1;
DROP TRIGGER IF EXISTS tri_wiki_category_counter2;
DROP TRIGGER IF EXISTS tri_unit_ingr_counter1;
DROP TRIGGER IF EXISTS tri_unit_ingr_counter2;
DROP TRIGGER IF EXISTS tri_user_rank_counter1;
DROP TRIGGER IF EXISTS tri_user_rank_counter2;
DROP TRIGGER IF EXISTS tri_user_rank_counter3;
DROP TRIGGER IF EXISTS tri_user_rank_counter4;
DROP TRIGGER IF EXISTS tri_user_rank_counter5;
DROP TRIGGER IF EXISTS tri_user_rank_counter6;
DROP TRIGGER IF EXISTS tri_ingr_wiki1;
DROP TRIGGER IF EXISTS tri_ingr_wiki2;

DROP TABLE IF EXISTS recipe_ingredient;
DROP TABLE IF EXISTS ingredient;
DROP TABLE IF EXISTS unit;
DROP TABLE IF EXISTS recipe_shared;
DROP TABLE IF EXISTS recipe_comment;
DROP TABLE IF EXISTS recipe_ranking;
DROP TABLE IF EXISTS recipe_picture;
DROP TABLE IF EXISTS recipe;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS user_connections;
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS wiki;
DROP TABLE IF EXISTS wiki_content;
DROP TABLE IF EXISTS wiki_category;
DROP TABLE IF EXISTS picture;
DROP TABLE IF EXISTS passkeys;
DROP TABLE IF EXISTS video;

CREATE TABLE passkeys
(
user_id VARCHAR(40) BINARY NOT NULL,
pass VARCHAR(40) NOT NULL,
salt VARCHAR(40) NOT NULL,
CONSTRAINT pk_passkeys PRIMARY KEY(user_id)
);

CREATE TABLE picture
(
picture_id SERIAL NOT NULL AUTO_INCREMENT,
caption VARCHAR(50),
location VARCHAR(100),
CONSTRAINT pk_picture PRIMARY KEY(picture_id)
);

CREATE TABLE video
(
video_id SERIAL NOT NULL AUTO_INCREMENT,
caption VARCHAR(50),
address VARCHAR(100),
CONSTRAINT pk_video PRIMARY KEY(video_id)
);

CREATE TABLE wiki_category
(
wiki_cat_id SERIAL,
category_name VARCHAR(40) NOT NULL,
use_count INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_wiki_cat PRIMARY KEY(wiki_cat_id)
);

CREATE TABLE wiki
(
wiki_id SERIAL,
wiki_cat_id BIGINT UNSIGNED,
wiki_title VARCHAR(40) NOT NULL,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
description TEXT NOT NULL,
ingr_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
FULLTEXT(wiki_title),
CONSTRAINT pk_wiki PRIMARY KEY(wiki_id),
CONSTRAINT fk_wiki_category FOREIGN KEY(wiki_cat_id) REFERENCES wiki_category(wiki_cat_id),
CONSTRAINT fk_wiki_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
) ENGINE=MyISAM;

CREATE TABLE wiki_content
(
wiki_cont_id SERIAL,
wiki_id BIGINT UNSIGNED NOT NULL,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
video_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
title VARCHAR(40),
content TEXT NOT NULL,
FULLTEXT(title, content),
CONSTRAINT pk_wiki_cont PRIMARY KEY(wiki_cont_id),
CONSTRAINT fk_wiki FOREIGN KEY(wiki_id) REFERENCES wiki(wiki_id),
CONSTRAINT fk_wiki_video FOREIGN KEY(video_id) REFERENCES video(video_id),
CONSTRAINT fk_cont_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
) ENGINE=MyISAM;

CREATE TABLE user
(
user_id VARCHAR(40) BINARY NOT NULL UNIQUE,
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
user_id_1 VARCHAR(40) BINARY NOT NULL,
user_id_2 VARCHAR(40) BINARY NOT NULL,
accepted TINYINT(1) NOT NULL DEFAULT 0,
active TINYINT(1) NOT NULL DEFAULT 1,
seen TINYINT(1) NOT NULL DEFAULT 0,
date_added DATETIME NOT NULL,
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
owner_id VARCHAR(40) BINARY NOT NULL,
category_id SMALLINT UNSIGNED NOT NULL,
recipe_name VARCHAR(60) NOT NULL,
public TINYINT(1) NOT NULL DEFAULT 1,
serving_size VARCHAR(10) DEFAULT '0-0',
prep_time TIME DEFAULT 0,
ready_time TIME DEFAULT 0,
directions TEXT NOT NULL,
date_added DATETIME NOT NULL,
date_edited DATETIME,
active TINYINT(1) NOT NULL DEFAULT 1,
description TEXT NOT NULL,
FULLTEXT(recipe_name),
CONSTRAINT pk_recipe PRIMARY KEY(recipe_id),
CONSTRAINT fk_recipe_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_category FOREIGN KEY(category_id) REFERENCES category(category_id)
) ENGINE=MyISAM;

CREATE TABLE recipe_picture
(
recipe_picture_id SERIAL,
recipe_id BIGINT UNSIGNED NOT NULL,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
CONSTRAINT pk_recipe_picture PRIMARY KEY(recipe_picture_id),
CONSTRAINT fk_recipe_picture_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id),
CONSTRAINT fk_recipe_picture_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
) ENGINE=MyISAM;

CREATE TABLE recipe_comment
(
comment_id SERIAL,
owner_id VARCHAR(40) BINARY NOT NULL,
recipe_id BIGINT UNSIGNED NOT NULL,
reply_comment_id BIGINT UNSIGNED DEFAULT 0,
content VARCHAR(500) NOT NULL,
date_added DATETIME NOT NULL,
date_edited DATETIME,
seen TINYINT(1) NOT NULL DEFAULT 0,
CONSTRAINT pk_comment PRIMARY KEY(comment_id),
CONSTRAINT fk_recipe_comment_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_comment_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id)
) ENGINE=MyISAM;

CREATE TABLE recipe_ranking
(
rank_id SERIAL,
owner_id VARCHAR(40) BINARY NOT NULL,
recipe_id BIGINT UNSIGNED NOT NULL,
rank TINYINT UNSIGNED DEFAULT 0,
date_added DATETIME NOT NULL,
date_edited DATETIME,
CONSTRAINT pk_recipe_ranking PRIMARY KEY(rank_id),
CONSTRAINT fk_recipe_ranking_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_ranking_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id)
) ENGINE=MyISAM;

CREATE TABLE recipe_shared
(
shared_id SERIAL,
owner_id VARCHAR(40) BINARY NOT NULL,
follower_id VARCHAR(40) BINARY NOT NULL,
recipe_id BIGINT UNSIGNED NOT NULL,
seen TINYINT(1) NOT NULL DEFAULT 0,
date_added DATETIME NOT NULL,
CONSTRAINT pk_recipe_shared PRIMARY KEY(shared_id),
CONSTRAINT fk_recipe_shared_owner FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_shared_follower FOREIGN KEY(follower_id) REFERENCES user(user_id)
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
ingr_name VARCHAR(60) BINARY NOT NULL,
use_count INT UNSIGNED NOT NULL DEFAULT 0,
wiki_id BIGINT UNSIGNED,
CONSTRAINT pk_ingredient PRIMARY KEY(ingr_id)
-- CONSTRAINT fk_ingredient_wiki FOREIGN KEY(wiki_id) REFERENCES wiki(wiki_id),
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
) ENGINE=MyISAM;

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

CREATE TRIGGER tri_wiki_category_counter1 AFTER INSERT ON wiki
	FOR EACH ROW BEGIN
		UPDATE wiki_category SET use_count = use_count + 1 WHERE wiki_cat_id = NEW.wiki_cat_id;
	END;
|

CREATE TRIGGER tri_wiki_category_counter2 AFTER DELETE ON wiki
	FOR EACH ROW BEGIN
		UPDATE wiki_category SET use_count = use_count - 1 WHERE wiki_cat_id = OLD.wiki_cat_id;
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
|

CREATE TRIGGER tri_user_rank_counter2 AFTER UPDATE ON recipe_ranking
	FOR EACH ROW BEGIN
		UPDATE user SET user_points = user_points + (NEW.rank * 3) - (OLD.rank * 3) WHERE user_id = (SELECT r.owner_id FROM recipe r JOIN recipe_ranking rr ON r.recipe_id = rr.recipe_id WHERE r.recipe_id = NEW.recipe_id LIMIT 1);
	END;
|

CREATE TRIGGER tri_user_rank_counter3 AFTER DELETE ON recipe_ranking
	FOR EACH ROW BEGIN
		UPDATE user SET user_points = user_points - (OLD.rank * 3) WHERE user_id = (SELECT r.owner_id FROM recipe r JOIN recipe_ranking rr ON r.recipe_id = rr.recipe_id WHERE r.recipe_id = OLD.recipe_id LIMIT 1);
	END;
|

CREATE TRIGGER tri_user_rank_counter4 AFTER INSERT ON user_connections
	FOR EACH ROW BEGIN
		IF NEW.accepted = 1 
			THEN UPDATE user SET user_points = user_points + 1 WHERE user_id = NEW.user_id_2;
		END IF;
	END;
|

CREATE TRIGGER tri_user_rank_counter5 AFTER UPDATE ON user_connections
	FOR EACH ROW BEGIN
		IF NEW.active = 0 AND OLD.accepted = 1 THEN 
			UPDATE user SET user_points = user_points - 1 WHERE user_id = NEW.user_id_2;
		END IF;
		IF NEW.active = 1 AND NEW.accepted = 1 THEN 
			UPDATE user SET user_points = user_points + 1 WHERE user_id = NEW.user_id_2;
		END IF;
	END;
|

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

CREATE TRIGGER tri_ingr_wiki1 BEFORE INSERT ON ingredient
	FOR EACH ROW BEGIN
		SET @temp = (SELECT wiki_id FROM wiki WHERE ingr_id = 0 AND wiki_title = NEW.ingr_name LIMIT 1);
		IF (SELECT COUNT(wiki_id) FROM wiki WHERE ingr_id = 0 AND wiki_title = NEW.ingr_name LIMIT 1) = 0 THEN
			INSERT INTO wiki (wiki_title, wiki_cat_id, description) VALUES(NEW.ingr_name, 1, '');
			SET NEW.wiki_id = LAST_INSERT_ID();
		ELSE
			SET NEW.wiki_id = @temp;
		END IF;
	END;
|

CREATE TRIGGER tri_ingr_wiki2 AFTER INSERT ON ingredient
	FOR EACH ROW BEGIN
		UPDATE wiki SET ingr_id = NEW.ingr_id WHERE wiki_id = NEW.wiki_id;
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
INSERT INTO passkeys (user_id, pass, salt) VALUES('Mario', 'ed9afd51c1609d0c4f42dbd3132def270ca9d36f', 'eb99762e96c220d67e6683c25fcd3666ea67041b');


INSERT INTO picture (caption, location) VALUES('No Picture', 'unknown.png'); -- 1
INSERT INTO picture (caption, location) VALUES('Sam Luebbert', 'sam1.png'); -- 2
INSERT INTO picture (caption, location) VALUES('Potato Salad Yum!', 'pre_1.jpg'); -- 3
INSERT INTO picture (caption, location) VALUES('Pumpkin Pie! - It has pumpkin in it.', 'pre_2.jpg'); -- 4
INSERT INTO picture (caption, location) VALUES('Raspberry Cheesecake Bars; They are good for you!', 'pre_3.jpg'); -- 5
INSERT INTO picture (caption, location) VALUES('Curtis Sydnor', 'curtis_sydnor.jpg'); -- 6
INSERT INTO picture (caption, location) VALUES('Mona Lisa', 'mona_lisa.jpg'); -- 7
INSERT INTO picture (caption, location) VALUES('James "Sawyer" Ford', 'james_ford.jpg'); -- 8
INSERT INTO picture (caption, location) VALUES('Kate Middleton', 'kate_middleton.jpg'); -- 9
INSERT INTO picture (caption, location) VALUES('Johnny Depp', 'johnny_depp.jpg'); -- 10
INSERT INTO picture (caption, location) VALUES('Falicia Day', 'felicia_day.jpg'); -- 11
INSERT INTO picture (caption, location) VALUES('Just out of the oven.', 'pre_2_2.jpg'); -- 12
INSERT INTO picture (caption, location) VALUES('Gingers!', 'pre_ing1.jpg'); -- 13
INSERT INTO picture (caption, location) VALUES('Eggs', 'pre_ing2.jpg'); -- 14
INSERT INTO picture (caption, location) VALUES('Sugar', 'pre_ing3.jpg'); -- 15
INSERT INTO picture (caption, location) VALUES('Evaporated Milk', 'pre_ing4.jpg'); -- 16
INSERT INTO picture (caption, location) VALUES('Solid Packed Pumpkin', 'pre_ing5.jpg'); -- 17
INSERT INTO picture (caption, location) VALUES('Unbaked Pie Shells', 'pre_ing6.jpg'); -- 18
INSERT INTO picture (caption, location) VALUES('Salt', 'pre_ing7.jpg'); -- 19
INSERT INTO picture (caption, location) VALUES('Cinnamon', 'pre_ing8.jpg'); -- 20
INSERT INTO picture (caption, location) VALUES('Nutmeg', 'pre_ing9.jpg'); -- 21
INSERT INTO picture (caption, location) VALUES('CAKE!', 'simple_white.jpg'); -- 22
INSERT INTO picture (caption, location) VALUES('pork chops', 'pork_chops.jpg'); -- 23
INSERT INTO picture (caption, location) VALUES('ranch burgers', 'ranch_burgers.jpg'); -- 24
INSERT INTO picture (caption, location) VALUES('pepper', 'pepper.jpg'); -- 25
INSERT INTO picture (caption, location) VALUES('flour', 'flour.jpg'); -- 26
INSERT INTO picture (caption, location) VALUES('butter','butter.jpg'); -- 27
INSERT INTO picture (caption, location) VALUES('chicken','chicken.jpg'); -- 28
INSERT INTO picture (caption, location) VALUES('Julia','julia.jpg'); -- 29
INSERT INTO picture (caption, location) VALUES('Mike','mike.jpg'); -- 30
INSERT INTO picture (caption, location) VALUES('Ground Beef','ground_beef.jpg'); -- 31
INSERT INTO picture (caption, location) VALUES('All Purpose Flour','flour.jpg'); -- 32
INSERT INTO picture (caption, location) VALUES('Brown Sugar','brown_sugar.jpg'); -- 33
INSERT INTO picture (caption, location) VALUES('Lemon Juice','lemon_juice.jpg'); -- 34
INSERT INTO picture (caption, location) VALUES('Butter','butter.jpg'); -- 35
INSERT INTO picture (caption, location) VALUES('Milk','milk.jpg'); -- 36
INSERT INTO picture (caption, location) VALUES('Vanilla Extract','van_ext.jpg'); -- 37
INSERT INTO picture (caption, location) VALUES('Mario','mario.jpg'); -- 38
INSERT INTO picture (caption, location) VALUES('Mushroom Soup','soup1.jpg'); -- 39
INSERT INTO picture (caption, location) VALUES('Super Mushroom','mushroom1.jpg'); -- 40
INSERT INTO picture (caption, location) VALUES('Potatoes','potatoes.jpg'); -- 41
INSERT INTO picture (caption, location) VALUES('Water','water.jpg'); -- 42
INSERT INTO picture (caption, location) VALUES('Grill','grill.jpg'); -- 43

INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Sam', 2, 'admin', 'Sam', 'Luebbert', 'sgluebbert1@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Mike', 30, 'admin', 'Mike', 'Little', 'malittle3@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Julia', 29, 'admin', 'Julia', 'Collins', 'jlcollins4@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Curtis', 6, 'admin', 'Curtis', 'Sydnor', 'casydnor1@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Mona', 7, 'user', 'Mona', 'Lisa', 'mglisa@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('James', 8, 'user', 'James', 'Ford', 'jsford@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Catherine', 9, 'user', 'Catherine', 'Middleton', 'cemiddleton@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('John', 10, 'user', 'John', 'Depp', 'jcdepp@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active) VALUES('Felicia', 11, 'user', 'Felicia', 'Day', 'fkday@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1);
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added, active, show_email) VALUES('Mario', 38, 'user', 'Mario', '', 'mario@mushroomkingdom.com', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'), 1, 1);

-- Read as user_id_1 follows user_id_2...
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Sam', 'Julia', 1, 1, STR_TO_DATE('9,19,2012 6:05', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Sam', 'Curtis', 1, 1, STR_TO_DATE('9,23,2012 13:30', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Sam', 'Mario', 1, 1, STR_TO_DATE('9,30,2012 11:02', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Sam', 'John', 1, 1, STR_TO_DATE('9,12,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, active, date_added) VALUES('Sam', 'James', 1, STR_TO_DATE('10,25,2012 19:20', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Sam', 'Catherine', 1, 1, STR_TO_DATE('10,16,2012 13:30', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Julia', 'Mike', 1, 1, STR_TO_DATE('10,15,2012 10:07', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Julia', 'Curtis', 1, 1, STR_TO_DATE('10,04,2012 17:45', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, active, date_added) VALUES('Julia', 'Catherine', 1, STR_TO_DATE('10,13,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Mike', 'Curtis', 1, 1, STR_TO_DATE('10,28,2012 05:30', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Mike', 'Felicia', 1, 1, STR_TO_DATE('10,29,2012 10:03', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Curtis', 'Felicia', 1, 1, STR_TO_DATE('11,02,2012 13:50', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, accepted, active, date_added) VALUES('Curtis', 'John', 0, 1, STR_TO_DATE('11,04,2012 18:53', '%m,%d,%Y %H:%i'));
INSERT INTO user_connections (user_id_1, user_id_2, active, date_added) VALUES('Curtis', 'Mona', 1, STR_TO_DATE('11,07,2012 12:03', '%m,%d,%Y %H:%i'));

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
INSERT INTO category (category_name) VALUES('Beef'); -- 2
INSERT INTO category (category_name) VALUES('Chicken'); -- 3
INSERT INTO category (category_name) VALUES('Lamb'); -- 4
INSERT INTO category (category_name) VALUES('Pork'); -- 5
INSERT INTO category (category_name) VALUES('Turkey'); -- 6
INSERT INTO category (category_name) VALUES('Sausage'); -- 7
INSERT INTO category (category_name) VALUES('Seafood'); -- 8
INSERT INTO category (category_name) VALUES('Breakfast'); -- 9
INSERT INTO category (category_name) VALUES('Brunch'); -- 10
INSERT INTO category (category_name) VALUES('Side Dish'); -- 11
INSERT INTO category (category_name) VALUES('Salad'); -- 12
INSERT INTO category (category_name) VALUES('Soup'); -- 13
INSERT INTO category (category_name) VALUES('Appetizers and Snacks'); -- 14
INSERT INTO category (category_name) VALUES('Desserts'); -- 15
INSERT INTO category (category_name) VALUES('Drinks'); -- 16
INSERT INTO category (category_name) VALUES('Holiday'); -- 17
INSERT INTO category (category_name) VALUES('Other'); -- 18
INSERT INTO category (category_name) VALUES('Ham'); -- 19
INSERT INTO category (category_name) VALUES('Bread'); -- 20
INSERT INTO category (category_name) VALUES('Vegetables'); -- 21

INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES('Curtis', 11, 'Potato Salad', '4-6', STR_TO_DATE('00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), '1. Do this\n2. Do that\n3. Maybe your done?', STR_TO_DATE('9,29,2012 19:00', '%m,%d,%Y %H:%i'));  -- 1
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES('Sam', 15, 'Grandmas Pumpkin Pie', '5-6', STR_TO_DATE('00:10', '%H:%i'), STR_TO_DATE('02:00', '%H:%i'), 'directions', STR_TO_DATE('9,30,2012 11:00', '%m,%d,%Y %H:%i'));  -- 2
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES('Julia', 15, 'Raspberry Cheesecake Bars', '3-5', STR_TO_DATE('00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), 'directions', STR_TO_DATE('9,28,2012 19:00', '%m,%d,%Y %H:%i')); -- 3
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added, description) VALUES ( 'Mike', 15, 'Simple White Cake', '6-10', STR_TO_DATE( '00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), 'directions', STR_TO_DATE('10,25,2012 19:00', '%m,%d,%Y %H:%i'), 'Cake that taste great and its simple to make.'); -- 4
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES ( 'Curtis', 5, 'Oven-fried Pork Chops', '4', STR_TO_DATE( '00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), 'directions', STR_TO_DATE('10,28,2012 19:00', '%m,%d,%Y %H:%i')); -- 5
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added, public) VALUES ( 'Sam', 2, 'Ranch Burgers', '8', STR_TO_DATE( '00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), 'directions', STR_TO_DATE('10,28,2012 19:05', '%m,%d,%Y %H:%i'), 0); -- 6
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES ( 'Mario', 13, 'Mushroom Soup', '3-4', STR_TO_DATE( '00:20', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), '1. Chop the mushroom and put it into a pot with the water and set it to boil.\n2. Chop potatoes into the pot as well with anything else you usually put in a soup.', STR_TO_DATE('11,02,2012 12:35', '%m,%d,%Y %H:%i')); -- 6

INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(1, 3);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(2, 4);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(2, 12);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(3, 5);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(4, 22);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(5, 23);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(6, 24);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(7, 39);

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
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Sam', 7, 10, STR_TO_DATE('11,2,2012 15:13:02', '%m,%d,%Y %H:%i:%s')); -- 7

-- Wiki categories
INSERT INTO wiki_category (category_name) VALUES ("Ingredients"); -- 1
INSERT INTO wiki_category (category_name) VALUES ("Other"); -- 2
INSERT INTO wiki_category (category_name) VALUES ("Cooking Techniques"); -- 3
INSERT INTO wiki_category (category_name) VALUES ("Poultry"); -- 4

INSERT INTO ingredient (ingr_name) VALUES('Potatoes'); --  1
INSERT INTO ingredient (ingr_name) VALUES('Italian Salad Dressing');  -- 2
INSERT INTO ingredient (ingr_name) VALUES('Mayonnaise');  -- 3
INSERT INTO ingredient (ingr_name) VALUES('Chopped Green Onions');  -- 4
INSERT INTO ingredient (ingr_name) VALUES('Chopped Fresh Dill');  -- 5
INSERT INTO ingredient (ingr_name) VALUES('Dijon Mustard');  -- 6
INSERT INTO ingredient (ingr_name) VALUES('Lemon Juice');  -- 7
INSERT INTO ingredient (ingr_name) VALUES('Pepper');  -- 8
INSERT INTO ingredient (ingr_name) VALUES('Unbaked Pie Shells');  -- 9
INSERT INTO ingredient (ingr_name) VALUES('White Sugar');  -- 10
INSERT INTO ingredient (ingr_name) VALUES('Salt');  -- 11
INSERT INTO ingredient (ingr_name) VALUES('Cinnamon');  -- 12
INSERT INTO ingredient (ingr_name) VALUES('Ginger');  -- 13
INSERT INTO ingredient (ingr_name) VALUES('Nutmeg');  -- 14
INSERT INTO ingredient (ingr_name) VALUES('Eggs');  -- 15
INSERT INTO ingredient (ingr_name) VALUES('Solid Pack Pumpkin');  -- 16
INSERT INTO ingredient (ingr_name) VALUES('Evaporated Milk');  -- 17
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
INSERT INTO ingredient (ingr_name) VALUES('Super Mushroom'); -- 38
INSERT INTO ingredient (ingr_name) VALUES('Water'); -- 39
INSERT INTO ingredient (ingr_name) VALUES('Chicken'); -- 40
INSERT INTO ingredient (ingr_name) VALUES('Sugar'); -- 41
INSERT INTO ingredient (ingr_name) VALUES('Flour'); -- 42

UPDATE wiki SET picture_id = 41 WHERE ingr_id = 1;
UPDATE wiki SET picture_id = 34 WHERE ingr_id = 7;
UPDATE wiki SET picture_id = 18 WHERE ingr_id = 9;
UPDATE wiki SET picture_id = 15 WHERE ingr_id = 10;
UPDATE wiki SET picture_id = 19 WHERE ingr_id = 11;
UPDATE wiki SET picture_id = 20 WHERE ingr_id = 12;
UPDATE wiki SET picture_id = 13 WHERE ingr_id = 13;
UPDATE wiki SET picture_id = 21 WHERE ingr_id = 14;
UPDATE wiki SET picture_id = 14 WHERE ingr_id = 15;
UPDATE wiki SET picture_id = 17 WHERE ingr_id = 16;
UPDATE wiki SET picture_id = 16 WHERE ingr_id = 17;
UPDATE wiki SET picture_id = 32 WHERE ingr_id = 18;
UPDATE wiki SET picture_id = 33 WHERE ingr_id = 19;
UPDATE wiki SET picture_id = 35 WHERE ingr_id = 28;
UPDATE wiki SET picture_id = 37 WHERE ingr_id = 29;
UPDATE wiki SET picture_id = 36 WHERE ingr_id = 31;
UPDATE wiki SET picture_id = 31 WHERE ingr_id = 34;
UPDATE wiki SET picture_id = 40 WHERE ingr_id = 38;
UPDATE wiki SET picture_id = 42 WHERE ingr_id = 39;
UPDATE wiki SET picture_id = 28 WHERE ingr_id = 40;
UPDATE wiki SET picture_id = 13 WHERE ingr_id = 41;
UPDATE wiki SET picture_id = 26 WHERE ingr_id = 42;

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
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(7, 38, 1, 1); -- Mushroom Soup
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(7, 39, 5, 3); -- Mushroom Soup
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(7, 1, 1, 2); -- Mushroom Soup


-- Wiki data
INSERT INTO video (caption, address) VALUES("Test Caption", "http://www.youtube.com/embed/ghb6eDopW8I"); -- test video 1
INSERT INTO video (caption, address) VALUES("How To Grill", "http://www.youtube.com/embed/h82C-FCq2dI"); -- Grilling 2


-- Wiki pages ::::: We can't count these like in previous inserts, because ingredients make wikis, you don't know what ID you are up to.
INSERT INTO wiki (wiki_title, wiki_cat_id, description) VALUES("Grilling", 3, 'All about the art of grilling.');

-- Wiki content
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES((SELECT wiki_id FROM wiki WHERE wiki_title = "Salt" LIMIT 1), 19, "Salt", "Salt, also known as rock salt, is a crystalline mineral that is composed primarily of sodium chloride (NaCl), a chemical compound belonging to the larger class of ionic salts. It is absolutely essential for animal life, but can be harmful to animals and plants in excess.\n\nSalt is one of the oldest, most ubiquitous food seasonings and salting is an important method of food preservation. The taste of salt (saltiness) is one of the basic human tastes. Salt for human consumption is produced in different forms: unrefined salt (such as sea salt), refined salt (table salt), and iodized salt. It is a crystalline solid, white, pale pink or light gray in color, normally obtained from sea water or rock deposits. Edible rock salts may be slightly grayish in color because of mineral content.\n\nChloride and sodium ions, the two major components of salt, are needed by all known living creatures in small quantities. Salt is involved in regulating the water content (fluid balance) of the body. The sodium ion itself is used for electrical signaling in the nervous system.[1] Because of its importance to survival, salt has often been considered a valuable commodity during human history.\n\nHowever, as salt consumption has increased during modern times, scientists have become aware of the health risks associated with high salt intake, including high blood pressure in sensitive individuals. Therefore, some health authorities have recommended limitations of dietary sodium, although others state the risk is minimal for typical western diets.[2][3][4][5][6] The United States Department of Health and Human Services recommends that individuals consume no more than 1500–2300 mg of sodium (3750–5750 mg of salt) per day depending on age.[7]"); -- 1 
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES((SELECT wiki_id FROM wiki WHERE wiki_title = "Sugar" LIMIT 1), 15, "Sugar", "Sugar is the generalised name for a class of sweet flavored substances used as food. They are carbohydrates and as this name implies, are composed of carbon, hydrogen and oxygen.Sugars are found in the tissues of most plants but are only present in sufficient concentrations for efficient extraction in sugarcane and sugar beet. Sugarcane is a giant grass and has been cultivated in tropical climates in the Far East since ancient times.\n A great expansion in its production took place in the 18th century with the setting up of sugar plantations in the West Indies and Americas. This was the first time that sugar became available to the common people who had previously had to rely on honey to sweeten foods.\n Sugar beet is a root crop and is cultivated in cooler climates and became a major source of sugar in the 19th century when methods for extracting the sugar became available. Sugar production and trade has changed the course of human history in many ways. It influenced the formation of colonies, the perpetuation of slavery, the transition to indentured labour, the migration of peoples, wars between 19th century sugar trade controlling nations and the ethnic composition and political structure of the new world.\nThe world produced about 168 million tonnes of sugar in 2011. The average person consumes about 24 kilograms of sugar each year (33.1 kg in industrialised countries), equivalent to over 260 food calories per person, per day. Sugar provides empty calories. Since the latter part of the twentieth century, it has been questioned whether a diet high in sugars, especially refined sugars, is bad for health.\n Sugar has been linked to obesity and suspected of being implicated in diabetes, cardiovascular disease, dementia, macular degeneration and tooth decay. Numerous studies have been undertaken to try to clarify the position but the results remain largely unclear, mainly because of the difficulty of finding populations for use as controls that do not consume sugars."); -- 2
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES((SELECT wiki_id FROM wiki WHERE wiki_title = "Pepper" LIMIT 1), 25, "Pepper", "<a href='?w_id=1'>Black pepper</a> (Piper nigrum) is a flowering vine in the family Piperaceae, cultivated for its fruit, which is usually dried and used as a spice and seasoning. The fruit, known as a peppercorn when dried, is approximately 5 millimetres (0.20 in) in diameter, dark red when fully mature, and, like all drupes, contains a single seed.\n Peppercorns, and the powdered pepper derived from grinding them, may be described simply as pepper, or more precisely as black pepper (cooked and dried unripe fruit), green pepper (dried unripe fruit) and white pepper (dried ripe seeds). Black pepper is native to south India, and is extensively cultivated there and elsewhere in tropical regions. Currently Vietnam is the world's largest producer and exporter of pepper, producing 34% of the world's Piper nigrum crop as of 2008.\nDried ground pepper has been used since antiquity for both its flavour and as a medicine. Black pepper is the world's most traded spice. It is one of the most common spices added to European cuisine and its descendants. The spiciness of black pepper is due to the chemical piperine. It is ubiquitous in the industrialized world, often paired with table salt.\n Black pepper is produced from the still-green unripe drupes of the pepper plant. The drupes are cooked briefly in hot water, both to clean them and to prepare them for drying. The heat ruptures cell walls in the pepper, speeding the work of browning enzymes during drying. The drupes are dried in the sun or by machine for several days, during which the pepper around the seed shrinks and darkens into a thin, wrinkled black layer. Once dried, the spice is called black peppercorn.\n On some estates, the berries are separated from the stem by hand and then sun-dried without the boiling process. Once the peppercorns are dried, pepper spirit & oil can be extracted from the berries by crushing them. Pepper spirit is used in famous beverages like Coca-Cola and many medicinal and beauty products. Pepper oil is also used as an ayurvedic massage oil and used in certain beauty and herbal treatments. "); -- 3
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES((SELECT wiki_id FROM wiki WHERE wiki_title = "Butter" LIMIT 1), 27, "Butter", "Butter is a dairy product made by churning fresh or fermented cream or milk. It is generally used as a spread and a condiment, as well as in cooking, such as baking, sauce making, and pan frying. Butter consists of butterfat, milk proteins and water. Most frequently made from cows' milk, butter can also be manufactured from the milk of other mammals, including sheep, goats, buffalo, and yaks. Salt, flavorings and preservatives are sometimes added to butter. Rendering butter produces clarified butter or ghee, which is almost entirely butterfat.\nButter is a water-in-oil emulsion resulting from an inversion of the cream, an oil-in-water emulsion; the milk proteins are the emulsifiers. Butter remains a solid when refrigerated, but softens to a spreadable consistency at room temperature, and melts to a thin liquid consistency at 32–35 °C (90–95 °F). The density of butter is 911 g/L (56.9 lb/ft3).[1]\nIt generally has a pale yellow color, but varies from deep yellow to nearly white. Its unmodified color is dependent on the animals' feed and is commonly manipulated with food colorings in the commercial manufacturing process, most commonly annatto or carotene. The word butter derives (via Germanic languages) from the Latin butyrum,[2] which is the latinisation of the Greek (bouturon).[3][4] This may have been a construction meaning 'cow-cheese', from (bous), 'ox, cow'[5] + (turos), 'cheese',[6] but perhaps this is a false etymology of a Scythian word.[7]\n Nevertheless, the earliest attested form of the second stem, turos ('cheese'), is the Mycenaean Greek tu-ro, written in Linear B syllabic script.[8] The root word persists in the name butyric acid, a compound found in rancid butter and dairy products such as Parmesan cheese. In general use, the term 'butter' refers to the spread dairy product when unqualified by other descriptors. The word commonly is used to describe puréed vegetable or seed & nut products such as peanut butter and almond butter. It is often applied to spread fruit products such as apple butter. Fats such as cocoa butter and shea butter that remain solid at room temperature are also known as 'butters'.\n In addition to the act of applying butter being called 'to butter', non-dairy items that have a dairy butter consistency may use 'butter' to call that consistency to mind, including food items such as maple butter and witch\'s butter and nonfood items such as baby bottom butter, hyena butter, and rock butter."); -- 4
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES((SELECT wiki_id FROM wiki WHERE wiki_title = "Flour" LIMIT 1), 26, "Flour", "Flour is a powder which is made by grinding cereal grains, other seeds or roots (like Cassava). It is the main ingredient of bread, which is a staple food for many cultures, making the availability of adequate supplies of flour a major economic and political issue at various times throughout history. Wheat flour is one of the most important foods in European, North American, Middle Eastern, Indian and North African cultures, and is the defining ingredient in most of their styles of breads and pastries.\n Maize flour has been important in Mesoamerican cuisine since ancient times, and remains a staple in much of Latin American cuisine.[citation needed] Rye flour is an important constituent of bread in much of central/northern Europe. It was discovered around 6000 BC that wheat seeds could be crushed between simple millstones to make flour.[2] The Romans were the first to grind seeds on cone mills. In 1879, at the beginning of the Industrial Era, the first steam mill was erected in London.\n[3] In the 1930s, some flour began to be enriched with iron, niacin, thiamine and riboflavin. In the 1940s, mills started to enrich flour and folic acid was added to the list in the 1990s. Degermed and heat-processed flour An important problem of the industrial revolution was the preservation of flour. Transportation distances and a relatively slow distribution system collided with natural shelf life. The reason for the limited shelf life is the fatty acids of the germ, which react from the moment they are exposed to oxygen.\n This occurs when grain is milled; the fatty acids oxidize and flour starts to become rancid. Depending on climate and grain quality, this process takes six to nine months. In the late 19th century, this process was too short for an industrial production and distribution cycle. As vitamins, micro nutrients and amino acids were completely or relatively unknown in the late 19th century, removing the germ was a brilliant solution. Without the germ, flour cannot become rancid. Degermed flour became standard. Degermation started in densely populated areas and took approximately one generation to reach the countryside.\n Heat-processed flour is flour where the germ is first separated from the endosperm and bran, then processed with steam, dry heat or microwave and blended into flour again.[4] The FDA has been advised by several cookie dough manufacturers that they have implemented the use of heat-treated flour for their ready-to-bake cookie dough products' to reduce the risk of E. coli contamination.[5]"); -- 5
INSERT INTO wiki_content (wiki_id, picture_id, title, content) VALUES((SELECT wiki_id FROM wiki WHERE wiki_title = "Chicken" LIMIT 1), 28, "Chicken", "The chicken (Gallus gallus domesticus is a domesticated fowl, a subspecies of the Red Junglefowl. As one of the most common and widespread domestic animals, and with a population of more than 24 billion in 2003,[1] there are more chickens in the world than any other species of bird. Humans keep chickens primarily as a source of food, consuming both their meat and their eggs. The chicken's cultural and culinary dominance could be considered amazing to some in view of its believed domestic origin and purpose and it has inspired contributions to culture, art, cuisine, science and religion [2] from antiquity to the present.\n\n The traditional poultry farming view of the domestication of the chicken is stated in Encyclopædia Britannica (2007): 'Humans first domesticated chickens of Indian origin for the purpose of cockfighting in Asia, Africa, and Europe. Very little formal attention was given to egg or meat production...\n\n[3] Recent genetic studies have pointed to multiple maternal origins in Southeast, East, and South Asia, but with the clade found in the Americas, Europe, the Middle East and Africa originating in the Indian subcontinent. From India the domesticated fowl made its way to the Persianized kingdom of Lydia in western Asia Minor, and domestic fowl were imported to Greece by the fifth century BC.\n\n[4] Fowl had been known in Egypt since the 18th Dynasty, with the 'bird that gives birth every day' having come to Egypt from the land between Syria and Shinar, Babylonia, according to the annals of Tutmose III.[5][6]"); -- 6
INSERT INTO wiki_content (wiki_id, video_id, picture_id, title, content) VALUES((SELECT wiki_id FROM wiki WHERE wiki_title = "Grilling" LIMIT 1), 2, 43, "Grilling", "Grilling is a form of cooking that involves dry heat applied to the surface of food, commonly from above or below. Grilling usually involves a significant amount of direct, radiant heat, and tends to be used for cooking meat quickly and meat that has already been sliced (or other pieces). Food to be grilled is cooked on a grill (an open wire grid such as a gridiron with a heat source above or below), a grill pan (similar to a frying pan, but with raised ridges to mimic the wires of an open grill), or griddle (a flat plate heated from below).[1] Heat transfer to the food when using a grill is primarily via thermal radiation. Heat transfer when using a grill pan or griddle is by direct conduction. In the United States and Canada, when the heat source for grilling comes from above, grilling is termed broiling.[2] In this case, the pan that holds the food is called a broiler pan, and heat transfer is by thermal convection. Grilling, like most forms of cooking is more art than science. You can follow a few basic rules but after that it is your skill and style that will make you a great griller or a not so great griller. These tips will help you with many of the problems most people have.");  -- 7
