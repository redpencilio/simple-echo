require 'net/http'

raise "environment variable ECHO_FROM_NAME must be set" if ENV["ECHO_FROM_NAME"].nil? || ENV["ECHO_FROM_NAME"] == ""

get "/" do
  %(<form method="POST" action="/send-ping"><input type="text" placeholder="hostname" name="hostname"/><button type="submit">ping</button></form>)
end

post "/send-ping" do
  log.info "I will now ping #{params[:hostname]} for you"
  r = Net::HTTP::Post.new('/ping')
  r.body = ENV["ECHO_FROM_NAME"]
  response = Net::HTTP.new(params[:hostname], 80).start{ |http| http.request(r) }
  "#{params[:hostname]} responds: #{response.body}"
end

post "/ping" do
  request.body.rewind
  ping_received_from = request.body.read.strip
  log.info "I have received a ping from #{ping_received_from} with ip address #{request.ip}"
  "Hello #{ping_received_from}, your ping was received by #{ENV["ECHO_FROM_NAME"]}. I see your ip address is #{request.ip}"
end
