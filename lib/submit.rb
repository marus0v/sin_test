require_relative 'user'
require_relative 'level'
require_relative 'product'
require_relative 'operation'

class Submit < ActiveRecord::Base
  @@SQLITE_DB_FILE = File.expand_path('../db/test.db', __dir__)
  
  # def self.get_last_id
  #  db = SQLite3::Database.open(@@SQLITE_DB_FILE)
  #  result = db.execute("SELECT MAX(id) FROM operations").flatten
  #  db.close
  #  # result.to_s
  #  return result.to_i + 1
  # end

  def self.get_last_id
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT MAX(id) FROM operations").flatten.first
    db.close
    return result || 0
  end

  def self.count(info)
    puts info.to_s
    user_inf =  info['user']# .flatten #.to_s
    puts user_inf.to_s
    # user_template_id = User.get_template_by_id(user_inf[1]) #.flatten.to_s
    user_id = user_inf['id']
    puts user_id.to_i
    user_template_id = user_inf['template_id']
    puts user_template_id.to_i
    operation_id = info['operation_id'].to_i
    puts operation_id
    operation_write_off = info['write_off'].to_i
    puts operation_write_off
    operation = Operation.get_operation_by_id(operation_id).first
    # operation = Operation.get_operation_by_id(1)
    puts operation# .to_s
    operation_max_write_off = operation[9]
    puts operation_max_write_off.to_s
    # технически далее должен быть перерасчет операции согласно продуктам и правилам
    if operation_write_off < operation_max_write_off
      op_check_summ = operation[7]
      puts op_check_summ
      op_write_off = operation_write_off
      puts op_write_off
      op_check_summ = op_check_summ - op_write_off
      puts op_check_summ
      op_cashback = ((op_check_summ * operation[3].to_i)/100).round(0)
      puts op_cashback
    end

    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = true
    # db.execute("UPDATE operations SET " +
    #"cashback = op_cashback, " +
    #"write_off = op_write_off, " +
    #"check_summ = op_check_summ, " +
    #"done = 'true' " +
    #"WHERE id = operation_id")# +
    db.execute(
      "UPDATE operations SET cashback = ?, write_off = ?, check_summ = ?, done = 'true' WHERE id = ?",
      [op_cashback, op_write_off, op_check_summ, operation_id]
    )
    #"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [result[:operation_id], result[:user][:id], result[:cashback][:will_add], result[:cashback][:value], result[:discount]['summ'], result[:discount]['value'], result[:cashback][:allowed_summ], result[:cashback][:allowed_summ], result[:summ], 'false'])
    db.close
    result = op_cashback
    return result
  end

    # user_discount = Level.get_discount_by_id(user_template_id[0]).to_i
    # discount = 0
    # discount_level = Level.get_discount_by_id(user_template_id[0]).to_i
    # cashback = Level.get_cashback_by_id(user_template_id[0]).to_s
    # user_cashback = Level.get_cashback_by_id(user_template_id[0]).to_i
    # positions_count = info['positions'].count
    # positions = info['positions']
    # discounted_positions = positions.map do |p|
    #  {
    #    'id' => p['id'],
    #    'price' => p['price'] * (100 - user_discount) / 100,
    #    'quantity' => p['quantity'],
    #    'type' => Product.get_type_by_id(p['id']),
    #    'value' => Product.get_value_by_id(p['id']),
    #    'type_desc' => Product.get_type_desc(p['id']),
    #    'discount_percent' => Product.get_discount_percent(p['id']),
    #    'discount_summ' => p['price'] - p['price'] * (100 - Product.get_discount_percent(p['id']).to_i) / 100
    #  }
    # end
    # total_items = info['positions'].sum { |p| p['quantity'] }
    # total_price = info['positions'].sum { |p| p['price'] * p['quantity']}
    # total_discounted_price = discounted_positions.sum { |p| p['price'] * p['quantity']}
    # puts total_discounted_price
    # discount_summ = (discounted_positions.sum { |p| p['discount_summ'].to_i }).to_f.round(1)
    # discount_value = ((discount_summ.to_f / total_price ) * 100).round(2)
    # discount = {
    #    'summ' => discount_summ,
    #    'value' => discount_value
    #}
    #cashback_positions = discounted_positions.map do |p|
    #  product_id = p['id']
    #  product_inf = Product.get_product_discount_cashback(p['id'])
    #  discounted_price = (p['price'] * (100 - user_discount - p['discount_percent'].to_i) / 100).to_f
    #  {
    #    'id' => product_id,
    #    # 'price' => p['price'] * (100 - user_discount - p['discount_percent'].to_i) / 100,
    #    'price' => discounted_price,
    #    'quantity' => p['quantity'],
    #    'type' => product_inf['type'],
    #    'cashback_value' => product_inf['cashback_value'],
    #    'bonus_max_writeoff' => p['type'].to_s == 'noloyalty' ? 0 : (discounted_price * p['quantity'].to_i),
    #    'bonus_add' => p['type'].to_s == 'noloyalty' ? 0 : ((discounted_price * (user_cashback + product_inf['cashback_value']) * p['quantity'] / 100).to_i),
    #    # 'discount_percent' => Product.get_discount_percent(p['id']),
    #    'discount_summ' => p['price'] - p['price'] * (100 - Product.get_discount_percent(p['id']).to_i) / 100
    #  }
    #end
    #max_writeoff = (cashback_positions.sum { |p| p['bonus_max_writeoff'].to_i }).to_f.round(1)
    #total_bonus_add = (cashback_positions.sum { |p| p['bonus_add'].to_i }).to_f.round(0)
    #puts total_discounted_price
    #total_bonus_percent = ((total_bonus_add / total_discounted_price.to_f) * 100).to_f .round(2)
    #puts total_discounted_price
    #cashback = {
    #    'existed_summ': user_inf[3],
    # 'allowed_summ': 434.0,
    #    'allowed_summ': max_writeoff,
    # 'value': "4.19%",
        #'tba': total_bonus_add,
        #'tdp': total_discounted_price,
        #'value_test': total_bonus_add / total_discounted_price.to_f,
    #    'value': total_bonus_percent.to_s + "%",
    #    'will_add': total_bonus_add
    #}
    # end

    # return
    #result = {
    #  status: 200,
    #  user: {
    #    id: user_inf[0],
    #    template_id: user_inf[1],
    #    name: user_inf[2],
    #    bonus: user_inf[3]
    #  },
    #  operation_id_01: 666,
    #  operation_id: new_operation_id,
    #  summ: total_discounted_price.to_f.round(1),
    #  summ_01: 734.0,
    #  positions: discounted_positions,
    #  discount: discount,
    #  cashback: cashback #,
      # cashback_positions: cashback_positions
      # positions_count: positions_count,
      # positions: positions,
      #discounted_positions: discounted_positions,
      #total_items: total_items,
      #total_price: total_price,
      #total_discounted_price: total_discounted_price
    #}
    # result.save_to_db
    #db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    #db.results_as_hash = true
    # db.execute(
    #      "INSERT INTO operations ("
    #      id
    #      ")
    #      VALUES ("
    #      result['operation_id']
    #      ")"# ,
    #    # result.values # массив значений хэша, которые будут вставлены в запрос вместо _плейсхолдеров_
    #  )
    #db.execute("INSERT INTO operations (id, user_id, cashback, cashback_percent, discount, discount_percent, write_off, allowed_write_off, check_summ, done) " +
    #"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [result[:operation_id], result[:user][:id], result[:cashback][:will_add], result[:cashback][:value], result[:discount]['summ'], result[:discount]['value'], result[:cashback][:allowed_summ], result[:cashback][:allowed_summ], result[:summ], 'false'])
    #db.close
    #return result
  #end

  # def self.get_products
        # db = SQLite3::Database.open(@@SQLITE_DB_FILE) # открываем "соединение" к базе SQLite
        # db.results_as_hash = true # настройка соединения к базе, он результаты из базы преобразует в Руби хэши
        # db.execute("SELECT * FROM Users")
        # закрываем соединение
        #db.close

  #  db = SQLite3::Database.open(@@SQLITE_DB_FILE)
  #  result = db.execute("SELECT * FROM Products")
  #  db.close
    # result.to_s
  #  return result
  # end

  # def self.get_product_by_id(id)
  #  db = SQLite3::Database.open(@@SQLITE_DB_FILE)
  #  result = db.execute("SELECT * FROM Products WHERE id = ?", id.to_i)
  #  db.close
  #  return result
  # end

  # def self.get_name_by_id(id)
  #  db = SQLite3::Database.open(@@SQLITE_DB_FILE)
  #  result = db.execute("SELECT name FROM Products WHERE id = ?", id.to_i)
  #  db.close
  #  return result
  # end

  # def self.get_rule_by_id(id)
  #  db = SQLite3::Database.open(@@SQLITE_DB_FILE)
  #  result = db.execute("SELECT type, value FROM Products WHERE id = ?", id.to_i).flatten
  #  db.close
  #  return result
  # end
    
  def self.save_to_db
        db = SQLite3::Database.open(@@SQLITE_DB_FILE) # открываем "соединение" к базе SQLite
        db.results_as_hash = true # настройка соединения к базе, он результаты из базы преобразует в Руби хэши
    
        # запрос к базе на вставку новой записи в соответствии с хэшом, сформированным дочерним классом to_db_hash
        db.execute(
          "INSERT INTO operations (" +
            result.keys.join(', ') + # все поля, перечисленные через запятую
            ") " +
            " VALUES ( " +
            ('?,'*result.keys.size).chomp(',') + # строка из заданного числа _плейсхолдеров_ ?,?,?...
            ")",
          result.values # массив значений хэша, которые будут вставлены в запрос вместо _плейсхолдеров_
        )
    
        # insert_row_id = db.last_insert_row_id
    
        # закрываем соединение
        db.close
    
        # возвращаем идентификатор записи в базе
        return insert_row_id
  end

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
end