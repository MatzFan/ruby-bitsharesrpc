require 'market'

module BitShares

  class Orders

    attr_reader :client, :market

    def initialize(client, market)
      @market = market
      @quote = market.quote
      @base = market.base
      @client = client
      @usr = @client.usr
      @wallet = @client.wallet
    end

    def all
      client.wallet_market_order_list(@quote, @base, 10)
    end

  end

end
