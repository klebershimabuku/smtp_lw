require_relative '../../../test_helper'

describe SmtpLw::Client::Messages do

  subject { SmtpLw::Client.new }

  before do
    VCR.insert_cassette name
  end

  after do
    VCR.eject_cassette
  end

  it "find messages with required filters" do
    raw  = subject.list_messages('all', '2015-01-07', '2015-01-07', per: 10)
    assert_equal raw["data"]["messages"].count>0, true
  end

  it "will send a  message" do
    raw  = subject.send_message('hello', 'this is just a message', 'bruno.batalha@locaweb.com.br', 'rachad.honein@gmail.com')
    assert_equal raw['data']['attributes']['status'], 'Enfileirado'
  end
end

