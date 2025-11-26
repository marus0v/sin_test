class User < ActiveRecord::Base
  DB = Sequel.connect('sqlite://db/test.db')

  def self.get_user_level_by_id(id)
    user_inf = DB[:users].where(id: id).first
    user_level = DB['select discount, cashback from templates where id = ?', user_inf[:template_id]].first
    result = user_inf.merge(user_level)
    # puts result.to_s
    return result
  end

  def self.get_user_loyalty_by_id(id)
    user_inf = DB[:users]
    .join(:templates, id: :template_id)
    .select(Sequel[:users].*, Sequel[:templates][:discount], Sequel[:templates][:cashback])
    .where(Sequel[:users][:id] => id)
    .first
    result = user_inf
    # puts result.to_s
    return result
  end

end