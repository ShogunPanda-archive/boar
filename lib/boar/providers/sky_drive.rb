# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Providers
    class SkyDrive < Base
      SCOPES = "wl.skydrive_update,wl.offline_access"

      def redirect_for_authentication(authorizer, configuration)
        authorizer.ip = configuration[:domain]

        @client = Boar::Providers::SkyDrive.client(configuration, authorizer.callback_url)
        @client.authorize_url
      end

      def get_credentials(authorizer, request, response)
        begin
          raise Clavem::Exceptions::AuthorizationDenied if request.query["error"].present? || request.query["code"].blank?
          token = @client.get_access_token(request.query["code"])
          {access_token: token.token, refresh_token: token.refresh_token}
        rescue RuntimeError
          nil
        end
      end

      def search_file(path, params)
        rv = nil

        # Split path
        Lazier.load_pathname
        filename = File.basename(path)
        tree = Pathname.new(File.dirname(path)).components

        # Initialize client
        client = Boar::Providers::SkyDrive.authorized_client(params[:single], params)

        # Find the last folder
        current = client.my_skydrive
        tree.each do |folder|
          current = search_entry(current, folder, true)
          break if !current
        end

        # We have the container, query for the file
        rv = search_entry(current, filename) if current
        rv ? {"id" => rv.id} : nil
      end

      def self.client(configuration, callback_url = nil)
        ::Skydrive::Oauth::Client.new(configuration[:client_id], configuration[:client_secret], callback_url, Boar::Providers::SkyDrive::SCOPES)
      end

      def self.authorized_client(configuration, params)
        # Get a new access token
        token = Boar::Providers::SkyDrive.client(configuration).get_access_token_from_hash(configuration[:access_token], {:refresh_token => configuration[:refresh_token]})
        params[:provider].update_credentials({access_token: token.token, refresh_token: token.refresh_token}, params)

        # Create the client
        Skydrive::Client.new(token)
      end

      private
        def search_entry(parent, entry, directory = false)
          catch(:entry) do
            parent.files.items.each do |file|
              if file.name == entry && (file.is_a?(Skydrive::File) || directory)
                file.instance_variable_set("@client", parent.client) # This is to fix a gem's bug.
                throw(:entry, file)
              end
            end

            nil
          end
        end
    end
  end
end