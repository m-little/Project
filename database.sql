USE project;

-- This sql script will flush the database!!!
-- to update database with this script:
-- run command: mysql -u student -p
-- enter password student
-- run command: \. /usr/local/node/docs/project/database.sql

-- or ...

-- mysql --user=student --password=student < /usr/local/node/docs/project/database.sql
-- ^ this doesn't give you any feedback though...

DROP TABLE recipe_ingredient;
DROP TABLE ingredient;
DROP TABLE unit;
DROP TABLE comment;
DROP TABLE recipe;
DROP TABLE category;
DROP TABLE user;
DROP TABLE passkeys;

CREATE TABLE passkeys
(
user_id VARCHAR(40) NOT NULL,
pass VARCHAR(40) NOT NULL,
salt VARCHAR(40) NOT NULL,
CONSTRAINT pk_passkeys PRIMARY KEY(user_id)
);

CREATE TABLE user
(
user_id VARCHAR(40) NOT NULL,
user_group VARCHAR(20) NOT NULL,
user_fname VARCHAR(40) NOT NULL,
user_lname VARCHAR(40) NOT NULL,
email VARCHAR(50) NOT NULL,
date_added DATETIME NOT NULL,
CONSTRAINT pk_user PRIMARY KEY(user_id),
CONSTRAINT fk_user_passkeys FOREIGN KEY(user_id) REFERENCES passkeys(user_id)
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
rank_count INT UNSIGNED NOT NULL DEFAULT 0,
rank_sum INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_recipe PRIMARY KEY(recipe_id),
CONSTRAINT fk_recipe_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_category FOREIGN KEY(category_id) REFERENCES category(category_id)
);

CREATE TABLE comment
(
comment_id SERIAL,
owner_id VARCHAR(40) NOT NULL,
recipe_id BIGINT UNSIGNED NOT NULL,
content VARCHAR(500) NOT NULL,
CONSTRAINT pk_comment PRIMARY KEY(comment_id),
CONSTRAINT fk_comment_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_comment_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id)
);

CREATE TABLE unit
(
unit_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
unit_name VARCHAR(20) NOT NULL,
abrev VARCHAR(10),
use_count INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_unit PRIMARY KEY(unit_id)
);

CREATE TABLE ingredient
(
ingr_id SERIAL,
ingr_name VARCHAR(20) NOT NULL,
use_count INT(11),
CONSTRAINT pk_ingredient PRIMARY KEY(ingr_id)
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

INSERT INTO passkeys (user_id, pass, salt) VALUES('Sam', 'e233560939c66735c503f136f32a431cb203db78', 'aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Mike', '4d00564fd19d74efff6ba1f392f757f33fca273b', '4196ce6a9377e11ecc9f01517e8a118c4b596646');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Julia', '9bb9949ea212c05242d0110858987af879c84041', '5fc0d6f9d1b18a1a28738a9834ef6bf12c2716f9');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Curtis', '041b2e52b42326af4c9ac9c63504dd623ab51895', '1019078d1d90533aed697b1e94fbdba9bf3f4d4a');

INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added) VALUES('Sam', 'admin', 'Sam', 'Luebbert', 'sgluebbert1@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added) VALUES('Mike', 'admin', 'Mike', 'Little', 'malittle3@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added) VALUES('Julia', 'admin', 'Julia', 'Collins', 'jlcollins4@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added) VALUES('Curtis', 'admin', 'Curtis', 'Sydnor', 'casydnor1@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));

INSERT INTO unit (unit_name) VALUES(''); -- used for no unit ex: "4 eggs"
INSERT INTO unit (unit_name, abrev) VALUES('Teaspoon', 'tsp');
INSERT INTO unit (unit_name, abrev) VALUES('Tablespoon', 'tbsp');
INSERT INTO unit (unit_name, abrev) VALUES('Dessertspoon', 'dstspn');
INSERT INTO unit (unit_name) VALUES('Cup');
INSERT INTO unit (unit_name) VALUES('Drop');
INSERT INTO unit (unit_name, abrev) VALUES('Pinch', 'pn');
INSERT INTO unit (unit_name) VALUES('Dash');
INSERT INTO unit (unit_name) VALUES('Smidgen');
INSERT INTO unit (unit_name) VALUES('Handfull');
INSERT INTO unit (unit_name, abrev) VALUES('Gill', 'gi');
INSERT INTO unit (unit_name, abrev) VALUES('Ounce', 'oz');
INSERT INTO unit (unit_name, abrev) VALUES('Fluid Ounces', 'fl oz');
INSERT INTO unit (unit_name, abrev) VALUES('Pound', 'lb');
INSERT INTO unit (unit_name, abrev) VALUES('Pint', 'pt');
INSERT INTO unit (unit_name, abrev) VALUES('Quart', 'qt');
INSERT INTO unit (unit_name, abrev) VALUES('Gallon', 'gal');
INSERT INTO unit (unit_name) VALUES('Jigger');
INSERT INTO unit (unit_name, abrev) VALUES('Peck', 'pk');
INSERT INTO unit (unit_name, abrev) VALUES('Bushel', 'bu');
INSERT INTO unit (unit_name) VALUES('Firkin');
INSERT INTO unit (unit_name) VALUES('Hogshead');
INSERT INTO unit (unit_name, abrev) VALUES('Mililiter', 'ml');
INSERT INTO unit (unit_name, abrev) VALUES('Cubic Centimeter', 'cc');
INSERT INTO unit (unit_name) VALUES('Cubic Foot');
INSERT INTO unit (unit_name) VALUES('Cubic Inch');
INSERT INTO unit (unit_name, abrev) VALUES('Liter', 'l');
INSERT INTO unit (unit_name) VALUES('Fifth');
INSERT INTO unit (unit_name) VALUES('Shot');
INSERT INTO unit (unit_name, abrev) VALUES('Gram', 'g');
INSERT INTO unit (unit_name, abrev) VALUES('Kilogram', 'kg');
INSERT INTO unit (unit_name, abrev) VALUES('Inch', 'in');
INSERT INTO unit (unit_name, abrev) VALUES('Truckload', 'tl');
INSERT INTO unit (unit_name, abrev) VALUES('Partial Truckload', 'ltl');
INSERT INTO unit (unit_name) VALUES('Crate');
INSERT INTO unit (unit_name) VALUES('Bucket');
