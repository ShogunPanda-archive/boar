# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Providers
    class BoxNet < Base
      def redirect_for_authentication(authorizer, configuration)
        @session = RubyBox::Session.new({client_id: configuration[:client_id], client_secret: configuration[:client_secret]})
        @session.authorize_url(authorizer.callback_url)
      end

      def get_credentials(authorizer, request, response)
        begin
          raise Clavem::Exceptions::AuthorizationDenied if request.query["error"].present?

          token = @session.get_access_token(request.query["code"])
          {access_token: token.token, refresh_token: token.refresh_token}
        rescue RuntimeError
          nil
        end
      end
    end
  end
end