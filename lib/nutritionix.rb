require "nutritionix/version"
require "rest-client"
require "cgi"

module Nutritionix
  class API
    attr_accessor :app_id, :app_key, :app_url

    #
    # Create the Nutritionix API client.
    #
    # @param id Nutritionix application ID
    # @param key Nutritionix API key
    # @param url (Optional) Nutritionix API url
    #

    def initialize(id, key, url="http://api.nutritionix.com/v1/")
      @app_id = id
      @app_key = key
      @app_url = url
    end

    #
    # Pass a search term into the API like taco, or cheese fries, and the API will return an array of matching foods.
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
      nutritionix_request('search', ::CGI::escape(term), {
          :results => "#{range_start}:#{range_end}",
          :cal_min => "#{cal_min}",
          :cal_max => "#{cal_max}",
          :fields => fields,
          :brand_id => brand_id,
      })
    end

    #
    # Performs a query request with the Nutritionix API Server
    #
    # @param type string type of query. Current valid types are: search, item, brand
    # @param query string Query or search term / phrase
    # @param params hash Parameters associated with the query
    #
    # @return The request result as json string
    #
    # @error
    # application_not_found
    #

    def nutritionix_request(type, query, params)
      serialized = get_serialized_params(params)
      url = "#{File.join("#{@app_url}", "#{type}", "#{query}")}?#{serialized}"
      header = {}
      begin
        response = RestClient.get url, header
      rescue Exception => e
        {:error => e.message}.to_json
      end
    end

    #
    # This operation returns an item object that contains data on all its nutritional content
    #
    # @param id string The id of the brand you want to retrieve
    #
    # @return The brand as json string
    #

    def get_item(id)
      nutritionix_request('item',::CGI::escape(id), {})
    end

    #
    # This operation returns the a brand object that contains data on all its nutritional content
    #
    # @param id string The id of the brand you want to retrieve
    #
    # @return The brand as json string
    #

    def get_brand(id)
      nutritionix_request('brand',::CGI::escape(id), {})
    end

    #
    # Combine the parameter hash with access credentials
    #
    # @param params - Parameters associated with the query
    #
    # @return string The request results string
    #

    def get_serialized_params(params)
      params['appId'] = @app_id
      params['appKey'] = @app_key
      request_params = []
      params.each do |key, value|
        request_params << "#{key}=#{::CGI::escape(value)}" unless value.nil?
      end
      request_params.join('&')
    end

  end

  class APIException < Exception

  end
end
