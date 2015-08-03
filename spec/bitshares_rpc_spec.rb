require 'bitshares_rpc'

abort 'bitshares client not running!' if `pgrep bitshares_clien`.empty? # 15 ch

describe BitsharesRPC do

  let(:client) { BitsharesRPC.new }

  context '#new' do
    it 'raises BitsharesError "Server not running!" if the server isn\'t running' do
      allow(client).to receive(:rpc_ports).and_return []
      expect(->{client.send :bitshares_running?}).to raise_error BitsharesRPC::BitsharesError, 'Server not running!'
    end

    it 'instantiates an instance of the class if the bitshares server is running' do
      expect(client.class).to eq BitsharesRPC
    end
  end

  context '#synced?' do
    it 'returns false if client is not synced with the network' do
      c = client
      head = c.get_info['blockchain_head_block_num']
      allow(c).to receive(:blockchain_get_block_count).and_return(head -1)
      expect(c.synced?).to be_falsy
    end

    it 'returns true if client is synced with the network' do
      c = client
      head = c.get_info['blockchain_head_block_num']
      allow(c).to receive(:blockchain_get_block_count).and_return head
      expect(c.synced?).to be_truthy
    end
  end

  context '#unlock' do
    it 'with no args unlocks "default" wallet for default time' do
      c = client
      c.unlock
      expect(c.wallet_get_info['unlocked']).to eq true
    end

    it 'with :timeout option unlocks "default" wallet for given time (seconds)' do
      c = client
      c.unlock timeout: 1
      sleep 1
      expect(c.wallet_get_info['unlocked']).to eq true
    end

    it 'with :wallet option unlocks the named wallet' do
      c = client
      c.unlock wallet: 'default'
      expect(c.wallet_get_info['unlocked']).to eq true
    end
  end

  context 'valid client commands' do
    it 'raises UnauthorizedError with incorrect username' do
      stub_const('ENV', ENV.to_hash.merge('BITSHARES_USER' => 'wrong_password'))
      expect(->{client.get_info}).to raise_error BitsharesRPC::UnauthorizedError
    end

    it 'raise UnauthorizedError with incorrect password' do
      stub_const('ENV', ENV.to_hash.merge('BITSHARES_PWD' => 'wrong_password'))
      expect(->{client.get_info}).to raise_error BitsharesRPC::UnauthorizedError
    end

    it 'with valid credentials returns a Hash of JSON data ' do
      expect(client.get_info.class).to eq Hash
    end
  end

  context 'invalid client commands' do
    it 'raise JSONRPCError "Invalid command: <command name>" ' do
      expect(->{client.not_a_cmd}).to raise_error(BitsharesRPC::JSONRPCError, 'Invalid command: not_a_cmd')
    end
  end

end
