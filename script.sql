USE twitterdb;

CREATE TABLE users (
	user_id INT NOT NULL AUTO_INCREMENT,
	user_name VARCHAR(50) NOT NULL UNIQUE,
	email_address VARCHAR(50) NOT NULL UNIQUE,
	first_name VARCHAR(25) NOT NULL,
	last_name VARCHAR(25) NOT NULL,
	phonenumber CHAR(10) UNIQUE,
	created_at TIMESTAMP NOT NULL DEFAULT (NOW()),
	PRIMARY KEY(user_id)
)

-- INSERT INTO users(user_name, email_address, first_name, last_name, phonenumber)
-- VALUES ('user1', 'user1@gmail.com', 'user1', 'lastname1', '5700100100')

INSERT INTO users(user_name, email_address, first_name, last_name, phonenumber)
VALUES ('user2', 'user2@gmail.com', 'user2', 'lastname2', '5700100102'),
('user3', 'user3@gmail.com', 'user3', 'lastname3', '5700100103'),
('user4', 'user4@gmail.com', 'user4', 'lastname4', '5700100104'),
('user5', 'user5@gmail.com', 'user5', 'lastname5', '5700100105'),
('user6', 'user6@gmail.com', 'user6', 'lastname6', '5700100106');

CREATE TABLE followers(
	follower_id INT NOT NULL,
	following_id INT NOT NULL,
	PRIMARY KEY(follower_id, following_id),
	FOREIGN KEY(follower_id) REFERENCES users(user_id),
	FOREIGN KEY(following_id) REFERENCES users(user_id)
)

ALTER TABLE followers
ADD CONSTRAINT not_autofollowing
CHECK (follower_id <> following_id)

INSERT INTO followers (follower_id, following_id)
VALUES
(1, 2),
(2, 1),
(3, 1),
(4, 1),
(5, 6),
(2, 5),
(3, 5);

SELECT * FROM followers;

-- Traer todos los seguidores del user1
SELECT follower_id FROM followers WHERE following_id = 1;

-- Cuenta los seguidores que tiene el user1
SELECT COUNT(follower_id) AS number_of_followers FROM followers WHERE following_id = 1;

-- Top 3 usuarios con mas seguidores
SELECT following_id, COUNT(follower_id) AS number_of_followers
FROM followers
GROUP BY following_id
ORDER BY number_of_followers DESC
LIMIT 3;

-- Top 3 usuarios con mas seguidores
SELECT users.user_id, users.user_name, following_id, COUNT(follower_id) AS number_of_followers
FROM followers
JOIN users ON users.user_id = followers.following_id
GROUP BY following_id
ORDER BY number_of_followers DESC
LIMIT 3;

CREATE TABLE tweets(
	tweet_id INT NOT NULL AUTO_INCREMENT,
	user_id INT NOT NULL,
	tweet_text VARCHAR(280) NOT NULL,
	num_likes INT DEFAULT 0,
	num_retweets INT DEFAULT 0,
	num_comments INT DEFAULT 0,
	created_at TIMESTAMP NOT NULL DEFAULT (NOW()),
	FOREIGN KEY(user_id) REFERENCES users(user_id),
	PRIMARY KEY(tweet_id)
)

INSERT INTO tweets(user_id, tweet_text)
VALUES
(1, 'mi primer tweet'),
(2, 'estrenando twitter'),
(3, 'aprendiendo mysql'),
(1, 'mi segundo tweet'),
(2, 'estoy aburrido'),
(3, 'quisiera estar durmiendo'),
(1, 'a ver si aprendo algo'),
(1, 'y cambio de trabajo'),
(1, 'no me llamaron los franceses'),
(5, 'tweet para la subconsulta');

-- Cuantos tweet ha posteado un usuario
SELECT user_id, COUNT(tweet_id) AS number_of_tweets
FROM tweets
GROUP BY user_id 
ORDER BY number_of_tweets DESC;

-- Obtener los tweets de los usuarios que tienen màs de 2 seguidores
SELECT tweet_id, tweet_text, user_id FROM tweets
WHERE user_id IN (
	SELECT following_id
	FROM followers
	GROUP BY following_id
	HAVING COUNT(following_id) > 1
)

/* DELETE
DELETE FROM tweets WHERE tweet_id = 1;
DELETE FROM tweets WHERE user_id = 2;
DELETE FROM tweets WHERE tweet_text LIKE '%franceses%';
*/

-- UPDATE
UPDATE tweets SET num_comments = num_comments + 1 WHERE tweet_id = 8;
UPDATE tweets SET tweet_text = REPLACE (tweet_text, 'tweet', 'trino')
WHERE tweet_text LIKE '%tweet%';

CREATE TABLE tweet_likes(
	user_id INT NOT NULL,
	tweet_id INT NOT NULL,
	liked_at TIMESTAMP NOT NULL DEFAULT (NOW()),
	FOREIGN KEY (user_id) REFERENCES users(user_id),
	FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id),
	PRIMARY KEY (user_id, tweet_id)
)

INSERT INTO tweet_likes (user_id, tweet_id)
VALUES
(5, 1),
(6, 1),
(2, 7),
(1, 3),
(1, 7),
(3, 7),
(4, 7),
(5, 7),
(6, 7),
(5, 2),
(6, 3),
(5, 10);

-- Obtener el número de likes por tweet
SELECT tweets.tweet_text, tweet_likes.tweet_id, COUNT(tweet_likes.tweet_id) AS number_of_likes
FROM tweet_likes
JOIN tweets ON tweets.tweet_id = tweet_likes.tweet_id
GROUP BY tweet_likes.tweet_id
ORDER BY number_of_likes DESC;

-- Adicionar columna follower_count después de la columna phonenumber a la tabla users
ALTER TABLE users ADD follower_count INT NOT NULL DEFAULT 0 AFTER phonenumber;

-- TRIGGERS
DELIMITER $$
CREATE TRIGGER test
AFTER INSERT
ON followers FOR EACH ROW
UPDATE users SET follower_count = follower_count + 1 WHERE user_id = NEW.following_id;
DELIMITER ;

TRUNCATE TABLE followers ;

INSERT INTO followers (follower_id, following_id)
VALUES
(1, 2),
(2, 1),
(3, 1),
(4, 1),
(5, 6),
(2, 5),
(3, 5);

SELECT * FROM users;