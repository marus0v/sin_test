# https://blog.appsignal.com/2023/05/31/how-to-use-sinatra-to-build-a-ruby-application.html

# Include all the gems listed in Gemfile
require 'bundler'
require 'sinatra/activerecord'  # Критически важно!
require 'active_record'
require 'sequel'
require 'json'
require_relative 'lib/user'
# require_relative 'lib/level'
require_relative 'lib/product'
require_relative 'lib/operation'
# require_relative 'lib/submit'
Bundler.require

module LoyaltyCount

  class App < Sinatra::Base
 
    # @@SQLITE_DB_FILE = 'db/test.db'

    # global settings
    configure do
      set :root, File.dirname(__FILE__)
      set :public_folder, 'public'
 
      # register Sinatra::ActiveRecordExtension
    end
 
    # development settings
    configure :development do
      # this allows us to refresh the app on the browser without needing to restart the web server
      register Sinatra::Reloader
    end
    
    # database settings
    set :database_file, 'config/database.yml'

    # root route
    get '/'  do
      erb :index
    end

    get '/operation' do
      "Operation X!"
    end

    post '/operation' do
      # Логируем факт получения запроса
      "[#{Time.now}] POST /operation received"
      
      begin
        request.body.rewind
        raw_body = request.body.read
        puts "Raw request body: #{raw_body}"
        
        json_data = JSON.parse(raw_body)
        puts "Parsed JSON data: #{json_data.inspect}"
        
        # Логируем вызов Operation.count
        result = Operation.count(json_data)
        puts "Operation.count returned: #{result.inspect}"
        
        # Возвращаем результат
        # result
        content_type :json
        JSON.pretty_generate(result, indent: '  ')
      rescue JSON::ParserError => e
        puts "JSON parse error: #{e.message}"
        status 400
        "Неверный формат JSON"
      rescue => e
        puts "Unexpected error: #{e.class}: #{e.message}"
        puts e.backtrace.join("\n")
        status 500
        "Внутренняя ошибка сервера"
      end
    end

    get '/submit' do
      "Submit X!"
    end

    post '/submit' do
      # Логируем факт получения запроса
      "[#{Time.now}] POST /submit received"
      
      begin
        request.body.rewind
        raw_body = request.body.read
        puts "Raw request body: #{raw_body}"
        
        json_data = JSON.parse(raw_body)
        puts "Parsed JSON data: #{json_data.inspect}"
        
        result = Operation.submit(json_data)
        puts "Operation.submit returned: #{result.inspect}"
        
        # Возвращаем результат
        # result
        content_type :json
        JSON.pretty_generate(result, indent: '  ')
      rescue JSON::ParserError => e
        puts "JSON parse error: #{e.message}"
        status 400
        "Неверный формат JSON"
      rescue => e
        puts "Unexpected error: #{e.class}: #{e.message}"
        puts e.backtrace.join("\n")
        status 500
        "Внутренняя ошибка сервера"
      end
    end
    
      get '/hello' do
        'Hello world!'
      end
  
      get '/start' do
        erb :start
      end
  
      # get '/sql_users' do
      #  User.get_users.to_s
      # end
  
      # get '/sql_user/:id' do
      #  User.get_user_level_by_id(params[:id]).to_s
      # end
  
      # get '/sql_user_template/:id' do
      #  User.get_template_by_id(params[:id]).to_s
      # end
  
      # get '/sql_user_bonus/:id' do
      #  User.get_bonus_by_id(params[:id]).to_s
      # end
  
      # get '/sql_level' do
      #  Level.get_levels.to_s
      # end
  
      # get '/sql_level/:name' do
      #  Level.get_template_by_name(params[:name]).to_s
      # end
  
      # get '/sql_level_id/:name' do
      #  Level.get_template_id_by_name(params[:name]).to_s
      # end
  
      # get '/sql_level_discount/:id' do
      #  Level.get_discount_by_id(params[:id]).to_s
      # end
  
      # get '/sql_level_cashback/:id' do
      #  Level.get_cashback_by_id(params[:id]).to_s
      # end
  
      # get '/sql_product_rule/:id' do
      #  Product.get_rule_by_id(params[:id]).to_s
      # end
  
      # get '/sql_info' do
      #  User.get_users.to_s
      #  Level.get_levels.to_s
      # end
   
      # results
      get '/results' do
        erb :results
      end
  end
end

LoyaltyCount::App.run! if __FILE__ == $0