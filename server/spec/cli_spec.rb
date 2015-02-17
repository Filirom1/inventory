require 'inventory/server/cli'

RSpec.describe Inventory::Server::CLI do
  before do
    $stdout = StringIO.new
  end
  after(:all) do
    $stdout = STDOUT
  end

  it "should print usage on -h" do
    expect {
      Inventory::Server::CLI.new().parse! ['-h']
    }.to raise_error SystemExit
    expect($stdout.string).to match(/Usage/)
  end

  it "should print version on -v" do
    expect {
      Inventory::Server::CLI.new().parse! ['-v']
    }.to raise_error SystemExit
    expect($stdout.string).to match(/\d\.\d\.\d/)
  end

  it "should set host on --host" do
    options = Inventory::Server::CLI.new().parse! ['--host', '0.0.0.0']
    expect(options[:host]).to eq '0.0.0.0'
  end

  it "should set smtp port on --smtp_port" do
    options = Inventory::Server::CLI.new().parse! ['--smtp_port', '25']
    expect(options[:smtp_port]).to eq 25
  end

  it "should set ElasticSearch host on --es_host" do
    options = Inventory::Server::CLI.new().parse! ['--es_host', 'http://localhost:9300']
    expect(options[:es_host]).to eq 'http://localhost:9300'
  end

  it "should set logger on -o" do
    options = Inventory::Server::CLI.new().parse! ['-o', '/dev/null']
    expect(options[:logger]).to eq '/dev/null'
  end

  it "should set log level on -l" do
    options = Inventory::Server::CLI.new().parse! ['-l', 'DEBUG']
    expect(options[:log_level]).to eq 'DEBUG'
  end

  it "should set debug on -d" do
    options = Inventory::Server::CLI.new().parse! ['-d']
    expect(options[:debug]).to eq true
  end
end
