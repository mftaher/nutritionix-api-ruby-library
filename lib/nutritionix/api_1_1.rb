require "rest-client"
require "cgi"
require 'logger'
require 'active_support/json'

module Nutritionix
  # Reference: https://github.com/mftaher/nutritionix-api-ruby-library/blob/master/lib/nutritionix.rb
  class Api_1_1
    attr_accessor :app_id, :app_key, :app_url
    attr_accessor :logger

    #
    # Create the Nutritionix API client.
    #
    # @param id Nutritionix application ID
    # @param key Nutritionix API key
    # @param url (Optional) Nutritionix API url
    #
    def initialize(id, key, url="https://api.nutritionix.com/v1_1", logger=APILogger.default_logger)
      @app_id = id
      @app_key = key
      @app_url = url
      @logger = logger
    end

    # Sends a POST request to the Nutritionix API Server
    #
    # @param endpoint The endpoint to send the request to.Current valid type is: search
    #
    # @param params a hash containing required query, filters, etc options as defined
    # by https://developer.nutritionix.com/docs/v1_1 Nutritionix Querying Language
    # (NXQL) convertible to a valid JSON.
    #
    # @return The request result or error as json string
    #
    def post_request(endpoint, params={})
      params = sanitize_params(params)
      add_creds_to_params(params)

      params_json = params.to_json
      logger.debug "======POST Request Params Json: #{params_json}"

      url = [@app_url, endpoint].join('/')
      logger.debug "POST request URL: #{url}"
      begin
        # Reference: http://rubydoc.info/gems/rest-client/1.6.7/RestClient.post
        response = RestClient.post(url, params_json, content_type: 'application/json')
      rescue Exception => e
        logger.error "==================================================="
        logger.debug "An exception occured while processing POST request to url: #{url}"
        logger.error e.to_s
        logger.error "==================================================="
        response = { error: e.message}.to_json
      end

      response
    end

    # Sends a GET request to the Nutritionix API Server
    #
    # @param query string Query or search term / phrase
    # @param endpoint The endpoint to send the request to.Current valid type is: search, item, brand
    #
    # @param params a hash containing required query, filters, etc options as defined
    # by https://developer.nutritionix.com/docs/v1_1 Nutritionix Querying Language
    # (NXQL) convertible to a valid JSON.
    #
    # @return The request result or error as json string
    #
    def get_request(query, endpoint, params={})
      query = ::CGI::escape(query)
      params = sanitize_params(params)
      add_creds_to_params(params)

      serialized_params = serialize_params(params)

      url_components = [@app_url, endpoint]
      if 'item' == endpoint
        # Heroku using older version of Ruby prepend method on String is
        # not available.Thus using String's insert method
        serialized_params.insert(0, "id=#{query}&")
      else
        url_components << query
      end

      url =  "#{url_components.join('/')}?#{serialized_params}"
      logger.debug "GET request URL: #{url}"
      header = {}
      begin
        response = RestClient.get url, header
      rescue Exception => e
        logger.error "==================================================="
        logger.debug "An exception occured while processing GET request to url: #{url}"
        logger.error e.to_s
        logger.error "==================================================="
        response = { error: e.message}.to_json
      end

      response
    end

    #
    # Pass a search term into the API like taco, or cheese fries, and the
    # NutritionIX API will return an array of matching foods.
    #
    # @param term string The phrase or terms you would like to search by
    # @param range_start integer (Optional)Start of the range of results to view a section of up to 500 items in the "hits" array
    # @param range_end integer (Optional)End of the range of results to view a section of up to 500 items in the "hits" array
    # by default, the api will fetch the first 10 results
    # @param cal_min integer (Optional)The minimum number of calories you want to be in an item returned in the results
    # @param cal_max integer (Optional)The maximum number of calories you want to be in an item returned in the results
    # @param fields strings (Optional)The fields from an item you would like to return in the results.
    # Supports all item properties in comma delimited format.
    # A null parameter will return the following item fields only: item_name, brand_name, item_id.
    # NOTE-- passing "*" as a value will return all item fields.
    # @param brand_id string (Optional)Filter your results by a specific brand by passing in a brand_id
    #
    # @return The search results as json string
    #
    def search(term, range_start = 0, range_end = 10, cal_min = 0, cal_max = 0, fields = NIL, brand_id = NIL)
      get_request(term, 'search', {
          :results => "#{range_start}:#{range_end}",
          :cal_min => "#{cal_min}",
          :cal_max => "#{cal_max}",
          :fields => fields,
          :brand_id => brand_id,
      })
    end

    def nxql_search(search_params={})
      # Default sort options
      sort_options = {
        sort: {
          field: "_score",
          order: "desc"
        }
      }

      search_params.merge!(sort_options) unless search_params[:sort].nil?

      logger.debug "Nutritionix::Api_1_1 NXQL search params: #{search_params}"

      post_request('search', search_params)
    end

    #
    # This operation returns an item object that contains data on all its nutritional content
    #
    # @param id string The id of the food item whose details are needed
    #
    # @return the item details as json string
    #
    def get_item(id)
      get_request(id, 'item', {})
    end

    private

    def add_creds_to_params(params)
      params[:appId] = @app_id
      params[:appKey] = @app_key
    end

    def sanitize_params(params)
      params = {} unless params.is_a? Hash
      params
    end

     def serialize_params(params)
       request_params = []
       params.each do |key, value|
          request_params << "#{key}=#{::CGI::escape(value)}" unless value.nil?
       end
       request_params.join('&')
     end

  end

  class APIException < Exception

  end

  # http://ruby.about.com/od/tasks/a/logger.htm
  class APILogger
    attr_reader :logger_instance
    attr_accessor :file

    # @param logger the logger instance to be used for logging
    # @param file. Default outputs log to <HOME_DIR>/nutritionix_api_logs.txt
    def initialize(logger=nil, file=File.join(Dir.home, 'nutritionix_api_logs.txt'))
      @file = file
      @logger_instance = logger || Logger.new(@file)
    end

    # Returns the default logger(Logger) instance distributed by Ruby in its
    # standard library.
    def self.default_logger
      logger = APILogger.new
      logger.logger_instance
    end

  end
end