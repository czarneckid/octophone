require 'json'
require 'sinatra/base'
require 'tropo-webapi-ruby'
require 'github_api'

module Octophone
  class Application < Sinatra::Base
    enable :sessions

    get '/' do
      "Octophone - Dial into your GitHub repository and merge pull requests from your phone!"
    end

    post '/dialin' do
      @github = ::Github.new
      pull_request = @github.pull_requests.all('czarneckid', 'test-repository').first
      if pull_request
        tropo = Tropo::Generator.new do
          on :event => 'hangup', :next => '/hangup'
          on :event => 'continue', :next => "/merge_pull_request"
          ask({ :name => 'pull_request_number',
            :bargein => 'true',
            :timeout => 30,
            :required => 'true' }) do
              say :value => 'Please type in the pull request number to merge, followed by an #.'
              choices :value => '[1 DIGITS]', :mode => 'dtmf', :terminator => '#'
            end
          end

        tropo.response
      else
        Tropo::Generator.say(:value => 'There are no pull requests in your repository. Goodbye.')
      end
    end

    post '/hangup' do
      Tropo::Generator.say(:value => 'Goodbye.')
    end

    post '/merge_pull_request' do
      parsed_input = JSON.parse(request.env["rack.input"].read)
      pull_request = ::Github::PullRequests.new(:oauth_token => ENV['GITHUB_OAUTH_TOKEN'])
      pull_request.merge('czarneckid', 'test-repository', parsed_input['result']['actions']['value'])
      merged = pull_request.merged?('czarneckid', 'test-repository', parsed_input['result']['actions']['value'])
      if merged
        Tropo::Generator.say(:value => 'Your pull request was merged successfully.')
      else
        Tropo::Generator.say(:value => 'Your pull request could not be merged at this time.')
      end
    end
  end
end