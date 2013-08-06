# Nutritionix

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'nutritionix'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nutritionix

## Usage

* For NXQL Supported search:

        app_id = '<YOUR_APP_ID>'
        app_key = '<YOUR_APP_KEY>'
        provider = Nutritionix::Api_1_1.new(app_id, app_key)
        search_params = {
          offset: 0,
          limit: 50,
          fields: ['brand_id', 'brand_name', 'item_id', 'item_name', 'nf_calories'],
          query: 'potato'
        }
        results_json = provider.nxql_search(search_params)
        puts "Results: #{results_json}"

* Note:
  * There is a standalone test script **/script/test_api_1_1.rb** available
    which can be readily used for testing.You only need to replace &lt;YOUR_APP_ID&gt;
    and &lt;YOUR_APP_KEY&gt; with your nutritionix app credentials.

  * Logs generated can be found at default location &lt;HOME_DIRECTORY&gt;/nutritionix_api_logs.txt

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
