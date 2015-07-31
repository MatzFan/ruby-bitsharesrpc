require 'uri'
require 'json'

PATTERN = 'bitshares.*localhost.*LISTEN'

class Client

  def initialize
    @uri = URI "http://127.0.0.1:#{rpc_http_port}/rpc"
    @user = ENV['BITSHARES_USER'].strip
    @pwd = ENV['BITSHARES_PWD'].strip
  end

  private

  def rpc_http_port
    rpc_ports.each do |port|
      return port unless `curl -s -I -L http://127.0.0.1:#{port}`.empty?
    end
  end

  def rpc_ports
    `lsof -i -P|egrep #{PATTERN} | awk -F"[:(]" '{print $2}'`.split(" \n")
  end

  def method_missing(name, *args)
    post_body = {method: name, params: args, jsonrpc: '2.0', id: 0 }.to_json
    resp = JSON.parse(rpcexec post_body)
    raise JSONRPCError, "Invalid command: #{name}" if resp['error']
    resp['result']
  end

  def rpcexec(payload)
    http = Net::HTTP.new(@uri.host, @uri.port)
    req = Net::HTTP::Post.new(@uri)
    req.basic_auth @user, @pwd
    req.content_type = 'application/json'
    req.body = payload
    http.request(req).body
  end

  class JSONRPCError < RuntimeError; end
end
