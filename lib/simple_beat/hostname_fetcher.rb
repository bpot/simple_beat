require 'socket'

module SimpleBeat
  class HostnameFetcher
    def self.hostname
      Socket.gethostname
    end
  end
end
