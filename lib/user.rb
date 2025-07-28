class User < ActiveRecord::Base
  # @@SQLITE_DB_FILE = 'test.db'
  @@SQLITE_DB_FILE = File.expand_path('../db/test.db', __dir__)
    
  # def index
  #  @articles = Article.all
  # end
  
  def self.get_users
        # db = SQLite3::Database.open(@@SQLITE_DB_FILE) # открываем "соединение" к базе SQLite
        # db.results_as_hash = true # настройка соединения к базе, он результаты из базы преобразует в Руби хэши
        # db.execute("SELECT * FROM Users")
        # закрываем соединение
        #db.close

    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT * FROM Users")
    db.close
    # result.to_s
    return result
  end

  def self.get_user_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT * FROM Users WHERE id = ?", id.to_i)
    db.close
    return result
  end

  def self.get_template_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT template_id FROM Users WHERE id = ?", id.to_i)
    db.close
    return result[0]
  end

  def self.get_bonus_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT bonus FROM Users WHERE id = ?", id.to_i)
    db.close
    return result
  end
    
    def save_to_db
        db = SQLite3::Database.open(@@SQLITE_DB_FILE) # открываем "соединение" к базе SQLite
        db.results_as_hash = true # настройка соединения к базе, он результаты из базы преобразует в Руби хэши
    
        # запрос к базе на вставку новой записи в соответствии с хэшом, сформированным дочерним классом to_db_hash
        db.execute(
          "INSERT INTO posts (" +
            to_db_hash.keys.join(', ') + # все поля, перечисленные через запятую
            ") " +
            " VALUES ( " +
            ('?,'*to_db_hash.keys.size).chomp(',') + # строка из заданного числа _плейсхолдеров_ ?,?,?...
            ")",
          to_db_hash.values # массив значений хэша, которые будут вставлены в запрос вместо _плейсхолдеров_
        )
    
        insert_row_id = db.last_insert_row_id
    
        # закрываем соединение
        db.close
    
        # возвращаем идентификатор записи в базе
        return insert_row_id
      end
  
end