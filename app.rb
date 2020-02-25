require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
require "date"
# require "open-uri"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key here
ForecastIO.api_key = "bb6ffb709952488520c6e2a3d146c0b4"

# News API Key
news = HTTParty.get("http://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=39f4eb465b0c4330869cc31a81d563e6").parsed_response.to_hash

get "/" do
   view "ask"
end

get "/news" do
    # Convert location in form to coordinates
    results = Geocoder.search(params["q"])
    lat_long = results.first.coordinates

    # Get lat-long for weather API and store current weather
    @forecast = ForecastIO.forecast(lat_long[0],lat_long[1]).to_hash
    @current_temperature = @forecast["currently"]["temperature"]
    @current_summary = @forecast["currently"]["summary"]
    @icon = @forecast["currently"]["icon"]
    
    # Forecast data
    @forecast_temperature = Array.new
    @forecast_summary = Array.new
    @forecast_icon = Array.new

    # For loop to create arrays for weather API
    i = 0
    for day in @forecast["daily"]["data"] do
        @forecast_temperature[i] = day["temperatureHigh"]
        @forecast_summary[i] = day["summary"]
        @forecast_icon[i] = day["icon"]
        i = i+1
    end

    # Declare arrays for news API
    @title = Array.new
    @story_url = Array.new
    a = 0

    # For loop to create arrays from news API
    for story in news["articles"] do
        @title[a] = story["title"]
        @story_url[a] = story["url"]
        a = a+1
    end

    # Display todays date for new headlines section
    time = Time.new
    @year = time.year
    @month = time.month
    @day = time.day
    @date = Date.new(@year, @month, @day)

    view "newspage"

end