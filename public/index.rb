require 'sinatra'

get '/' do
  erb :index
end

get '/hello' do
  'Hello world!'
end

get '/time' do
  code = "<%= Time.now %>"
  erb code
end

get '/test' do
  'Mama Mia! Sinatra is working!'
end

set(:probability) { |value| condition { rand <= value } }

get '/win_a_car', :probability => 0.1 do
  "You won!"
end

get '/win_a_car' do
  "Sorry, you lost."
end

class Stream
  def each
    100.times { |i| yield "#{i}\n" }
  end
end

get('/stream') { Stream.new }
