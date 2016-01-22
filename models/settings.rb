require 'settingslogic'

class Settings < Settingslogic
  source '../config.yml'
  namespace ENV['chat_server'] || 'development'
  load!
end
