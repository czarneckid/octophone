$LOAD_PATH << '.'

require 'rack'
require 'octophone/application'

run Rack::Cascade.new([
  Octophone::Application
])
