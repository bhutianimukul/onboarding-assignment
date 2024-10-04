require "socket"
require "./key_manager_v2.rb"
require "./routes.rb"
require "json"
require 'logger'

module Server
  class KeyServer
    def initialize(port)
      @server = TCPServer.new(port)
      @controller = ApiKeysControllerV2::KeyManagerV2.new
      @router = Routes::Router.new
      @logger = Logger.new(STDOUT)
      @logger.info "Server is running on port #{port}"
    end

    def start
      loop do
        client = @server.accept
        request_lines = []
        while (line = client.gets) && !line.chomp.empty?
          request_lines << line.chomp
        end
        next if request_lines.empty?
        method, path, headers, body = parse_request(request_lines, client)
        @logger.debug "Server Hit #{path} #{method}"
        action = @router.route(method, path)
        serve_content(action, client, headers, body)
        client.close
      end
    end

    private

    def parse_request(request_lines, client)
      headers = {}
      request_line = request_lines[0]
      method, path, _ = request_line.split(" ", 3)

      headers = {}

      request_lines[1..-1].each do |line|
        key, value = line.split(": ", 2)
        headers[key] = value.strip if key && value
      end

      body = ""
      if headers["Content-Length"]
        content_length = headers["Content-Length"].to_i
        body = client.read(content_length) if content_length > 0
      end

      parsed_body = body.empty? ? {} : JSON.parse(body) rescue {}

      [method, path, headers, parsed_body]
    end

    def serve_content(action, client, headers, body)
      begin
        status, resp = @controller.send(action, headers, body)
        case status
        when :ok
          send_response(client, 200, resp)
        when :not_found
          send_response(client, 404, { error: resp })
        when :server_error
          send_response(client, 500, { error: resp })
        end
      rescue StandardError => _
        if action == :method_not_allowed
          send_response(client, 404, "Not Found")
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
