require "http"
require "json"
require "ascii_charts"

# Ask for user location
puts "Hello, what's your location?"

# Get and store user location
user_location = gets.chomp

# Get user's latitude and longitude from Google API
puts "Let's see what the weather is in #{user_location}"
 gmaps = ENV.fetch("GMAPS_KEY")
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
if minute_hash
  weather_summary = minute_hash.fetch("summary")
  puts "Next hour #{weather_summary}"
end

#For each of the next twelve hours, check if the precipitation probability is greater than 10%.

hour_hash = parsed_pw.fetch("hourly")
hour_array = hour_hash.fetch("data")
next_twelve = hour_array[1..12]
precip_threshold = 0.10
any_precip = false

next_twelve.each do |the_hour|
  precip_probability = the_hour.fetch("precipProbability")

  #If so, print a message saying how many hours from now and what the precipitation probability is.

  if precip_probability > precip_threshold
    any_precip = true
    precip_time = Time.at(the_hour.fetch("time"))
    seconds_later = precip_time - Time.now
    hours_later = seconds_later / 60 / 60
    puts "In #{hours_later.round} hours, there is a #{(precip_probability * 100).round}% chance of precipitation."
  end
  if any_precip == true
    puts "You might want to carry an umbrella!"
    puts AsciiCharts::Cartesian.new({hours_later.round => (precip_probability * 100).round}, :bar => true, :hide_zero => true).draw
  end
end

#If any of the next twelve hours has a precipitation probability greater than 10%, print “You might want to carry an umbrella!”
#If not, print “You probably won’t need an umbrella today.”
  if any_precip == false
    puts "You probaly won't need an umbrella today."
  end
    
