require 'sinatra/base'
require 'tropo-webapi-ruby'

module Octophone
  class Application < Sinatra::Base
    enable :sessions

    get '/' do
      "Octophone - Dial into your GitHub repository and merge pull requests from your phone!"
    end
  end
end