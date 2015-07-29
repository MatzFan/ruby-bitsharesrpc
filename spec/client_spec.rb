require 'client'

describe Client do

  let(:uri_no_port) { 'http://127.0.0.1:9988/rpc' }
  let(:uri) { 'http://127.0.0.1:9988/rpc' }
  let(:user) { 'a-user' }
  let(:pwd) { 'a password' }
  let(:rpc) { Client.new(uri, ENV['BITSHARES_USER'], ENV['BITSHARES_PWD']) }

  context '#new' do
    it 'can be instantiated without a port specified valid parameters' do
      expect(->{Client.new(uri_no_port, user, pwd)}).not_to raise_error
    end

     it 'can be instantiated with a port specified valid parameters' do
      expect(->{Client.new(uri, user, pwd)}).not_to raise_error
    end

    it 'raises an error if provided with a bad ip address' do
      expect(->{Client.new('//// bad url')}).to raise_error
    end
  end

  context 'valid methods' do
    it 'returns data' do
      expect(rpc.get_info.to_s).to include('blockchain_head')
    end
  end

end
