module SimpleBeat
  class DataStore
    def initialize(redis, namespace)
      @redis      = redis
      @namespace  = namespace 
    end

    def record_beat(hostname, attributes)
      @redis.hset(redis_key, hostname, attributes.to_json)
    end

    def fetch_beat(hostname)
      json = @redis.hget(redis_key, hostname)
      if json
        JSON.parse(json)
      else
        nil
      end
    end

    def fetch_all_beats
      h = {}
      @redis.hgetall(redis_key).each do |hostname, json|
        h[hostname] = JSON.parse(json)
      end
      h
    end

    def prune_beats(threshold = 3600)
      pruned = 0
      threshold_time = Time.now.to_i - threshold
      beats = fetch_all_beats

      @redis.pipelined do
        beats.each do |hostname, attributes|
          if attributes['timestamp'].nil? || attributes['timestamp'] < threshold_time
            @redis.hdel(redis_key, hostname)
            pruned += 1
          end
        end
      end
      pruned
    end

    def reset!
      @redis.del(redis_key)
    end

    private
    def redis_key
      [@hostname, "simple_beat_hash"].compact.join(":")
    end
  end
end
