module Routes
  class Router
    def initialize
      @routes = {}
      setup_routes
    end

    def route(method, path)
      @routes.dig(method, path) || :method_not_allowed
    end

    private

    def setup_routes
      @routes = {
        "GET" => {
          "/key/info" => :key_info,
          "/key/generate" => :add_key_to_pool,
          "/key/block" => :get_available_keys,
        },
        "POST" => {
          "/key/unblock" => :unblock_key,
        },
        "DELETE" => {
          "/key/purge" => :purge_key,
        },
        "PUT" => {
          "/key/refresh" => :keep_alive_cron,
        },
      }
    end
  end
end
