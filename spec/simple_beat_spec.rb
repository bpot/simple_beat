require 'spec_helper'

describe "simple_beat" do
  let(:hostname) { "127.0.0.1" }
  let(:pid) { "123" }
  let(:identifier) { [hostname,pid].join(":") }

  before(:each) do
    SimpleBeat.stub(:identifier) { identifier }

    SimpleBeat.redis = Redis.new
    SimpleBeat.namespace = "test"
    SimpleBeat.reset!
  end

  describe "simple" do
    it "knows that hosts which have never beat are dead" do
      SimpleBeat.alive?(identifier).should == false
    end

    it "knows that beating hosts are alive" do
      beat = SimpleBeat::Beat.new
      beat.beat
      
      SimpleBeat.alive?(identifier).should == true
    end

    it "knows that hosts which beat longer than threshold ago are dead" do
      beat = SimpleBeat::Beat.new
      beat.beat

      current_time = Time.now
      Time.stub(:now) { current_time + 600 }
      SimpleBeat.alive?(identifier).should == false
    end
  end

  describe "recent beats" do
    it "returns hosts that beat recently" do
      beat = SimpleBeat::Beat.new
      beat.beat

      SimpleBeat.recent_beats.has_key?(identifier).should == true
    end

    it "ignore hosts that haven't beat recently" do
      beat = SimpleBeat::Beat.new
      beat.beat

      current_time = Time.now
      Time.stub(:now) { current_time + 600 }
      SimpleBeat.recent_beats.has_key?(identifier).should == false
    end
  end

  describe "pruning beats" do
    it "removes beats older than threshold" do
      beat = SimpleBeat::Beat.new
      beat.beat

      current_time = Time.now
      Time.stub(:now) { current_time + 600 }

      SimpleBeat.prune_beats(120)
      SimpleBeat.alive?(identifier, 7200).should == false
    end
  end

  describe "last beat" do
    it "returns the last time we got a beat from the host" do
      Time.stub(:now) { 1 }

      beat = SimpleBeat::Beat.new
      beat.beat

      SimpleBeat.last_beat(identifier).should == 1
    end
  end

  describe "additional beat attributes" do
    it "should record additional attributes" do
      beat = SimpleBeat::Beat.new
      beat.additional_attributes do
        { 'revision' => "abc" }
      end

      beat.beat
      SimpleBeat.recent_beats[identifier]['revision'].should == "abc"
    end
  end

  describe "on beat" do
    it "calls the on beat block" do
      graphite = double('graphite')
      graphite.should_receive(:push)

      beat = SimpleBeat::Beat.new
      beat.on_beat do
        graphite.push
      end

      beat.beat
    end
  end

  describe "beat thread" do
    it "should beat every 'period' seconds" do
      beats = []

      beat = SimpleBeat::Beat.new
      beat.on_beat do
        beats << Time.now.to_i
      end
      start = Time.now.to_i
      beat.run_beat_thread(5)

      sleep 21
      beats.size.should == 5

      beat.stop_beat_thread
      beats.clear

      sleep 21
      beats.should be_empty
    end
  end
end
