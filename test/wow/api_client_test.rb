require 'test/test_helper'
require 'wow/api_client'

class Wow::ApiClientTest < ActiveSupport::TestCase
  test 'test set current source with key is working' do
    client = Wow::ApiClient.new
    new_source = Faker::Internet.url
    client.sources = {some: new_source}
    client.current_source = :some
    assert_equal new_source, client.current_source
  end

  test 'test set current source with url is working' do
    client = Wow::ApiClient.new
    new_source = Faker::Internet.url
    client.current_source = new_source
    assert_equal new_source, client.current_source
  end
end