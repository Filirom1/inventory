# Inventory::Server  [![Build Status](https://travis-ci.org/Filirom1/inventory.svg?branch=master)](https://travis-ci.org/Filirom1/inventory) [![Code Climate](https://codeclimate.com/github/Filirom1/inventory/badges/gpa.svg)](https://codeclimate.com/github/Filirom1/inventory) [![Test Coverage](https://codeclimate.com/github/Filirom1/inventory/badges/coverage.svg)](https://codeclimate.com/github/Filirom1/inventory)

Inventory is an HTTP and SMTP Server that process and index facts produced by facter.

## Installation, the Docker way

    $ git clone https://github.com/Filirom1/inventory.git
    $ cd inventory
    $ fig up -d

## Installation, the hard way

Install ElasticSearch, Kibana, ruby >=1.9 and bundler

    $ git clone https://github.com/Filirom1/inventory.git
	$ cd inventory
	$ bundle install
	$ bundle exec rackup                # to start the HTTP Server
	$ bundle exec bin/inventory-smtpd   # to start the SMTP Server

## Usage

Send facts by HTTP:

```
$ facter --json | curl -d @- localhost:9292/api/v1/facts/`hostname`
2015-03-01 19:03:39 +0100 t-4864360    [dahu  ] INFO  | facts_parser.rb:20       | Facts parser
2015-03-01 19:03:39 +0100 t-4864360    [dahu  ] INFO  | json_schema_valid...:14  | JSON Schema Validator
2015-03-01 19:03:39 +0100 t-4864360    [dahu  ] INFO  | json_schema_valid...:24  | No JSON Schema found at /etc/inventory/json_schema/facts/1-0-0.json, skip validation
2015-03-01 19:03:39 +0100 t-4864360    [dahu  ] INFO  | index.rb:23              | Index
2015-03-01 19:03:39 +0100 t-4864360    [dahu  ] INFO  | index.rb:38              | {"_index":"inventory_facts","_type":"1-0-0","_id":"dahu","_version":2,"created":false}
2015-03-01 19:03:39 +0100 t-4864360    [dahu  ] INFO  | http_server.rb:16        | 127.0.0.1 - - [01/Mar/2015 19:03:39] "POST /api/v1/facts/dahu HTTP/1.1" 200 36 0.0383

127.0.0.1 - - [01/Mar/2015 19:03:39] "POST /api/v1/facts/dahu HTTP/1.1" 200 36 0.0390
{"id":"dahu","ok":true,"status":200}
```

Or send facts by Email:

```
facter --json | mail -s `hostname` inventory@localdomain
2015-03-01 19:43:35 +0100 t-70045727140840 [      ] INFO  | email_parser.rb:9        | Email parser
2015-03-01 19:43:35 +0100 t-70045727140840 [dahu  ] INFO  | facts_parser.rb:20       | Facts parser
2015-03-01 19:43:35 +0100 t-70045727140840 [dahu  ] INFO  | json_schema_valid...:14  | JSON Schema Validator
2015-03-01 19:43:35 +0100 t-70045727140840 [dahu  ] INFO  | json_schema_valid...:24  | No JSON Schema found at /etc/inventory/json_schema/facts/1-0-0.json, skip validation
2015-03-01 19:43:35 +0100 t-70045727140840 [dahu  ] INFO  | index.rb:23              | Index
2015-03-01 19:43:35 +0100 t-70045727140840 [dahu  ] INFO  | index.rb:38              | {"_index":"inventory_facts","_type":"1-0-0","_id":"dahu","_version":6,"created":false}
```

## Plugins

Inventory is built with plugins in mind. The default plugins could be found in the `plugins` dir. The default execution order is this one: `log_failures_on_disk`,`facts_parser`,`json_schema_validator`,`index`

To add/remove plugins or change the order, you have to change 2 configurations options (see configurations options below)

* `plugins_path`
* `plugins`

You could create your own plugin, copy the example `plugins/sample.rb` to start.

### log_failures_on_disk

If an error is raised during the processing, the received facts will be stored in the file `failed_facts_dir`/$ID and the error message, stacktrace and context will be written to `failed_facts_dir`/$ID.log

### facts_parser

Transform JSON, YAML, XML and XML with `__base64__` into a ruby hash

### json_schema_validator

Check if the received facts are compliant with the JSON Schema in `json_schema_dir`/$TYPE/$VERSION.json

### index

Index the received facts in ElasticSearch

## Configuration

Configuration options could be set via environment variables. Each option should be prefixed with `INVENTORY_`. For exemple: `export INVENTORY_LOG_LEVEL=ERROR`

Configurations could also be defined in a YAML file: `/etc/inventory/inventory.yml`

The following options are configurable:

* `host` (default: '127.0.0.1'): SMTP host to bind on
* `smtp_port` (default: 2525): SMTP port
* `max_connections` (default: 4): SMTP maximum number of simultaneus allowed connexions
* `es_host` (default: 'http`//localhost`9200'): ElasticSearch URL
* `es_index_prefix` (default: 'inventory_'): ElasticSearch index prefix 
* `failed_facts_dir` (default: '/var/log/inventory/failures'): Dir where failed facts will be written to
* `logger` (default: 'stdout'): stout/stderr or file for log destination
* `log_level` (default: 'INFO'): DEBUG/INFO/WARN/ERROR
* `debug` (default: false): Show more details, need log_level on DEBUG
* `type_key` (default: 'type'): Facts key that will be used as a type
* `type_default` (default: 'facts'): Default type if `type_key` not found in facts
* `version_key` (default: 'version'): Facts key that wll be used as a version
* `version_default` (default: '1-0-0'): Default version if not `version_key` found
* `json_schema_dir` (default: '/etc/inventory/json_schema'): directory containing JSON Schema
* `plugins_path` (default: ''): a directory containing middlewares.
* `plugins` (default: `log_failures_on_disk,facts_parser,json_schema_validator,index`): a comma separated list of plugins that will be executed in order.

## Contributing

1. Fork it ( https://github.com/Filirom1/inventory-server/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
