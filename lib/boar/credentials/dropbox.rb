# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Credentials
    class Dropbox < Base
      def redirect_for(authorizer, configuration)
        @session = DropboxSession.new(configuration[:app_key], configuration[:app_secret])
        @session.get_request_token
        @session.get_authorize_url + "&oauth_callback=#{authorizer.callback_url}"
      end

      def get_credentials(authorizer, request, response)
        begin
          @session.get_access_token
          {session: @session.serialize}
        rescue DropboxAuthError
          nil
        end
      end
    end
  end
end