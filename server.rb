require "socket"
require "./key_manager_v2.rb"
require "./routes.rb"
require "json"

module Server
  class KeyServer
    def initialize(port)
      @server = TCPServer.new(port)
      @controller = ApiKeysControllerV2::KeyManagerV2.new
      @router = Routes::Router.new
      puts "Server is running on port #{port}"
    end

    def start
      loop do
        client = @server.accept
        request = client.gets
        # Thread.new { handle_client(client) }
        method, path, headers, body = parse_request(request, client)
        action = @router.route(method, path)
        serve_content(action, client, headers, body)
        client.close
      end
    end

    private

    def parse_request(request, client)
      puts request
      method, path = request.split(" ")
      headers = {}
      while (line = client.gets) && !line.chomp.empty?
        key, value = line.split(": ", 2)
        headers[key] = value
      end
      body = ""
      if headers["Content-Length"]
        content_length = headers["Content-Length"].to_i
        body = client.read(content_length)
      end
      [method, path, headers, JSON.parse(body)]
    end

    def serve_content(action, client, headers, body)
      begin
        status, resp = @controller.send(action, headers, body)
        case status
        when :ok
          send_response(client, 200, { response: resp })
        when :not_found
          send_response(client, 404, { error: resp })
        when :server_error
          send_response(client, 500, { error: resp })
        end
      rescue StandardError => e
        puts "Error: #{e.message}"
        if action == :method_not_allowed
          send_response(client, 404, "")
        else
          send_response(client, 500, { error: "Internal Server Error" })
        end
      end
    end

    def send_response(client, status, body)
      json_body = body.to_json
      client.puts "HTTP/1.1 #{status}"
      client.puts "Content-Type: application/json"
      client.puts "Content-Length: #{json_body.bytesize}"
      client.puts
      client.puts json_body
    end
  end
end
