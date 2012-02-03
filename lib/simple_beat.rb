require "json"
require "redis"
require "simple_beat/version"
require "simple_beat/beat"
require "simple_beat/data_store"

module SimpleBeat
  def self.alive?(identifier, threshold = 120)
    beat = data_store.fetch_beat(identifier)
    !!(beat && beat['timestamp'] && beat['timestamp'] >= (Time.now.to_i - threshold))
  end

  def self.recent_beats(threshold = 120)
    h = {}
    threshold_time = Time.now.to_i - threshold
    data_store.fetch_all_beats.each do |identifier, attributes|
      next if attributes['timestamp'].nil? || attributes['timestamp'] < threshold_time
      h[identifier] = attributes
    end
    h
  end

  def self.prune_beats(threshold = 3600)
    data_store.prune_beats(threshold)
  end

  def self.last_beat(identifier)
    attributes = data_store.fetch_beat(identifier)
    attributes && attributes['timestamp']
  end

  def self.reset!
    data_store.reset! 
  end

  def self.identifier
    @identifier = [Socket.getidentifier, $$].join(":")
  end

  def self.redis=(redis)
    @redis = redis
  end

  def self.redis
    @redis
  end

  def self.namespace=(namespace)
    @namespace = namespace
  end

  def self.namespace
    @namespace
  end

  def self.data_store
    @data_store ||= build_data_store
  end

  private
  def self.build_data_store
    if @redis.nil? || @namespace.nil?
      raise "Please defined redis and namespace"
    end

    DataStore.new(redis, namespace)
  end
end
