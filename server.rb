require 'socket'
tcp_server = TCPServer.new(9292)
client = tcp_server.accept

puts "Ready for a request"
request_lines = []
while line = client.gets and !line.chomp.empty?
  request_lines << line.chomp
end

puts "Got this request:"
puts request_lines.inspect
print "\n"

d = {}	#hash containing request diagnostic info

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
	when '/hello'
		puts '/hello detected'
	when '/datetime'
		puts '/datetime detected'
	when '/shutdown'
		puts '/shutdown detected'
	else
		puts "#{d['Path']} is an unknown command"
end

#output diagnostic info
print "\n*********** DEBUG INFO ************\n"
d.each{|key,val| 
	puts "#{key}: #{val}"
}

client.close

=begin
puts "Sending response."
response = "<pre>" + request_lines.join("\n") + "</pre>"
output = "<html><head></head><body>#{response}</body></html>"
headers = ["http/1.1 200 ok",
          "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
          "server: ruby",
          "content-type: text/html; charset=iso-8859-1",
          "content-length: #{output.length}\r\n\r\n"].join("\r\n")
client.puts headers
client.puts output

puts ["Wrote this response:", headers, output].join("\n")
client.close
puts "\nResponse complete, exiting."
=end
