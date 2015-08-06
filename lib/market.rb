require 'client'

module BitShares

  class Market

    SELL_ORDER_TYPES = %w(ask_order cover_order)
    BUY_ORDER_TYPES = %w(bid_order)

    attr_reader :client, :quote, :base

    def initialize(quote, base)
      @client = Client.new
      @quote_hash, @base_hash = *get_assets(quote.upcase, base.upcase)
      @multiplier = multiplier
      @quote = @quote_hash['symbol']
      @base = @base_hash['symbol']
      @order_book = order_book
    end

    def center_price
      market_status['center_price']['ratio'].to_f
    end

    def feeds_median(asset)
      feeds(asset).last['median_price'].to_f
    end

    def last_fill
      return -1 if order_hist.empty?
      order_hist.map.first['bid_index']['order_price']['ratio'].to_f * multiplier
    end

    def mid_price
      (highest_bid + lowest_ask) / 2
    end

    def lowest_ask
      price asks.first
    end

    def highest_bid
      price bids.first
    end

    private

    def get_assets(quote, base)
      [quote, base].map { |sym| get_asset sym }
    end

    def get_asset(s)
      client.blockchain_get_asset(s) || (raise AssetError, "No such asset: #{s}")
    end

    def multiplier
      @base_hash['precision'].to_f / @quote_hash['precision']
    end

    def market_status
      client.blockchain_market_status(@quote, @base)
    end

    def feeds(asset)
      client.blockchain_get_feeds_for_asset(asset)
    end

    def order_book
      client.blockchain_market_order_book(@quote, @base)
    end

    def order_hist
      client.blockchain_market_order_history(@quote, @base)
    end

    def check_new_order_type(order_list, order_types)
      new_ = order_list.reject { |p| order_types.any? { |t| p['type'] == t } }
      raise AssetError, "New order type: #{new_.first}" unless new_.empty?
      order_list
    end

    def buy_orders
      bids = @order_book.first
      check_new_order_type(bids, BUY_ORDER_TYPES)
    end

    def bids
      buy_orders.select { |p| p['type'] == 'bid_order' }
    end

    def sell_orders # includes 'ask_type' and 'cover_type'
      asks = @order_book.last
      check_new_order_type(asks, SELL_ORDER_TYPES)
    end

    def asks
      sell_orders.select { |p| p['type'] == 'ask_order' }
    end

    def covers
      sell_orders.select { |p| p['type'] == 'cover_order' }
    end

    def price(order) # CARE: preserve float precision with * NOT /
      order['market_index']['order_price']['ratio'].to_f * @multiplier
    end

    class AssetError < RuntimeError; end
  end

end
