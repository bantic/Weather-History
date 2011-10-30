module WeatherHistory
  class Analyzer
    DEBUG = true
    
    def initialize(airport_code)
      @airport_code = airport_code
    end
    
    def analyze
      docs = []
      1.upto(12) do |month|
        1.upto(31) do |day|
          if has_day?(month,day)
            puts "Month: #{month}, day: #{day}" if DEBUG
            data       = get_data_for(month,day)
            min_temp   = analyze_min_temp(data)
            max_temp   = analyze_max_temp(data)
            snow_count = analyze_snow_count(data)
            rain_count = analyze_rain_count(data)
            fog_count  = analyze_fog_count(data)
            
            doc = {
              :min_temp     => min_temp,
              :max_temp     => max_temp,
              :snow_count   => snow_count,
              :rain_count   => rain_count,
              :fog_count    => fog_count,
              :month        => month,
              :day          => day,
              :airport_code => @airport_code
            }
            docs << doc
            # $DB['weather_analysis'].insert(doc)
          end
        end
      end
      docs
    end
    
    private
    
    def has_day?(month, day)
      $COLL.count(query:{ airport_code:@airport_code, month:month, day:day }) > 0
    end
    
    def get_data_for(month,day)
      $COLL.find(airport_code:@airport_code, month:month, day:day).to_a
    end
    
    def analyze_min_max(data, field, min_or_max)
      data.collect do |d| 
        t = d[field]
        if t.is_a?(Float)
          t
        else
          nil
        end
      end.compact.send(min_or_max)
    end
    
    def analyze_min_temp(data)
      analyze_min_max(data, 'min_temperaturef', :min)
    end
    
    def analyze_max_temp(data)
      analyze_min_max(data, 'max_temperaturef', :max)
    end
    
    def analyze_snow_count(data)
      analyze_event_count(data,'snow')
    end
    
    def analyze_rain_count(data)
      analyze_event_count(data,'rain')
    end

    def analyze_fog_count(data)
      analyze_event_count(data,'fog')
    end
    
    def analyze_event_count(data, event)
      count = 0
      data.each do |datum|
        count += 1 if datum[event]
      end
      count
    end
  end
end
