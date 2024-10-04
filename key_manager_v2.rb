require "securerandom"
require "algorithms"

module ApiKeysControllerV2
  class KeyManagerV2
    EXPIRY_TIME = 300
    ACCESSIBLE_TIME = 60
    attr_reader :key_pool, :available_keys, :blocked_keys, :expiry_time, :blocked_keys_map, :expiry_time_map 

    # time after which child thread should auto release blocked keys and remove expired keys
    def initialize(cleanup_time = 1)
      @key_pool = Hash.new
      @available_keys = Set.new
      @blocked_keys, @expiry_time = Containers::MinHeap.new, Containers::MinHeap.new
      @blocked_keys_map, @expiry_time_map = Hash.new, Hash.new  ## To store the values, to delete from heap in O(log n)
      start_cleanup_thread cleanup_time #auto restore blocked and remove expired keys
    end

    # E1 : Generate a new Key
    def add_key_to_pool(headers = Hash.new, body = Hash.new, key = SecureRandom.hex(16))
      expiry_time = Time.now + EXPIRY_TIME
      @key_pool[key] = expiry_time
      @available_keys.add(key)
      map_element = [expiry_time, key]
      @expiry_time.push(map_element)
      @expiry_time_map[key] = map_element
      [:ok, { key: key, expiry_time: expiry_time }]
    end

    # E2 : Get available_key and block key
    def get_available_keys(headers = Hash.new, body = Hash.new)
      return [:not_found, "Unable to get any key from the key pool"] if @available_keys.empty? ## will handle 404
      key_to_be_blocked = @available_keys.first
      block_key key_to_be_blocked
    end

    private

    # Helper : Block key
    def block_key(key)
      return [:not_found, "Unable to get any key from the available key"] unless @key_pool[key] && @available_keys.include?(key)
      @available_keys.delete(key)
      map_element = [Time.now, key]
      @blocked_keys.push(map_element)
      @blocked_keys_map[key] = map_element
      [:ok, ({ key: key, unblock_time: Time.now + ACCESSIBLE_TIME })]
    end

    public

    # E3 : unblock key
    def unblock_key(headers = Hash.new, body = Hash.new)
      return [:not_found, "Unable to get key to be blocked"] if body["key"].nil?
      key = body["key"]
      puts "Unblocking Key : #{key}"
      return [:not_found, "Key not found"] unless @key_pool[key]
      add_key_to_pool(headers, body, key)
      @blocked_keys.delete(@blocked_keys_map[key])
      @blocked_keys_map.delete(key)
      [:ok, "SUCCESS"]
    end

    # E4 : Delete key
    def purge_key(headers = Hash.new, body = Hash.new)
      return [:not_found, "Unable to get key to be blocked"] if body["key"].nil?
      key = body["key"]
      return [:not_found, "Key not found"] unless @key_pool[key]
      @key_pool.delete(key)
      @available_keys.delete(key)
      [:ok, "SUCCESS"]
    end

    # E5 : cron which will be called every 5 min
    def keep_alive_cron(headers = Hash.new, body = Hash.new)
      return [:not_found, "Unable to get key to be blocked"] if body["key"].nil?
      key = body["key"]
      puts "Refreshing Key : #{key}"
      return [:not_found, "Key not found"] unless @key_pool[key]
      # new expiry time, if the key is not refreshed yet
      if Time.now < @key_pool[key]
        @key_pool[key] = Time.now + EXPIRY_TIME
        map_element = [key, @key_pool[key]]
        @expiry_time.delete(@expiry_time_map[key]) if @expiry_time_map[key] # delete if already exist
        @expiry_time_map[key] = map_element
        @expiry_time.push(map_element)
        [:ok, "SUCCESS"]
      else [:ok, "Key is Already refreshed or expired"]       end
    end

    # Helper Child thread that will auto release blocked keys and cleanup expired keys
    private

    def start_cleanup_thread(cleanup_time)
      Thread.new do
        loop do
          auto_release_blocked_keys
          cleanup_expired_keys
          sleep cleanup_time
        end
      end
    end

    def cleanup_expired_keys
      time = Time.now
      while !@expiry_time.empty? && @expiry_time.next[0] <= time
        key = @expiry_time.next[1]
        puts "Purging Key : #{key}"
        status, _ = purge_key({}, { "key" => key })
        @expiry_time.pop if status == :ok
      end
    end

    def auto_release_blocked_keys
      while !@blocked_keys.empty? && Time.now - @blocked_keys.next[0] > ACCESSIBLE_TIME
        key = @blocked_keys.next[1]
        status, _ = unblock_key({}, { "key" => key })
        @blocked_keys.pop if status == :ok
      end
    end

    public

    def key_info(header, body)
      return([:ok, {
              "keys_pool" => @key_pool, ## for debugging only
              "available_keys" => @available_keys.size,
              "blocked_keys" => @blocked_keys.size,
            }])
    end
  end
end
