require 'socket'

#Constants
STATUS_OK = '200 OK'
STATUS_MOVED = '301 Moved Permanently'
STATUS_UNAUTH = '401 Unauthorized'
STATUS_FORB = '403 Forbidden'
STATUS_NOTFOUND = '404 Not Found'
STATUS_ERROR = '500 Internal Server Error'

#Helper methods
def response(client,msg,status=STATUS_OK)
  time = Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')
  puts "Sending response."
  response = "<pre>" + msg.to_s + "</pre>"
  output = "<html><head></head><body>#{response}</body></html>"
  headers = ["http/1.1 #{status}",
    "date: #{time}",
    "server: ruby",
    "content-type: text/html; charset=iso-8859-1",
    "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    client.puts headers
    client.puts output

    puts ["Wrote this response:", headers, output].join("\n")
  end

#Main code
tcp_server = TCPServer.new(9292)
client = tcp_server.accept
counter = 0

loop do
  counter += 1
  d = {}  #hash containing request diagnostic info

  puts "Ready for a request"
  request_lines = []
  while line = client.gets and !line.chomp.empty?
    request_lines << line.chomp
  end

  puts "Got this request:"
  puts request_lines.inspect
  print "\n"
  
  #put request into hash 'd'
  request_lines.each.with_index{ |req,index| 
    #print index, " ", req, "\n" 
    if index == 0
      (d['Verb'], d['Path'], d['Protocol']) = req.split
    else
      line_elements = req.split(':')
      d[line_elements[0].strip] = line_elements[1].strip
    end
  }

  #process request
  case d['Path']
  when '/'
    puts '/ detected'
    response(client,'/ detected')
  when '/hello'
    puts '/hello detected'
      #response(client, '/hello detected')
      response(client, "Hello World #{counter}")
    when '/datetime'
      puts '/datetime detected'
      response(client, Time.now.strftime('%a, %e %b %Y %H:%M:%S %z'))
    when '/shutdown'
      puts '/shutdown detected'
      response(client, '/shutdown detected')
      client.close
      exit
    else
      puts "#{d['Path']} is an unknown command"
      response(client, "unknown command, #{d['Path']} detected",STATUS_NOTFOUND)
    end

  #output diagnostic info
  print "\n*********** DEBUG INFO ************\n"
  d.each{|key,val| 
    puts "#{key}: #{val}"
  }


end
client.close