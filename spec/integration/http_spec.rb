require 'rspec'
require 'rest-client'
require 'parallel'

FIXTURES_PATH = File.join File.expand_path(File.dirname(__FILE__)), 'fixtures'
XML_STR = File.read(File.join FIXTURES_PATH, 'facter.xml')

context "HTTP integration tests" do
  before(:all) do
    WebMock.allow_net_connect!
  end

  it "integrates one document", :integration => true do
    response = RestClient.post "http://localhost/api/v1/facts/MY_UUID", XML_STR
    expect(response.code).to eq 200
  end

  it "integrates 500 document", :integration => true do
    Parallel.each([*1..500], :in_threads=>20){|i| 
      response = RestClient.post "http://localhost/api/v1/facts/MY_UUID_#{i}", XML_STR
      expect(response.code).to eq 200
    }
  end
end
