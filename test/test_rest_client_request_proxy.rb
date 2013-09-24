require File.expand_path('../test_helper', __FILE__)

begin
  require 'oauth/request_proxy/rest_client_request'
  require 'rest-client'
  require 'oauth/request_proxy/typhoeus_request'
  require 'typhoeus'
  require 'debugger'
  
  class RestlClientRequestProxyTest < Test::Unit::TestCase
  
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
    
    def test_that_proxy_simple_put_request_works_with_arguments
      request = ::RestClient::Request.new(method: :put, url: "http://example.com/test")
      params = {'key' => 'value'}
      request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test', :parameters => params})

      expected_parameters = {'key' => 'value'}
      assert_equal expected_parameters, request_proxy.parameters_for_signature
      assert_equal 'http://example.com/test', request_proxy.normalized_uri
      assert_equal 'PUT', request_proxy.method
    end
    
    def test_that_proxy_simple_put_request_works_with_form_data
      request = ::RestClient::Request.new(method: :put, url: "http://example.com/test",
        payload: {'key' => 'value'},
        headers: {'Content-Type' => 'application/x-www-form-urlencoded'})
      request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test'})

      expected_parameters = {'key' => 'value'}
      assert_equal expected_parameters, request_proxy.parameters_for_signature
      assert_equal 'http://example.com/test', request_proxy.normalized_uri
      assert_equal 'PUT', request_proxy.method
    end
    
    def test_that_proxy_post_request_works_with_mixed_parameter_sources
      request = ::RestClient::Request.new(url: 'http://example.com/test?key=value',
        method: :post,
        payload: {'key2' => 'value2'},
        headers: {'Content-Type' => 'application/x-www-form-urlencoded'})
      request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test?key=value', :parameters => {'key3' => 'value3'}})

      expected_parameters = {'key' => ['value'], 'key2' => 'value2', 'key3' => 'value3'}
      assert_equal expected_parameters, request_proxy.parameters_for_signature
      assert_equal 'http://example.com/test', request_proxy.normalized_uri
      assert_equal 'POST', request_proxy.method
    end
    
    def test_should_remove
      p "hi mastercard"

      cosumer_key = "KXydlOacvKZULi_bcJJV4Btfl3ev7UjbVaib9n1L4ec243a7!4b58647657676646794d484a2b4951644b345a4e70673d3d" # key from MC site

      private_key =  File.read("/Users/khem/Documents/RailsWorkspace/TestRuby-latest/private_key_regen_mobile.pem")
      consumer = OAuth::Consumer.new(cosumer_key, private_key, :site => "")

      request_token = ""
      
      uri = "http://localhost:9000/api/"
      options = {method: :get, headers: { Accept: "text/json" }}

      access_token = OAuth::ConsumerToken.from_hash(consumer, {oauth_token_secret: request_token, oauth_token: ""})

      oauth_params = {:signature_method => "RSA-SHA1", :token => access_token, :consumer => consumer}
      
      # hydra = Typhoeus::Hydra.new
      # req = Typhoeus::Request.new(uri, options)
      req = ::RestClient::Request.new(url: uri, method: :get,  headers: { Accept: "text/json" })
      oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(:request_uri => uri))
      # req.options[:headers].merge!({"Authorization" => oauth_helper.header}) # Signs the request
      req.headers.merge!({"Authorization" => oauth_helper.header}) # Signs the request
      debugger
      response = req.execute
      p "response: #{response.to_s}"
      p "response: #{response.code}"
      p "response: #{response.body}"
      
      # hydra.queue(req)
      # hydra.run
      # response = req.response
      # p "response: #{response.to_s}"
      # p "response: #{response.code}"
      # p "response: #{response.body}"
    end
    
  end
rescue LoadError => e
    warn "! problem loading rest-client, skipping these tests: #{e}"
end