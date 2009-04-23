require 'openssl'
require 'base64'

module OAuth
  module Helper
    extend self

    def escape(value)
      URI::escape(value.to_s, OAuth::RESERVED_CHARACTERS)
    end

    def generate_key(size=32)
      Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
    end

    alias_method :generate_nonce, :generate_key

    def generate_timestamp
      Time.now.to_i.to_s
    end

    def normalize(params)
      params.sort.map do |k, values|

        if values.is_a?(Array)
          # multiple values were provided for a single key
          values.sort.collect do |v|
            [escape(k),escape(v)] * "="
          end
        else
          [escape(k),escape(values)] * "="
        end
      end * "&"
    end

    # Parse an Authorization / WWW-Authenticate header into a hash
    def parse_header(header)
      # decompose
      params = header[6,header.length].split(/[,=]/)

      # odd number of arguments - must be a malformed header.
      raise OAuth::Problem.new("Invalid authorization header") if params.size % 2 != 0

      params.map! do |v|
        # strip and unescape
        val = unescape(v.strip)
        # strip quotes
        val.sub(/^\"(.*)\"$/, '\1')
      end

      # convert into a Hash
      Hash[*params.flatten]
    end

    def unescape(value)
      URI.unescape(value.gsub('+', '%2B'))
    end
  end
end