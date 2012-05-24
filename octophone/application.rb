require 'sinatra/base'
require 'tropo-webapi-ruby'
require 'github_api'

module Octophone
  class Application < Sinatra::Base
    enable :sessions

    get '/' do
      "Octophone - Dial into your GitHub repository and merge pull requests from your phone!"
    end

    post '/' do
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
              say :value => 'Please type in the pull request number to merge'
              choices :value => '[ANY]', :terminator => '#'
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
      p ENV['GITHUB_OAUTH_TOKEN']
      p params
      pull_request = ::Github::PullRequests.new(:oauth_token => ENV['GITHUB_OAUTH_TOKEN'])
      # p pull_request
      # p pull_request.merged?('czarneckid', 'test-repository', params[:id])
      # pull_request.merge('czarneckid', 'test-repository', '2', :commit_message => "Merge from Octophone")
      Tropo::Generator.say(:value => 'Goodbye.')
    end
  end
end