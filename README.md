# Simple beat

A simple heart beat library for ruby daemons using redis

## Usage

### Client

    SimpleBeat.redis = Redis.new
    SimpleBeat.namespace = 'my-app'

    sb = SimpleBeat.new

    # The #on_beat handler allows you to do additional actions on each beat
    sb.on_beat do
      # notify graphite, statsd, WHATEVER
    end
    
    # #beat_attributes allows you to define other key value pairs to store on 
    # each beat.  By default it just sends the 'hostname', 'pid' and 'timestamp'.
    sb.addition_attributes do
      { 'revision' => "abc", 'load' => Load.get }
    end

    # notify redis of existence and run the #on_beat handler. This is useful
    # if you want to send heartbeats after a succesful operation or want to 
    # avoid threads. May be a better option than a background thread if want 
    # to make sure you're daemon is still operating and not just spinning a 
    # background heart beat thread. Only actually sends a heartbeat every 'beat_period'.
    sb.beat

    # spin up a background thread that sends a heartbeat every 'beat_period'
    sb.run_beat_thread


### Query heartbeats

    # => { process_identifier => attributes }
    SimpleBeat.recent_beats(threshold = 300)

    # Prune heartbeats old than seconds 'threshold'
    SimpleBeat.prune_beats(threshold = 300)

    # Have we recieved a heartbeat from 'identifier' in the last 'threshold' seconds
    SimpleBeat.alive?(identifier, threshold = 120)

    # Returns time of last beat
    SimpleBeat.last_beat_at(identifier)


## Redis storage

    Heartbeats are stored in a hash with the hostname:pid as the key and attributes as the value

    redis.hset(simple_beat_hash, "#{hostname}:#{pid}", attributes)
