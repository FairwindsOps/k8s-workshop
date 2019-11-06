require 'sinatra'
require 'sinatra/base'
require 'redis'
require 'json'
require 'pp'

require 'digest/md5'


set :bind, '0.0.0.0'
set :port, '8080'

$redis = Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'])

if ENV['CHAOS']
  chaos_limit = rand(1..100)
else
  chaos_limit = -1
end

chaos_count = 0

before do
  if chaos_limit > 0 and chaos_limit <= chaos_count
    Process.kill('KILL', Process.pid)
  end
  chaos_count += 1
end

get '/' do

  output = 'Hello from Kubernetes! I am serving from pod: ' + `hostname`.strip
  output += "\n"
  return output
end

get '/load' do
  a = Array (1..100)
  a.each do |i|
    i.to_s
  end
  output = 'Working for my primary...' + chaos_count.to_s + ':' + chaos_limit.to_s
  output += "\n"
  return output
end

get '/:key/:val' do
  key = params.fetch('key','')
  val = params.fetch('val','')
  output =  "Trying to add adding " + key + " with value " + val + "<br>"
  if $redis.set(key,val)
      output += "Adding " + key + " with value " + val + "<br>"
  else
      output += "Could not add " + key + "<br>"
  end
  output += "\n"
  return output
end

get '/:key' do
  key = params.fetch('key','')
  if $redis.get(key)
    output = 'value of ' + key + ' is ' + $redis.get(key)
  else
    output = key + ' does not appear to exist'
  end
  output += "\n"
  return output
end
