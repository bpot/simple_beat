module SimpleBeat
  class Beat
    def beat
      SimpleBeat.data_store.record_beat(attributes)
      @on_beat.call if @on_beat
    end

    def on_beat(&block)
      @on_beat = block
    end

    def additional_attributes(&block)
      @additional_attributes_proc = block
    end

    def attributes
      if @additional_attributes_proc
        attributes = @additional_attributes_proc.call
      else
        attributes = {}
      end
      attributes['timestamp'] = Time.now.to_i
      attributes
    end

    def run_beat_thread(period = 60)
      if @beat_thread
        raise "Beat thread already running!"
      end

      @beat_thread = Thread.new {
        begin
          loop do
            beat

            sleep(period)
          end
        rescue Exception
        end
      }
    end

    def stop_beat_thread
      @beat_thread.kill
      @beat_thread = nil
    end
  end
end
