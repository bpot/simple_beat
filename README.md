# Simple beat

A simple heart beat library for ruby daemons using redis

## Usage

### Client

    sb = SimpleBeat.new(:beat_period => 60, :namespace => 'my-app')

    # The #on_beat handler allows you to do additional actions on each beat
    sb.on_beat do
      # notify graphite, statsd, WHATEVER
    end
    
    # #beat_attributes allows you to define other key value pairs to store on 
    # each beat.  By default it just sends the 'hostname' and 'timestamp'.
    sb.beat_attributes do
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

    # => { ip_address => attributes }
    SimpleBeat.recent_beats(threshold = 300)


    # Prune heartbeats old than seconds 'threshold'
    SimpleBeat.prune_beats(threshold = 300)

    # Have we recieved a heartbeat from 'hostname' in the last 'threshold' seconds
    SimpleBeat.alive?(hostname, threshold = 120)

    SimpleBeat.last_beat(hostname)


## Redis storage

    Heartbeats are stored in a hash with the hostname as the key and attributes as the value

    redis.hset(simple_beat_hash, hostname, attributes)
