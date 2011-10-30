require 'yaml'

env = ENV['RACK_ENV'] || 'development'
db_data = YAML::load_file File.dirname(__FILE__) + '/../mongo.yml'
db_data = db_data[env]

conn = Mongo::Connection.new
$DB   = conn[db_data['database_name']]
$COLL = $DB['weather']
