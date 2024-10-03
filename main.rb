require "./server.rb"
server = Server::KeyServer.new(8000)
server.start
