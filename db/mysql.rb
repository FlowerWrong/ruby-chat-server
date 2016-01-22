require 'active_record'
require 'mysql2'

require '../models/settings'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     Settings.mysql.host,
  username: Settings.mysql.username,
  password: Settings.mysql.password,
  database: Settings.mysql.database
)
