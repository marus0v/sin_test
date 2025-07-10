# https://blog.appsignal.com/2023/05/31/how-to-use-sinatra-to-build-a-ruby-application.html

# Include all the gems listed in Gemfile
require 'bundler'
require 'sinatra/activerecord'  # Критически важно!
require 'active_record'
require_relative 'lib/user'
require_relative 'lib/level'
Bundler.require

# get '/hello' do
#  'Hello world!'
# end

module LoyaltyCount

  class App < Sinatra::Base
 
    @@SQLITE_DB_FILE = 'db/test.db'

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

    get '/hello' do
      'Hello world!'
    end
 
    # start here (where the user enters their info)
    get '/start' do
      erb :start
    end

    # start here (where the user enters their info)
    get '/sql_users' do
      # erb :start
      # db = SQLite3::Database.open(@@SQLITE_DB_FILE)
      # result = db.execute("SELECT * FROM Users")
      # db.close
      # result.to_s
      # users = get_users
      # users.to_s
      User.get_users.to_s
    end

    get '/sql_user/:id' do
      User.get_user_by_id(params[:id]).to_s
    end

    get '/sql_user_template/:id' do
      User.get_template_by_id(params[:id]).to_s
    end

    get '/sql_user_bonus/:id' do
      User.get_bonus_by_id(params[:id]).to_s
    end

    get '/sql_level' do
      Level.get_levels.to_s
    end

    get '/sql_level/:name' do
      Level.get_template_by_name(params[:name]).to_s
    end

    get '/sql_level_id/:name' do
      Level.get_template_id_by_name(params[:name]).to_s
    end

    get '/sql_info' do
      User.get_users.to_s
      Level.get_levels.to_s
    end
 
    # results
    get '/results' do
      erb :results
    end
 
  end
 
end

LoyaltyCount::App.run! if __FILE__ == $0

# module LivingCostCalc
# 
#  class App < Sinatra::Base
# 
#    # global settings
#    configure do
#      set :root, File.dirname(__FILE__)
#      set :public_folder, 'public'
# 
#      register Sinatra::ActiveRecordExtension
#    end
# 
#    # development settings
#    configure :development do
#      # this allows us to refresh the app on the browser without needing to restart the web server
#      register Sinatra::Reloader
#    end
#    
#    # database settings
#    set :database_file, 'config/database.yml'
#
    # root route
#    get '/'  do
#      erb :index
#    end
 
    # start here (where the user enters their info)
#    get '/start' do
#      erb :start
#    end
 
    # results
#    get '/results' do
#      erb :results
#    end
 
#  end
 
# end