require_relative "../config/environment.rb"
require 'pry'
class Student
    # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL 
    CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id.nil?
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      sql = <<-SQL
      UPDATE students 
      SET name = ?, grade = ?
      WHERE id =  ?
      SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    name = row[1]
    grade = row[2]
    id = row[0]
    self.new(name, grade, id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE students.name = ?
    SQL
    student = DB[:conn].execute(sql, name)[0]
    self.new_from_db(student)
  end

  def update 
    sql = <<-SQL
    UPDATE students 
    SET name = ?, grade = ?
    WHERE id =  ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)[0]
  end


end
