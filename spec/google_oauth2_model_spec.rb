require 'spec_helper'

GoogleOauth2Model.consumer_key = 'foo'
GoogleOauth2Model.consumer_secret = 'bar'

describe GoogleOauth2Model::GoogleAccessToken do
  describe "#expired?" do
    context "with an unexpired token" do
      subject do
        owner = double('Model')
        owner.stub(:oauth2_token_expires_at).and_return((Time.now + 5*60*60).to_i)
        owner.stub(:oauth2_token).and_return('')
        owner.stub(:oauth2_refresh_token).and_return('')
        GoogleOauth2Model::GoogleAccessToken.new(owner)
      end
      its(:expired?) { should be_false }
    end
    context "with an expired token" do
      subject do
        owner = double('Model')
        owner.stub(:oauth2_token_expires_at).and_return((Time.now - 5*60*60).to_i)
        owner.stub(:oauth2_token).and_return('')
        owner.stub(:oauth2_refresh_token).and_return('')
        GoogleOauth2Model::GoogleAccessToken.new(owner)
      end
      its(:expired?) { should be_true }
    end
  end
  describe "#token" do
    context "with an unexpired token" do
      subject do
        owner = double('Model')
        owner.stub(:oauth2_token_expires_at).and_return((Time.now + 5*60*60).to_i)
        owner.stub(:oauth2_token).and_return('old_token')
        owner.stub(:oauth2_refresh_token).and_return('')
        GoogleOauth2Model::GoogleAccessToken.new(owner)
      end
      before do
        subject.should_not_receive(:refresh!)
      end
      its(:token) { should == 'old_token' }
    end
    context "with an expired token" do
      subject do
        @oauth_token = 'old_token'
        owner = double('Model')
        owner.stub(:oauth2_token_expires_at).and_return((Time.now - 5*60*60).to_i)
        owner.stub(:oauth2_token) { @oauth_token }
        owner.stub(:oauth2_refresh_token).and_return('')
        GoogleOauth2Model::GoogleAccessToken.new(owner)
      end
      before do
        subject.should_receive(:refresh!) { @oauth_token = 'new_token' }
      end
      its(:token) { should == 'new_token' }
    end
  end
end
