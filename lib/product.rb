class Product < ActiveRecord::Base
  # @@SQLITE_DB_FILE = 'test.db'
  @@SQLITE_DB_FILE = File.expand_path('../db/test.db', __dir__)
    
  # def index
  #  @articles = Article.all
  # end
  
  def self.get_products
        # db = SQLite3::Database.open(@@SQLITE_DB_FILE) # открываем "соединение" к базе SQLite
        # db.results_as_hash = true # настройка соединения к базе, он результаты из базы преобразует в Руби хэши
        # db.execute("SELECT * FROM Users")
        # закрываем соединение
        #db.close

    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT * FROM Products")
    db.close
    # result.to_s
    return result
  end

  def self.get_product_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT * FROM Products WHERE id = ?", id.to_i)
    db.close
    return result
  end

  def self.get_name_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT name FROM Products WHERE id = ?", id.to_i)
    db.close
    # if result.empty? return nil
    # else return result
    return result
  end

  def self.get_type_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT type FROM Products WHERE id = ?", id.to_i).flatten
    db.close
    if result.empty?
      return nil
    else
      return result[0]
    end
    # return result[0]
  end

  def self.get_value_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT value FROM Products WHERE id = ?", id.to_i).flatten
    db.close
    if result.empty?
      return nil
    else
      return result[0]
    end
    # return result
  end

  def self.get_type_desc(id)
    type = Product.get_type_by_id(id)
    case type
    when 'increased_cashback'
      desc = "Дополнительный кешбек"
      value = self.get_value_by_id(id)
      type_desc = "#{desc} #{value}%"
    when 'discount'
      desc = "Дополнительная скидка"
      value = self.get_value_by_id(id)
      type_desc = "#{desc} #{value}%"
    when 'noloyalty'
      desc = "Товар не участвует в программе лояльности"
      value = nil
      type_desc = "#{desc}"
    else
      type_desc = nil
    end
    # db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    # result = db.execute("SELECT value FROM Products WHERE id = ?", id.to_i).flatten
    # db.close
    # if result.empty?
    #  return nil
    # else
    #  return result[0]
    # end
    return type_desc
  end

  def self.get_discount_percent(id)
    type = Product.get_type_by_id(id)
    if type == 'discount'
      return Product.get_value_by_id(id)
    else
      return 0
    end
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