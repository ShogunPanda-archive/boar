# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Credentials
    class GoogleDrive < Base
      NAME = "boar"
      VERSION = "1.0.0"
      SCOPES = ["https://www.googleapis.com/auth/drive"]

      def self.client(configuration)
        rv = Google::APIClient.new(authorization: :oauth_2, application_name: Boar::Credentials::GoogleDrive::NAME, application_version: Boar::Credentials::GoogleDrive::VERSION)
        rv.authorization.client_id = configuration[:client_id]
        rv.authorization.client_secret = configuration[:client_secret]
        rv.authorization.scope = Boar::Credentials::GoogleDrive::SCOPES
        rv
      end

      def redirect_for(authorizer, configuration)
        @client = Boar::Credentials::GoogleDrive.client(configuration)
        @client.authorization.redirect_uri = authorizer.callback_url
        @client.authorization.authorization_uri
      end

      def get_credentials(authorizer, request, response)
        begin
          raise Clavem::Exceptions::AuthorizationDenied if request.query["error"].present?

          @client.authorization.code = request.query["code"].to_s
          @client.authorization.fetch_access_token!
          {token: @client.authorization.refresh_token}
        rescue RuntimeError => e
          nil
        end
      end
    end
  end
end