require 'oauth/request_proxy/base'
require 'curb'
require 'uri'
require 'cgi'

module OAuth::RequestProxy::Curl
  class Easy < OAuth::RequestProxy::Base
    # Proxy for signing Typhoeus::Request requests
    # Usage example:   
    # oauth_params = {:consumer => oauth_consumer, :token => access_token}      
    # req = Typhoeus::Request.new(uri, options)
    # oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(:request_uri => uri))      
    # req.headers.merge!({"Authorization" => oauth_helper.header})
    # hydra = Typhoeus::Hydra.new()
    # hydra.queue(req)
    # hydra.run
    # response = req.response
    proxies ::Curl::Easy        

    def uri
      options[:uri].to_s
    end
    
    def parameters
      if options[:clobber_request]
        options[:parameters]
      else
        post_parameters.merge(query_parameters).merge(options[:parameters] || {})
      end
    end
    
    private
    
    def query_parameters
      query = URI.parse(request.url).query
      return(query ? CGI.parse(query) : {})
    end
    
    def post_parameters
      post_body = {}
      
      # Post params are only used if posting form data
      if (request.headers['Content-Type'] && request.headers['Content-Type'].downcase == 'application/x-www-form-urlencoded')
      
        request.post_body.split("&").each do |str|
          param = str.split("=")
          post_body[param[0]] = param[1]
        end
      end
      post_body
    end
  end
end