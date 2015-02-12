# Inventory::Server

Inventory server store and index data sent from the agent

## Installation

Install `postfix` with the following configuration

	mydestination = $myhostname, localhost.$mydomain, localhost
	relay_domains = $mydestination
	relayhost = 127.0.0.1:2525

Install ElasticSearch

Install ruby and bundler

Then

	bundle install
	bundle exec ruby smtp_server.rb


## Usage


## Contributing

1. Fork it ( https://github.com/[my-github-username]/inventory-server/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
