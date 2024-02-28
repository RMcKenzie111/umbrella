require "http"
require "json"

# Ask for user location
puts "Hello, whaat's your location?"

# Get and store user location
user_location = gets.chomp

# Get user's latitude and longitude from Google API
puts "Let's see what the weather is in #{user_location}"
 gmaps = ENV.fetch("GMAPS-KEY")
 gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps}"
 
 raw_gmaps = HTTP.get(gmaps_url)
 parsed_gmaps = JSON.parse(raw_gmaps)
 results = parsed_gmaps.fetch("results")
 result_hash = results.at(0)
 geohash = result_hash.fetch("geometry")
 localhash = geohash.fetch("location")
 latitude = localhash.fetch("lat")
 longitude = localhash.fetch("lng")

 puts "Your coordintes: #{latitude}, #{longitude} "

 # Get the weather at the user’s coordinates from the Pirate Weather API.

 pw_key = ENV.fetch("PIRATE_WEATHER_KEY")
 pw_url = "https://api.pirateweather.net/forecast/#{pw_key}/#{latitude},#{longitude}"

 raw_pw = HTTP.get(pw_url)
 parsed_pw = JSON.parse(raw_pw)
 current_hash = parsed_pw.fetch("currently")
 the_temp = current_hash.fetch("temperature")

 puts "It's currently #{the_temp}°F."

# Display the current temperature and summary of the weather for the next hour.

minute_hash = parsed_pw.fetch("minuteley", false)
if
