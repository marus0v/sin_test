class User < ActiveRecord::Base
  @@SQLITE_DB_FILE = File.expand_path('../db/test.db', __dir__)
  DB = Sequel.connect('sqlite://db/test.db')
  
  def self.get_users
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT * FROM Users")
    db.close
    return result
  end

  def self.get_user_level_by_id(id)
    user_inf = DB[:users].where(id: id).first
    user_level = DB['select discount, cashback from templates where id = ?', user_inf[:template_id]].first
    result = user_inf.merge(user_level)
    puts result.to_s
    return result # [:cashback].to_s
  end

  def self.get_user_by_id(id)
    # user_inf = DB[:users].where(id: id).first
    # result = user_inf
    users = DB[:users]
    result = users.first(id: id)
    # users.first(id: id)
    # puts result
    # puts result[:id].to_s
    # return result[:id].to_s
    return result[:name].to_s
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

  def self.get_user_inf_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    result = db.execute("SELECT * FROM Users WHERE id = ?", id.to_i)
    db.close
    return result
  end
  
end