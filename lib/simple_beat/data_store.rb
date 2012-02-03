module SimpleBeat
  class DataStore
    def initialize(redis, namespace)
      @redis      = redis
      @namespace  = namespace 
    end

    def record_beat(attributes)
      @redis.hset(redis_key, SimpleBeat.identifier, attributes.to_json)
    end

    def fetch_beat(identifier)
      json = @redis.hget(redis_key, identifier)
      if json
        JSON.parse(json).merge(explode_identifier(identifier))
      else
        nil
      end
    end

    def fetch_all_beats
      h = {}
      @redis.hgetall(redis_key).each do |identifier, json|
        h[identifier] = JSON.parse(json).merge(explode_identifier(identifier))
      end
      h
    end

    def prune_beats(threshold = 3600)
      pruned = 0
      threshold_time = Time.now.to_i - threshold
      beats = fetch_all_beats

      @redis.pipelined do
        beats.each do |identifier, attributes|
          if attributes['timestamp'].nil? || attributes['timestamp'] < threshold_time
            @redis.hdel(redis_key, identifier)
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
    def explode_identifier(identifier)
      hostname, pid = identifier.split(":")
      { 'hostname' => hostname, 'pid' => pid }
    end

    def redis_key
      [@identifier, "simple_beat_hash"].compact.join(":")
    end
  end
end
