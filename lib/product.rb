class Product < ActiveRecord::Base
  @@SQLITE_DB_FILE = File.expand_path('../db/test.db', __dir__)
  DB = Sequel.connect('sqlite://db/test.db')
  
  def self.get_products
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT * FROM Products")
    db.close
    return result
  end

  def self.count_product_discount(id, price, quantity, user_inf)
    # db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    # result = db.execute("SELECT * FROM Products WHERE id = ?", id.to_i)
    # db.close
    product_inf = DB[:products].where(id: id).first
    # if product_inf.empty?
    if product_inf.nil?
      product_inf = {:id => 0, :name => 0, :type => 0, :value => 0}
      #return product_inf = {:id => 0, :name => 0, :type => 0, :value => 0}
    # else # return result
    end
    # return product_inf
    user_discount = user_inf[:discount]
    type = product_inf[:type]
    value = product_inf[:value]
    type_desc = get_type_desc_by_type(product_inf[:type], product_inf[:value])
    product_discount_percent = product_inf[:type] == 'discount' ? product_inf[:value] : 0
    # discount_percent = product_discount_percent.to_i + user_discount.to_i
    discount_percent = type == 'noloyalty' ? 0 : product_discount_percent.to_i + user_discount.to_i
    discount_summ = price - price * (100 - discount_percent) / 100
    result = {
    'id' => id,
    'price' => price, # * (100 - user_inf[:discount].to_i) / 100,
    'quantity' => quantity,
    # 'type' => product_inf[:type],
    'type' => type,
    # 'value' => product_inf[:value],
    'value' => value,
    # 'type_desc' => get_type_desc_by_type(product_inf[:type]),
    'type_desc' => type_desc,
    # 'discount_percent' => Product.get_discount_percent(p['id']),
    # 'discount_percent' => product_inf[:type] == 'discount' ? product_inf[:value] : 0,
    'discount_percent' => discount_percent,
    # 'discount_summ' => p['price'] - p['price'] * (100 - Product.get_discount_percent(p['id']).to_i) / 100
    'discount_summ' => discount_summ
    }
    # puts result
    return result
  end

  def self.get_product_by_id(id)
    # db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    # result = db.execute("SELECT * FROM Products WHERE id = ?", id.to_i)
    # db.close
    product_inf = DB[:products].where(id: id).first
    if product_inf.empty?
      product_inf = {:id => 0, :name => 0, :type => 0, :value => 0}
      #return product_inf = {:id => 0, :name => 0, :type => 0, :value => 0}
    # else # return result
    end
    return product_inf
  end

  def self.get_name_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT name FROM Products WHERE id = ?", id.to_i)
    db.close
    # if result.empty?
    #  return 0
    # else
    return result
  end

  def self.get_type_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT type FROM Products WHERE id = ?", id.to_i).flatten
    db.close
    if result.empty?
      return 0
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
      return 0
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
      value = 0
      type_desc = "#{desc}"
    else
      type_desc = 0
    end
    return type_desc
  end

  def self.get_type_desc_by_type(type, value)
    case type
    when 'increased_cashback'
      desc = "Дополнительный кешбек"
      # value = self.get_value_by_id(id)
      # value = value
      type_desc = "#{desc} #{value}%"
    when 'discount'
      desc = "Дополнительная скидка"
      # value = self.get_value_by_id(id)
      type_desc = "#{desc} #{value}%"
    when 'noloyalty'
      desc = "Товар не участвует в программе лояльности"
      value = 0
      type_desc = "#{desc}"
    else
      type_desc = 0
    end
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

  def self.get_cashback_sum(id)
    type = Product.get_type_by_id(id)
    if type == 'increased_cashback'
      return Product.get_value_by_id(id)
    else
      return 0
    end
  end

  def self.check_noyoyalty(id)
    type = Product.get_type_by_id(id)
    if type == 'noloyalty'
      return true
    else
      return 0
    end
  end

  def self.get_product_discount_cashback(id)
    type = Product.get_type_by_id(id)
    discount_value = 0
    cashback_value  = 0
    desc = ""
    case type
    when 'increased_cashback'
      desc = "Дополнительный кешбек"
      value = self.get_value_by_id(id)
      type_desc = "#{desc} #{value}%"
      cashback_value = value
    when 'discount'
      desc = "Дополнительная скидка"
      value = self.get_value_by_id(id)
      type_desc = "#{desc} #{value}%"
      discount_value = value
    when 'noloyalty'
      desc = "Товар не участвует в программе лояльности"
      value = 0
      type_desc = "#{desc}"
    else
      type_desc = 0
    end
    return {'type' => type.to_s, 'desc' => type_desc.to_s, 'discount_value' => discount_value.to_i, 'cashback_value' => cashback_value.to_i}
  end
  
end