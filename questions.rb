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
    data = QuestionsDatabase.instance.execute("SELECT * FROM users WHERE users.id = #{id}")
    User.new(data)
  end

  def initialize(options)
    debugger
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

 end

 class Question

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

 end

 class QuestionFollow

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

 end

 class Reply

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @body = options['body']
  end

 end

 class QuestionLike

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

 end