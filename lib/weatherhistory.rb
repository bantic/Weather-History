require 'open-uri'

module WeatherHistory
  URL = "http://www.wunderground.com/history/airport/{{code}}/{{year1}}/1/1/CustomHistory.html?dayend=1&monthend=1&yearend={{year2}}&req_city=NA&req_state=NA&req_statename=NA&format=1"
  DEBUG = true
  
  class << self
    def url_for_year(year,code)
      year = year.to_i
      this_year = year.to_s
      next_year = (year + 1).to_s
      url = URL.sub("{{year1}}", this_year).
                sub("{{year2}}", next_year).
                sub("{{code}}",  code)
      puts url if DEBUG
      url
    end
    
    def parse(year, code="LGU")
      year_data = open(url_for_year(year, code))
      line_no   = 0
      fields    = []
      docs      = []
      year_data.each_line do |line|
        line_no += 1
        
        next if line =~ /^\s+$/ || line.empty?
        line = prepare line
        puts line if DEBUG
        
        if fields.empty?
          fields = parse_fields_from_line(line) 
        else
          data = parse_data_from_line(line)      
          docs << prepare_data(data, fields, code)
        end
      end
      
      docs
    end
    
    def prepare_data(data, fields, code)
      doc = {}
      fields.each_with_index do |field, index|
        doc[field] = data[index]
      end
      
      # denormalize snow, rain, fog
      events = data[ fields.index('events') ]
      events = (events || '').downcase
      ['snow','rain','fog'].each do |weather_type|
        doc[weather_type] = events.include?(weather_type)
      end
      
      # denormalize month, day, year
      doc['year']  = data[ fields.index('date') ].strftime("%Y").to_i
      doc['month'] = data[ fields.index('date') ].strftime("%m").to_i
      doc['day']   = data[ fields.index('date') ].strftime("%d").to_i
      
      doc['airport_code'] = code
      doc
    end
    
    def prepare(line)
      line.sub("<br />\n","")
    end
    
    def parse_fields_from_line(line)
      fields = line.split(',').map {|field| field.strip.gsub(/\s+/,'_').downcase }
      fields[0] = "date"
      fields
    end
    
    def parse_data_from_line(line)
      data = line.split(',')
      date = Time.parse data.shift
      data.map! do |d| 
        if d == '' || d =~ /^[a-zA-Z\-]+$/
          d
        else
          d.to_f
        end
      end
      data.unshift(date)
      data
    end
  end
end

require File.dirname(__FILE__) + '/weatherhistory/analyzer'