require 'ipaddress'
require 'uri'
require 'net/http'
require 'json'

DEFAULTS = { ip: '127.0.0.1', port: '9988', user: 'test', pwd: 'test' }

class Client
  def initialize(service_url, user, pwd)
    @uri = URI(service_url)
    @user, @pwd = user, pwd
    raise ArgumentError, 'bad ip address' unless IPAddress.valid? @uri.host
  end

  def method_missing(name, *args)
    post_body = {method: name, params: args, jsonrpc: '2.0', id: 0 }.to_json
    resp = JSON.parse(rpcexec(post_body))
    raise JSONRPCError, resp['error'] if resp['error']
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
