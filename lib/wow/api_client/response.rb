require 'rest-client'

# Module supposed to extend the RestClient response to add helper methods.
module Wow::ApiClient::Response
  # Parse the response body of a rest client
  # Should extend the response object of a RestClient request
  # e.g.
  # ```
  # result = RestClient.get('http://example.com/some.json')
  # result.extend Wow::ApiClient::Response
  # result.data
  # > Hash {...}
  # ```
  def data
    @data ||= JSON.parse(body, symbolize_names: true)
  end
end
