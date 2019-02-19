PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;




CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY, 
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users(fname, lname)
VALUES
('John', 'Doe'), ('Jane', 'Doe'), ('Thomas', 'Train'), ('Laurie', 'Louwrie');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('Assessment A00P', 'Do I need to worry about a 4 point score?', (SELECT id FROM users WHERE fname = 'Thomas' AND lname = 'Train')),
  ('Assess. A00P', 'Do I need to worry about a 3 point score?', (SELECT id FROM users WHERE fname = 'John' AND lname = 'Doe')),
  ('AssessmA00P', 'Do I need to worry about a 2 point score?', (SELECT id FROM users WHERE fname = 'Jane' AND lname = 'Doe')),
  ('Ass A00P', 'Do I need to worry about a 1 point score?', (SELECT id FROM users WHERE fname = 'Laurie' AND lname = 'Louwrie'));

INSERT INTO 
  replies(question_id, parent_id, user_id, body)
VALUES 
  ((SELECT id FROM questions WHERE title = 'Assessment A00P'), NULL, (SELECT id FROM users WHERE fname = 'John' AND lname = 'Doe'), 'Great question Thomas, I got a 3.'),
  ((SELECT id FROM questions WHERE title = 'Assessment A00P'), 1, (SELECT id FROM users WHERE fname = 'Jane' AND lname = 'Doe'), 'Great question Thomas, I got a 2.'),
  ((SELECT id FROM questions WHERE title = 'Assessment A00P'), 1, (SELECT id FROM users WHERE fname = 'Laurie' AND lname = 'Louwrie'), 'Terrible question, OF COURSE you need to worry.'),
  ((SELECT id FROM questions WHERE title = 'Ass A00P'), NULL, (SELECT id FROM users WHERE fname = 'Thomas' AND lname = 'Train'), 'Positive feedback is appreciated.');

  INSERT INTO 
    question_likes(user_id, question_id)
  VALUES 
    ((SELECT id FROM users WHERE fname = 'Thomas' AND lname = 'Train'), (SELECT id FROM questions WHERE title = 'Assessment A00P')),
    ((SELECT id FROM users WHERE fname = 'Jane' AND lname = 'Doe'), (SELECT id FROM questions WHERE title = 'Assessment A00P')),
    ((SELECT id FROM users WHERE fname = 'Jane' AND lname = 'Doe'), (SELECT id FROM questions WHERE title = 'Ass A00P'));
INSERT INTO 
    question_follows(user_id, question_id)
  VALUES 
    ((SELECT id FROM users WHERE fname = 'Thomas' AND lname = 'Train'), (SELECT id FROM questions WHERE title = 'Assessment A00P')),
    ((SELECT id FROM users WHERE fname = 'Jane' AND lname = 'Doe'), (SELECT id FROM questions WHERE title = 'Assessment A00P'));


