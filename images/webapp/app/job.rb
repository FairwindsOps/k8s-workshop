require 'redis'

$redis = Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'])

jobs = {
    "one" =>    "1",
    "two" =>    "2",
    "three" =>  "3",
    "four" =>   "4",
    "five" =>   "5",
    "six" =>    "6",
    "seven" =>  "7",
    "eight" =>  "8",
    "nine" =>   "9",
    "ten" =>    "10"
}

jobs.each do |key, value|
    if $redis.set(key, value)
        $stdout.write("Added " + key + " with value " + value + " to " + ENV['REDIS_HOST'])
    else
        $stderr.write("Failed to add " + key + " to " + ENV['REDIS_HOST'])
    end
end
