Weather History
=========

This tool uses history weather data from Weather Underground to analyze the
number of snow or rain days historically. I built it to answer the question:
How many days of the year in NYC have never had rain. In other words, is there
any day, like October 12th, on which it has never rained in NYC in the past?

The answer to that question is: **No**.  Since 1984 (first year for which comprehensive
data is available through the WU site), *it has rained at least once on every day
of the calendar year* (at least at JFK airport).

In Logan, UT, (airport code LGU) these days have never had rain:
Jan 6, Jan 12, Jan 13, Feb 2, Feb 27, Feb 29, July 8, July 12, July 27, Aug 9, 
Sep 25, and Dec 5.

Here's an example URL for the data:
http://www.wunderground.com/history/airport/jfk/1984/1/1/CustomHistory.html?dayend=1&monthend=1&yearend=1985&req_city=NA&req_state=NA&req_statename=NA&MR=1

To use:

```
$ gem install bundler
$ bundle
$ irb -r ./config/boot.rb
>> airport_code = 'JFK'
>> 1984.upto(2010) {|year| $COLL.insert(WeatherHistory.parse(y, airport_code))};
>> analyzer = WeatherHistory::Analyzer.new(airport_code)
>> $DB['weather_analysis'].insert(analyzer.analyze)
```

This loads the weather history data into a mongodb collection 'weather' in a db
named 'weatherhistory_development' (configurable in config/mongo.yml), and loads
the analyzed data in a collection 'weather_analysis'.  You can then query it for
days which historically have had no rain by doing:

```
>> $DB['weather_analysis'].find(:rain_count => 0, :airport_code => airport_code).to_a
```

It also stores the min and max temperature for that calendar day, so if you want
to find what the min and max temperatures on your birthday were:

```
>> $DB['weather_analysis'].find(:airport_code => airport_code, :day => 27, :month => 3).to_a
```