require 'client'

describe Client do

  let(:client) { Client.new }

  context '#new' do
    it 'instantiates an instance of the class' do
      expect(client.class).to eq Client
    end
  end

  context '#rpc_ports' do
    it 'returns both port numbers used by the RPC server' do
      ports = client.send :rpc_ports
      expect(->{ports.each &:to_i}).not_to raise_error
      expect(ports.count).to eq 2
    end
  end

  context '#rpc_http_port' do
    it 'returns the port used by the HTTP JSON RPC server' do
      expect(client.send :rpc_http_port).to match /\d/
    end
  end

  context 'valid methods' do
    it 'returns data' do
      expect(client.get_info.to_s).to include('blockchain_head')
    end
  end

  context 'invalid methods' do
    it 'raise an error "Invalid command: <command name>" ' do
      expect(->{client.not_a_cmd}).to raise_error(Client::JSONRPCError, 'Invalid command: not_a_cmd')
    end
  end

end
