require 'market'

describe BitShares::Market do

  let(:market) { BitShares::Market.new('BTC', 'BTS') }

  context '#new(quote, base)' do
    it 'raises AssetError "No such asset: <symbol(s)>" if an invalid asset symbol is used' do
      expect(->{BitShares::Market.new('BTC', 'GARBAGE')}).to raise_error BitShares::Market::AssetError, 'No such asset: GARBAGE'
    end

    it 'instantiates an instance of the class with valid asset symbols (case insensitive)' do
      expect(BitShares::Market.new('BTC', 'btS').class).to eq BitShares::Market
    end
  end

  context '#client' do
    it 'returns a BitsharesClient instance' do
      expect(market.client.class).to eq BitShares::Client
    end
  end

  context '#quote' do
    it 'returns the quote asset symbol' do
      expect(market.quote).to eq 'BTC'
    end
  end

  context '#base' do
    it 'returns the base asset symbol' do
      expect(market.base).to eq 'BTS'
    end
  end

  context '#center_price' do
    it 'returns the center price' do
      expect(market.center_price).to eq 0
    end
  end

  context '#feeds_median(asset)' do
    it 'returns the median price of the asset\'s relative to BTS from price feeds' do
      median = market.feeds_median('BTC')
      expect(median > 0 && median < 1).to be_truthy
    end
  end

  context '#last_fill' do
    it 'returns -1 if there is no order history' do
      allow(market).to receive(:order_hist).and_return []
      last_fill = market.last_fill
      expect(last_fill).to eq -1
    end

    it 'returns price of the last filled order' do
      last_fill = market.last_fill
      expect(last_fill > 0 && last_fill < 1).to be_truthy
    end
  end

  context '#mid_price' do
    it 'returns the mid price' do
      mid = market.mid_price
      expect(mid > market.highest_bid && mid < market.lowest_ask).to be_truthy
    end
  end

  context '#lowest_ask' do
    it 'returns lowest ask price from order book' do
      ask_prices = market.send(:asks).map { |p| p['market_index']['order_price']['ratio'].to_f }.sort
      expect(market.lowest_ask).to eq ask_prices.first * 0.001
    end
  end

  context '#highest_bid' do
    it 'returns highest bid price from order book' do
      bid_prices = market.send(:bids).map { |p| p['market_index']['order_price']['ratio'].to_f }.sort
      expect(market.highest_bid).to eq bid_prices.last * 0.001
    end
  end

end
