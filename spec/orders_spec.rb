require 'orders'
require 'client'
require 'market'

describe BitShares::Orders do

  client = BitShares::Client.new
  bad_market = BitShares::Market.new('TESTME', 'BTS')
  let(:bad_market_orders) { BitShares::Orders.new(client, bad_market) }
  market = BitShares::Market.new('TESTME', 'BTS')
  let(:orders) { BitShares::Orders.new(client, market) }

  context '#client' do
    it 'returns a Client instance' do
      expect(orders.client.class).to eq BitShares::Client
    end
  end

  context '#market' do
    it 'returns a Market instance' do
      expect(orders.market.class).to eq BitShares::Market
    end
  end

  context '#all' do
    it 'returns all open orders' do
      expect(orders.all).to eq []
    end
  end

end
