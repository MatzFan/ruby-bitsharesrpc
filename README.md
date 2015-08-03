# Ruby API for the BitShares client RPC interface
Exposes the commands provided by the [Bitshares client v0.x](https://github.com/bitshares/bitshares) via it's JSON RPC interface.

Requires the binary client to be installed, configured and running. The Gem detects the port the HTTP JSON RPC server is running on and expects the RPC endpoint to be `localhost` for security reasons - see [Configuration file settings](http://wiki.bitshares.org/index.php/BitShares/API).

## Requirements

_Important:_ The interface uses the commandline binary, not the GUI app.
Tested with v0.9.2 client on Mac OS X (10.9.5) but should work and any *NIX platform, not Windows (PR's welcome).

## Installation

Add this line to your application's Gemfile:

    gem 'ruby-bitsharesrpc'

Then execute:

    bundle install

Or install it yourself as:

    gem install ruby-bitsharesrpc

## Authentication

Login credentials for your BitShares account must be stored in the following environment variables:-

  $BITSHARES_USER
  $BITSHARES_PWD

## Usage

```ruby
require 'bitshares_rpc'

rpc = BitsharesRPC.new
```
Any valid rpc command can be issued via a method call with relevant parameters - e.g.

```ruby
rpc.get_info
rpc.open_wallet('default')
rpc.ask(account, amount, quote, price, base)
...
```

Data is returned as a Hash

## Testing and specification

`rspec spec --format documentation`

## Contributing

All contributions most welcome, especially Windows support, just send a PR.
