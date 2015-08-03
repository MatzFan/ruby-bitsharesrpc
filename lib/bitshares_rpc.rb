require 'uri'
require 'json'

class BitsharesRPC

  PATTERN = 'bitshares.*localhost.*LISTEN'
  PAYLOAD = {method: nil, params: nil, jsonrpc: '2.0', id: 0}

  def initialize
    bitshares_running?
    @uri = URI "http://127.0.0.1:#{rpc_http_port}/rpc"
    @usr = ENV['BITSHARES_USER']
    @pwd = ENV['BITSHARES_PWD']
  end

  def synced?
    get_info['blockchain_head_block_num'] == blockchain_get_block_count
  end

  def unlock(opts = {})
    defaults = {timeout: 1776, wallet: 'default'}
    args = opts.merge defaults
    params = [args[:timeout], @pwd, 'o', args[:wallet]] # 'o' is 'open'
    rpcexec(PAYLOAD.merge({method: 'wallet_unlock', params: params}).to_json)
  end

  private

  def bitshares_running?
    raise BitsharesError, 'Server not running!' unless rpc_ports.count == 2
  end

  def rpc_http_port
    rpc_ports.each do |port| # only http RPC port raises a non-empty response
      return port unless `curl -s -I -L http://127.0.0.1:#{port}`.empty?
    end
  end

  def rpc_ports # returns bitshares HTTP JSON RPC and JSON RPC server ports
    `lsof -i -P | egrep #{PATTERN} | awk -F"[:(]" '{print $2}'`.split(" \n")
  end

  def method_missing(name, *args)
    post_body = PAYLOAD.merge({method: name, params: args}).to_json
    data = JSON.parse(rpcexec post_body)
    raise JSONRPCError, "Invalid command: #{name}" if data['error']
    data['result']
  end

  def rpcexec(payload)
    http = Net::HTTP.new(@uri.host, @uri.port)
    req = Net::HTTP::Post.new(@uri)
    req.basic_auth @usr, @pwd
    req.content_type = 'application/json'
    req.body = payload
    resp = http.request(req)
    raise UnauthorizedError, "#{@user}#{@pwd}" if resp.class == Net::HTTPUnauthorized
    resp.body
  end

  class BitsharesError < RuntimeError; end
  class JSONRPCError < RuntimeError; end
  class UnauthorizedError < RuntimeError; end
end
