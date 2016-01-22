require 'redis'
require 'hiredis'
require 'redis-namespace'
require 'json'

require '../models/settings'

redis_connection = Redis.new(driver: :hiredis)
$redis = Redis::Namespace.new(Settings.redis.namespace.to_sym, redis: redis_connection)

def get_name(sockfd, host, port)
  name = nil
  $redis.keys.each do |key|
    if key.to_i == 0
      value = JSON.parse($redis.get(key))
      if value['sockfd'] == sockfd && value['host'] == host && value['port'] == port
        name = key
        break
      end
    end
  end
  name
end

def get_sockfd(name)
  value = JSON.parse($redis.get(name))
  value['sockfd']
end

def get_client_info(name)
  JSON.parse($redis.get(name))
end
