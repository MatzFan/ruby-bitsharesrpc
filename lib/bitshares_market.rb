require 'bitshares_rpc'

class BitsharesMarket

  ASK_ORDER_TYPES = %w(ask_order cover_order)
  BID_ORDER_TYPES = %w(bid_order)

  attr_reader :client

  def initialize
    @client = BitsharesRPC.new
  end

  def get_asset_id(sym)
    get_asset(sym)['id']
  end

  def get_precision(sym)
    get_asset(sym)['precision']
  end

  def get_center_price(quote, base)
    [quote, base].each { |sym| get_asset(sym) }
    client.blockchain_market_status(quote, base)['center_price']['ratio'].to_f
  end

  def get_lowest_ask(a1, a2)
    asks(a1, a2).first['market_index']['order_price']['ratio'].to_f
  end

  def get_highest_bid(a1, a2)
    bids(a1, a2).first['market_index']['order_price']['ratio'].to_f
  end

  private

  def get_asset(s)
    client.blockchain_get_asset(s) || (raise AssetError, "No such asset: #{s}")
  end

  def check_new_order_type(order_list, order_types)
    new_ = order_list.reject { |p| order_types.any? { |t| p['type'] == t } }
    raise AssetError, "New order type: #{new_.first}" unless new_.empty?
    order_list
  end

  def bids(a1, a2)
    bids = client.blockchain_market_order_book(a1, a2).first
    check_new_order_type(bids, BID_ORDER_TYPES)
  end

  def all_asks(a1, a2) # includes 'ask_type' and 'cover_type'
    asks = client.blockchain_market_order_book(a1, a2).last
    check_new_order_type(asks, ASK_ORDER_TYPES)
  end

  def asks(a1, a2)
    all_asks(a1, a2).select { |p| p['type'] == 'ask_order' }
  end

  def covers(a1, a2)
    all_asks(a1, a2).select { |p| p['type'] == 'cover_order' }
  end

  class AssetError < RuntimeError; end
end
