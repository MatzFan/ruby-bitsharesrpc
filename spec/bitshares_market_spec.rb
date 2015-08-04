require 'bitshares_market'

describe BitsharesMarket do

  let(:market) { BitsharesMarket.new }

  context '#client' do
    it 'returns a BitsharesRPC instance' do
      expect(market.client.class.to_s).to eq 'BitsharesRPC'
    end
  end

  context '#get_asset_id(symbol)' do
    it 'returns the id of the asset provided as parameter' do
      expect(market.get_asset_id('BTS')).to eq 0
    end

    it 'raises BitsharesMarket "No such asset: <symbol>" for an invalid asset symbol' do
      expect(->{market.get_asset_id('no_such_asset')}).to raise_error BitsharesMarket::AssetError, 'No such asset: no_such_asset'
    end
  end

  context '#get_precision(symbol)' do
    it 'returns the precision of the asset provided as parameter' do
      expect(market.get_precision('BITUSD')).to eq 100
    end
  end

  context '#get_center_price(quote, base)' do
    it 'returns the mid price of the quote relative to the base' do
      expect(market.get_center_price('BTC', 'BTS')).to eq 0.0000000000
    end
  end

  context '#get_lowest_ask(asset1, asset2)' do
    it 'returns lowest ask price of the quote relative to the base from order book' do
      ask_prices = market.send(:asks, 'BTC', 'BTS').map { |p| p['market_index']['order_price']['ratio'].to_f }.sort
      expect(market.get_lowest_ask('BTC', 'BTS')).to eq ask_prices.first
    end
  end

  context '#get_highest_bid(asset1, asset2)' do
    it 'returns highest bid price of the quote relative to the base from order book' do
      bid_prices = market.send(:bids, 'BTC', 'BTS').map { |p| p['market_index']['order_price']['ratio'].to_f }.sort
      expect(market.get_highest_bid('BTC', 'BTS')).to eq bid_prices.last
    end
  end

end
