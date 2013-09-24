require File.expand_path('../test_helper', __FILE__)

begin
  require 'oauth/request_proxy/rest_client_request'
  require 'rest-client'
  
  class TyphoeusRequestProxyTest < Test::Unit::TestCase
  
    def test_that_proxy_simple_get_request_works
      request = ::RestClient::Request.new(method: :get, url: "http://example.com/test?key=value")
      request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test?key=value'})

      expected_parameters = {'key' => ['value']}
      assert_equal expected_parameters, request_proxy.parameters_for_signature
      assert_equal 'http://example.com/test', request_proxy.normalized_uri
      assert_equal 'GET', request_proxy.method
    end
    
    def test_that_proxy_simple_post_request_works_with_arguments
      request = ::RestClient::Request.new(method: :post, url: "http://example.com/test")
      params = {'key' => 'value'}
      request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test', :parameters => params})

      expected_parameters = {'key' => 'value'}
      assert_equal expected_parameters, request_proxy.parameters_for_signature
      assert_equal 'http://example.com/test', request_proxy.normalized_uri
      assert_equal 'POST', request_proxy.method
    end
    
    def test_that_proxy_simple_post_request_works_with_form_data
      request = ::RestClient::Request.new(method: :post, url: "http://example.com/test",
        payload: {'key' => 'value'},
        headers: {'Content-Type' => 'application/x-www-form-urlencoded'})
      request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test'})

      expected_parameters = {'key' => 'value'}
      assert_equal expected_parameters, request_proxy.parameters_for_signature
      assert_equal 'http://example.com/test', request_proxy.normalized_uri
      assert_equal 'POST', request_proxy.method
    end
    
  end
rescue LoadError => e
    warn "! problem loading rest-client, skipping these tests: #{e}"
end