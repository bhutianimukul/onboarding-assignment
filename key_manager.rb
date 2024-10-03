require "securerandom"

module ApiKeysController
  class KeyManager
    EXPIRY_TIME = 300
    ACCESSIBLE_TIME = 60
    attr_reader :key_pool

    # time after which child thread should auto release blocked keys and remove expired keys
    def initialize cleanup_time = 1
      @key_pool = Hash.new
      start_cleanup_thread cleanup_time
    end

    # E1 : Generate a new Key
    def add_key_to_pool
      key = SecureRandom.hex(16)
      @key_pool[key] = { status: :available, expiry: Time.now + EXPIRY_TIME }
      key
    end

    # E2 : Get available_key and block key
    def get_available_keys
      key_to_be_blocked, _ = @key_pool.find { |key, value| value[:status] == :available && value[:expiry] > Time.now } # O(n)
      puts " key #{key_to_be_blocked}"
      return nil unless key_to_be_blocked ## will handle 404
      block_key key_to_be_blocked
      key_to_be_blocked
    end

    private

    # Helper : Block key
    def block_key(key)
      if @key_pool[key] && @key_pool[key][:status] == :available
        @key_pool[key][:status] = :blocked
        @key_pool[key][:block_time] = Time.now
      end
    end

    public

    # E3 : unblock key
    def unblock_key(key)
      puts "Here unblocking #{key}"
      if @key_pool[key] && @key_pool[key][:status] == :blocked
        @key_pool[key][:status] = :available
        @key_pool[key][:expiry] = Time.now + EXPIRY_TIME
        @key_pool[key].delete(:block_time)
      end
    end

    # E4 : Delete key
    def purge_key(key)
      return false unless @key_pool[key]
      @key_pool.delete key
    end

    # E5 : cron which will be called every 5 min
    def keep_alive_cron(key)
      puts "here refreshing #{key}"
      return false unless @key_pool[key]
      details = @key_pool[key]
      details[:expiry] = Time.now + EXPIRY_TIME if Time.now < details[:expiry]
      true
    end

    # Helper Child thread that will auto release blocked keys and cleanup expired keys
    private

    def start_cleanup_thread cleanup_time
      Thread.new do
        loop do
          auto_release_blocked_keys
          cleanup_expired_keys
          sleep cleanup_time
        end
      end
    end

    def cleanup_expired_keys
      @key_pool.delete_if { |_, data| data[:expiry] <= Time.now }
    end

    def auto_release_blocked_keys
      @key_pool.each do |key, data|
        if data[:status] == :blocked && Time.now - data[:block_time] > ACCESSIBLE_TIME
          unblock_key key
        end
      end
    end

    # obj = KeyManager.new
    # obj.add_key_to_pool
    # # obj.get_available_keys
    # puts obj.key_pool
    # obj.get_available_keys
    # # obj.add_key_to_pool
    # # obj.auto_release_blocked_keys
    # # obj.cleanup_expired_keys
    # puts obj.key_pool
    # i =0
    # while true
    #   puts obj.key_pool
    #   sleep 1
    #   obj.get_available_keys if i ==5
    #   i += 1
    # end
  end
end
