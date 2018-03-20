require 'sinatra'
require 'sinatra/base'
require 'redis'
require 'json'
require 'pp'

require 'digest/md5'


set :bind, '0.0.0.0'
set :port, '8080'    

$redis = Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'])

get '/' do
    'Hello from GKE!'
end

get '/app' do
  'Look Ma, no hands'
end

get '/load' do
  a = Array (1..100)
  a.each do |i|
    i.to_s
  end
  'Working for my primary...'
end 

get '/set/:key/:val' do
  key = params.fetch('key','')
  val = params.fetch('val','')
  output =  "Trying to add adding " + key + " with value " + val + "<br>"
  if $redis.set(key,val)
      output += "Adding " + key + " with value " + val + "<br>"
  else
      output += "Could not add " + key + "<br>"
  end
  return output
end

get '/:key' do
  key = params.fetch('key','')
  if $redis.get(key)
    return 'value of ' + key + ' is ' + $redis.get(key)
  else
    return key + ' does not appear to exist'
  end
end

get '/?*' do
  return "No key or value"
end


