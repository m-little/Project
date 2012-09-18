USE project;

-- This sql script will flush the database!!!
-- to update database with this script:
-- run command: mysql -u student -p
-- enter password student
-- run command: \. /usr/local/node/docs/project/database.sql

-- or ...

-- mysql --user=student --password=student < /usr/local/node/docs/project/database.sql
-- ^ this doesn't give you any feedback though...



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
category_id INT(11) NOT NULL AUTO_INCREMENT,
category_name VARCHAR(40) NOT NULL,
CONSTRAINT pk_category PRIMARY KEY(category_id)
);

CREATE TABLE recipe
(
recipe_id INT(11) NOT NULL AUTO_INCREMENT,
owner_id VARCHAR(40) NOT NULL,
category_id INT(11) NOT NULL,
CONSTRAINT pk_recipe PRIMARY KEY(recipe_id),
CONSTRAINT fk_recipe_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_category FOREIGN KEY(category_id) REFERENCES category(category_id)
);

CREATE TABLE comment
(
comment_id INT(11) NOT NULL AUTO_INCREMENT,
owner_id VARCHAR(40) NOT NULL,
recipe_id INT(11) NOT NULL,
content VARCHAR(500) NOT NULL,
CONSTRAINT pk_comment PRIMARY KEY(comment_id),
CONSTRAINT fk_comment_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_comment_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id)
);

CREATE TABLE unit
(
unit_id INT(11) NOT NULL AUTO_INCREMENT,
unit_name VARCHAR(20) NOT NULL,
CONSTRAINT pk_unit PRIMARY KEY(unit_id)
);

CREATE TABLE ingredient
(
ingr_id INT(11) NOT NULL AUTO_INCREMENT,
ingr_name VARCHAR(20) NOT NULL,
CONSTRAINT pk_ingredient PRIMARY KEY(ingr_id)
);

CREATE TABLE recipe_ingredient
(
recipe_ingr_id INT(11) NOT NULL AUTO_INCREMENT,
recipe_id INT(11) NOT NULL,
ingr_id INT(11) NOT NULL,
unit_id INT(11) NOT NULL,
unit_amount INT(10) NOT NULL,
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
