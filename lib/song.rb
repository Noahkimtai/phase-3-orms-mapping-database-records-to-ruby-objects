class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  # def method to create an object from db
  def self.new_from_db(row)
    # takes the array returned from db and create class instance
    self.new(id: row[0], name: row[1], album: row[2])
  end
  # def the method all to access data from database and create new object from them
  def self.all
    sql = <<-SQL
        SELECT * FROM songs
      SQL
    DB[:conn].execute(sql).map do |row|
      Song.new_from_db(row)
    end
  end

  # class method that fetch from db using name
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM songs
      WHERE name = ?
      LIMIT 1
    SQL
    #then create an instance of an object from the return
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

end
