require 'sqlite3'
require 'singleton'
require 'byebug'

 class QuestionsDatabase < SQLite3::Database 
  include Singleton 
    def initialize 
      super('questions.db')
      self.type_translation = true 
      self.results_as_hash = true
    end
 end

 class User
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute("SELECT * FROM users WHERE id = #{id}")
    User.new(data[0])
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute("SELECT * FROM users WHERE fname LIKE '#{fname}' COLLATE NOCASE AND lname LIKE '#{lname}' COLLATE NOCASE") 
    User.new(data[0])
  end

  attr_reader :fname, :lname, :id
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end
 end

 class Question

  attr_reader :title, :body, :id, :author_id
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions WHERE id = #{id}")
    Question.new(data[0])
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions WHERE author_id = #{author_id}")
    Question.new(data[0])
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author 
    User.find_by_id(self.author_id).fname
  end
 
  def replies
    Reply.find_by_question_id(self.id)
  end

 end

 class QuestionFollow
  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute("
    SELECT * 
    FROM questions
    ORDER BY (
      SELECT COUNT(*)
      FROM question_follows
      GROUP BY question_id
    )
    LIMIT #{n}
    ")

  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows WHERE id = #{id}")
    QuestionFollow.new(data[0])
  end

  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(
      "SELECT * 
       FROM users 
       JOIN question_follows 
        ON users.id = question_follows.user_id
       WHERE question_id = #{question_id}")
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(
      "SELECT * 
       FROM questions 
       JOIN question_follows 
        ON questions.id = question_follows.question_id
       WHERE user_id = #{user_id}")
  end

  attr_reader :user_id, :question_id, :id
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

 end

 class Reply

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies WHERE id = #{id}")
    Reply.new(data[0])
  end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies WHERE user_id = #{user_id}")
    Reply.new(data[0])
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies WHERE question_id = #{question_id}")
    Reply.new(data[0])
  end

  attr_reader :user_id, :question_id, :id, :parent_id, :body 
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @body = options['body']
  end

  def author
    User.find_by_id(self.user_id)
  end

  def question
    Question.find_by_id(self.question_id)
  end

  def parent_reply
    # raise "Reply has no parent" if parent_id == 'null'
    Reply.find_by_id(self.parent_id)
  end

  def child_replies
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies WHERE parent_id = #{self.id}")
    data.map {|datum| Reply.new(datum)}
  end

 end

 class QuestionLike
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes WHERE id = #{id}")
    QuestionLike.new(data[0])
  end

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute("
    SELECT * 
    FROM users 
    JOIN question_likes 
      ON users.id = question_likes.user_id
    WHERE question_id = #{question_id}")
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute("
    SELECT COUNT(*) AS num_likes 
    FROM users 
    JOIN question_likes 
      ON users.id = question_likes.user_id
    WHERE question_id = #{question_id}")
    data[0]['num_likes']
  end


  attr_reader :user_id, :question_id, :id
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

 end