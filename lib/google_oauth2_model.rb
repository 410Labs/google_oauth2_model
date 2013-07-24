require 'forwardable'
require 'oauth2'

module GoogleOauth2Model
  def self.consumer_key; @consumer_key end
  def self.consumer_key= v; @consumer_key = v end
  def self.consumer_secret; @consumer_secret end
  def self.consumer_secret= v; @consumer_secret = v end
  
  class GoogleAccessToken
    class NoRefreshTokenError < ArgumentError; end;
    attr_accessor :owner

    extend Forwardable
    def_delegators :@owner, :oauth2_token, :oauth2_token_expires_at, :oauth2_refresh_token

    def initialize(owner)
      @owner = owner
    end

    def access_token
      @access_token ||= ::OAuth2::AccessToken.new(client, oauth2_token, refresh_token: oauth2_refresh_token, expires_at: oauth2_token_expires_at.to_i)
    end

    def refresh!
      raise NoRefreshTokenError unless oauth2_refresh_token
      return access_token unless expired?
      @access_token = access_token.refresh!.tap do |new_token|
        # Statsd.increment('mailstrom.oauth2.success_response')
        owner.google_access_credentials!(token: new_token.token, expires_at: new_token.expires_at)
      end
    rescue OAuth2::Error => ex
      # do something here? the refresh *did* fail
      # maybe nix refresh token and have the user re-auth when they come back?
      # I don't like throwing away data that might still be working though
      # log it for now
      if ex.message.starts_with?('invalid_grant')
        # Statsd.increment('mailstrom.oauth2.invalid_grant_response')
        owner.update_attribute(:oauth2_refresh_token, nil) unless valid? # nix the refresh token, puts them in a needs_reauth?-positive state
      end
      raise
    end

    def expired?
      access_token.expired?
    end

    def token
      refresh! if expired?
      oauth2_token
    end

    def client
      @client ||= ::OAuth2::Client.new(GoogleOauth2Model.consumer_key, GoogleOauth2Model.consumer_secret,
                                     :site          => 'https://accounts.google.com',
                                     :authorize_url => '/o/oauth2/auth',
                                     :token_url     => '/o/oauth2/token')
    end


    def tokeninfo
      response = Faraday.get 'https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=' + URI.encode(oauth2_token)
      JSON.load(response.body)
    end

    def valid?
      !tokeninfo.key?('error')
    end

    module OwnerMethods
      def google_access_token; @google_access_token ||= GoogleAccessToken.new(self) end
      def google_oauth_token;                             google_access_token.token end
      def oauth2?;                                               !oauth2_token.nil? end
      def refresh_google_access_token!;                google_access_token.refresh! end

      def google_access_credentials!(creds)
        creds = creds.with_indifferent_access
        expires_at = creds.fetch(:expires_at)
        new_attributes = {
          oauth2_token: creds.fetch(:token),
          oauth2_token_expires_at: Time.at(creds.fetch(:expires_at))
        }
        new_attributes.merge!(oauth2_refresh_token: creds.fetch(:refresh_token)) if creds[:refresh_token]
        update_attributes(new_attributes)
      end
    end
  end
end