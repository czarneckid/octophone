require 'spec_helper'

describe 'Octophone::Application' do
  def app
    Octophone::Application
  end
  
  describe '#get' do  
    it 'should respond with 200' do
      get '/'
      last_response.should be_ok
      last_response.body.should == "Octophone - Dial into your GitHub repository and merge pull requests from your phone!"
    end
  end
end