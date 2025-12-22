class Product < ActiveRecord::Base
  DB = Sequel.connect('sqlite://db/test.db')

  def self.count_product_discount(id, price, quantity, user_inf)
    product_inf = DB[:products].where(id: id).first
    if product_inf.nil?
      product_inf = {:id => 0, :name => 0, :type => 0, :value => 0}
    end
    user_discount = user_inf[:discount]
    type = product_inf[:type]
    value = product_inf[:value]
    type_desc = get_type_desc_by_type(product_inf[:type], product_inf[:value])
    product_discount_percent = product_inf[:type] == 'discount' ? product_inf[:value] : 0
    # discount_percent = type == 'noloyalty' ? 0 : product_discount_percent.to_i + user_discount.to_i
    discount_percent = type == 'noloyalty' ? 0 : product_discount_percent.to_i + user_inf[:discount].to_i
    discount_summ = quantity * (price - price * (100 - discount_percent) / 100)
    result = {
    'id' => id,
    'price' => price,
    'quantity' => quantity,
    'type' => type,
    'value' => value,
    'type_desc' => type_desc,
    'discount_percent' => discount_percent,
    'discount_summ' => discount_summ
    }
    return result
  end

  def self.get_product_by_id(id)
    product_inf = DB[:products].where(id: id).first
    if product_inf.empty?
      product_inf = {:id => 0, :name => 0, :type => 0, :value => 0}
    end
    return product_inf
  end

  def self.get_type_desc_by_type(type, value)
    case type
    when 'increased_cashback'
      desc = "Дополнительный кешбек"
      type_desc = "#{desc} #{value}%"
    when 'discount'
      desc = "Дополнительная скидка"
      type_desc = "#{desc} #{value}%"
    when 'noloyalty'
      desc = "Товар не участвует в программе лояльности"
      type_desc = "#{desc}"
    else
      type_desc = 0
    end
    return type_desc
  end

  def self.show_product_discount_cashback(type, value)
    type = type
    discount_value = 0
    cashback_value  = 0
    desc = ""
    case type
    when 'increased_cashback'
      desc = "Дополнительный кешбек"
      value = value
      type_desc = "#{desc} #{value}%"
      cashback_value = value
    when 'discount'
      desc = "Дополнительная скидка"
      value = value
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