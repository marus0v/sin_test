require_relative 'user'
require_relative 'level'
require_relative 'product'

class Operation < ActiveRecord::Base
  DB = Sequel.connect('sqlite://db/test.db')

  def self.get_last_id
    result = DB[:operations].max(:id)
    return result || 0
  end

  def self.count(info)
    new_operation_id = (Operation.get_last_id + 1).to_i
    user_inf =  User.get_user_level_by_id(info['user_id'])
    positions_count = info['positions'].count
    positions = info['positions']
    discounted_positions = positions.map do |p|
        Product.count_product_discount(p['id'], p['price'], p['quantity'], user_inf)
    end
    total_items = info['positions'].sum { |p| p['quantity'] }
    total_price = info['positions'].sum { |p| p['price'] * p['quantity']}
    total_discounted_price = discounted_positions.sum { |p| p['price'] * p['quantity']} - discounted_positions.sum { |p| p['discount_summ']}
    discount_summ = (discounted_positions.sum { |p| p['discount_summ'].to_i }).to_f.round(1)
    discount_value = ((discount_summ.to_f / total_price ) * 100).round(2)
    discount = {
        'summ' => discount_summ,
        'value' => discount_value
    }
    cashback_positions = discounted_positions.map do |p|
      product_id = p['id']
      product_inf = Product.show_product_discount_cashback(p['type'], p['value'])
      discounted_price = (p['price'] * (100 - user_inf[:discount].to_i - p['discount_percent'].to_i) / 100).to_f
      {
        'id' => product_id,
        'price' => discounted_price,
        'quantity' => p['quantity'],
        'type' => product_inf['type'],
        'cashback_value' => product_inf['cashback_value'],
        'bonus_max_writeoff' => p['type'].to_s == 'noloyalty' ? 0 : (discounted_price * p['quantity'].to_i),
        'bonus_add' => p['type'].to_s == 'noloyalty' ? 0 : ((discounted_price * (user_inf[:cashback].to_i + product_inf['cashback_value']) * p['quantity'] / 100).to_i),
        'discount_summ' => p['price'] - p['price'] * (100 - product_inf['discount_value'].to_i) / 100
      }
    end
    max_writeoff = (cashback_positions.sum { |p| p['bonus_max_writeoff'].to_i }).to_f.round(1)
    total_bonus_add = (cashback_positions.sum { |p| p['bonus_add'].to_i }).to_f.round(0)
    total_bonus_percent = ((total_bonus_add / total_discounted_price.to_f) * 100).to_f.round(2)
    cashback = {
        'existed_summ': user_inf[:bonus].to_i,
        'allowed_summ': max_writeoff,
        'value': total_bonus_percent.to_s + "%",
        'will_add': total_bonus_add
    }

    result = {
      status: 200,
      user: {
        id: user_inf[:id].to_i,
        template_id: user_inf[:template_id].to_i,
        name: user_inf[:name].to_s,
        bonus: user_inf[:bonus].to_i
      },
      operation_id: new_operation_id,
      summ: total_discounted_price.to_f.round(1),
      positions: discounted_positions,
      discount: discount,
      cashback: cashback
    }
    operations = DB[:operations]
    operations.insert(id: result[:operation_id],
    user_id: result[:user][:id],
    cashback: result[:cashback][:will_add],
    cashback_percent: result[:cashback][:value],
    discount: result[:discount]['summ'],
    discount_percent: result[:discount]['value'],
    write_off: result[:cashback][:allowed_summ],
    allowed_write_off: result[:cashback][:allowed_summ],
    check_summ: result[:summ],
    done: 'false'
    )
    return result
  end

  def self.get_operation_by_id(id)
    operation = DB[:operations].where(id: id).first
    return operation
  end

  def self.submit(info)
    user_inf =  info['user']
    user_id = user_inf['id']
    user_template_id = user_inf['template_id']
    operation_id = info['operation_id'].to_i
    operation_write_off = info['write_off'].to_i
    operation = Operation.get_operation_by_id(operation_id)
    operation_max_write_off = operation[:allowed_write_off].to_i
    # технически далее должен быть перерасчет операции согласно продуктам и правилам
    if operation_write_off < operation_max_write_off
      op_check_summ = operation[:check_summ].to_i
      op_write_off = operation_write_off
      op_check_summ = op_check_summ - op_write_off
      op_cashback = ((op_check_summ * operation[:cashback_percent].to_i)/100).round(0)
      user_bonus = user_inf['bonus'].to_i - op_write_off + op_cashback
    end

    operations = DB[:operations]
    users = DB[:users]
    DB.transaction do
      operations.where(id: operation_id).update(cashback: op_cashback, write_off: op_write_off, check_summ: op_check_summ, done: 'true')
      users.where(id: user_id).update(bonus: user_bonus)
    end
    result = op_cashback
    
    return result
  end
end