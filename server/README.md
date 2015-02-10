Install `postfix` with the following configuration

	mydestination = $myhostname, localhost.$mydomain, localhost
	relay_domains = $mydestination
	relayhost = 127.0.0.1:2525

Install ElasticSearch

Install ruby and bundler

Then

	bundle install
	bundle exec ruby smtp_server.rb
