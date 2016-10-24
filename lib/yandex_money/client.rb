module YandexMoney
  module Client
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def base_uri(base)
        @base_uri = base
      end

      def default_timeout(timeout)
        @default_timeout = timeout
      end

      def post(uri, options = {})
        conn = Faraday.new(build_url(uri)) do |conn|
          conn.response :json, :content_type => /\bjson$/

          conn.adapter Faraday.default_adapter
        end

        conn.post do |req|
          if options[:headers].is_a?(Hash)
            options[:headers].each do |key, value|
              req[key] = value
            end
          end

          if options[:body]
            case req.headers['Content-Type']
            when 'application/x-www-form-urlencoded'
              req.body = URI.encode_www_form(options[:body])
            end
          end
        end
      end

      def build_url(uri)
        if @base_uri.nil?
          uri.to_s
        else
          URI.join(@base_uri, uri).to_s
        end
      end
    end

    class Basement
      include YandexMoney::Client
    end

    def self.post(*args)
      Basement.post(*args)
    end
  end
end
