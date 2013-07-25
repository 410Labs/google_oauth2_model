# google_oauth2_model
[![Build Status](https://travis-ci.org/410Labs/google_oauth2_model.png?branch=master)](https://travis-ci.org/410Labs/google_oauth2_model)
[![Dependency Status](https://gemnasium.com/410Labs/google_oauth2_model.png)](https://gemnasium.com/410Labs/google_oauth2_model)

Allow a model to store google oauth2 access and refresh tokens.

Your model is expected to have the following columns:

* oauth2_token: string
* oauth2_token_expires_at: datetime
* oauth2_refresh_token: string

First, set your Google key and secret:

    GoogleOauth2Model.consumer_key = '<your google key>'
    GoogleOauth2Model.consumer_secret = '<your google secret>'

Then, in your model, include the methods:

    include GoogleOauth2Model::GoogleAccessToken::OwnerMethods

