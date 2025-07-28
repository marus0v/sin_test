require_relative 'user'
require_relative 'level'

class Operation < ActiveRecord::Base
  @@SQLITE_DB_FILE = File.expand_path('../db/test.db', __dir__)
  
  def self.count(info)
    # info = info
    # puts info
    # {request_data: info}
    user_inf =  User.get_user_by_id(info['user_id']).flatten.to_s
    user_template_id = User.get_template_by_id(user_inf[1]) #.flatten.to_s
    # level_id =  User.get_template_by_id(info['user_id']).flatten.to_s
    discount = Level.get_discount_by_id(user_template_id[0]).to_s
    cashback = Level.get_cashback_by_id(user_template_id[0]).to_s
    positions_count = info['positions'].count
    positions = info['positions']
    # discounted_positions = positions.map {|p| p['price'] * (100 - 10) / 100}
    discounted_positions = positions.map do |p|
      {
        'id' => p['id'],
        'price' => p['price'] * (100 - discount.to_i) / 100,
        'quantity' => p['quantity']
      }
    end
    total_items = info['positions'].sum { |p| p['quantity'] }
    total_price = info['positions'].sum { |p| p['price'] * p['quantity']}
    {
      # user_id: info['user_id'],
      user_info: user_inf,
      user_template_id: user_template_id, #[0].to_i,
      # template: level_id['id'].to_i,
      discount: discount,
      cashback: cashback,
      positions_count: positions_count,
      # positions: positions,
      discounted_positions: discounted_positions,
      total_items: total_items,
      total_price: total_price
    }
    #{
    #request_data: info,
    # metadata: {
    #  user_id: info['user_id'],
    #  positions_count: info['positions'].count,
    #  total_items: info['positions'].sum { |p| p['quantity'] },
    #  total_price: info['positions'].sum { |p| p['price'] * p['quantity'] }
    #},
    #processed_at: Time.now.utc.iso8601
    #}
  end

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
    return result
  end

  def self.get_rule_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT type, value FROM Products WHERE id = ?", id.to_i).flatten
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