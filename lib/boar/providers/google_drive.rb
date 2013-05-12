# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Providers
    class GoogleDrive < Base
      NAME = "boar"
      VERSION = "1.0.0"
      SCOPES = ["https://www.googleapis.com/auth/drive"]

      def self.client(configuration)
        rv = Google::APIClient.new(authorization: :oauth_2, application_name: Boar::Providers::GoogleDrive::NAME, application_version: Boar::Providers::GoogleDrive::VERSION)
        rv.authorization.client_id = configuration[:client_id]
        rv.authorization.client_secret = configuration[:client_secret]
        rv.authorization.scope = Boar::Providers::GoogleDrive::SCOPES
        rv
      end

      def self.authorized_client(configuration)
        authorizer = Clavem::Authorizer.new(configuration.fetch(:authorizer_host, "localhost"), configuration.fetch(:authorizer_port, "2501"))

        client = Boar::Providers::GoogleDrive.client(configuration)
        client.authorization.redirect_uri = authorizer.callback_url
        client.authorization.refresh_token = configuration["token"]
        client.authorization.fetch_access_token!

        client
      end

      def redirect_for_authentication(authorizer, configuration)
        @client = Boar::Providers::GoogleDrive.client(configuration)
        @client.authorization.redirect_uri = authorizer.callback_url
        @client.authorization.authorization_uri
      end

      def get_credentials(authorizer, request, response)
        begin
          raise Clavem::Exceptions::AuthorizationDenied if request.query["error"].present? || request.query["code"].blank?

          @client.authorization.code = request.query["code"].to_s
          @client.authorization.fetch_access_token!
          {token: @client.authorization.refresh_token}
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
        client = Boar::Providers::GoogleDrive.authorized_client(params[:single])
        api = client.discovered_api('drive', 'v2')

        # Find the last folder
        parent = "root"
        tree.each do |folder|
          list = client.execute(api_method: api.children.list, parameters: {"folderId" => parent, "q" => "title='#{folder}'", "maxResults" => 1})
          parent = validate_file_entry(list)
          break if !parent
        end

        # We have the container, query for the file
        if parent then
          list = client.execute(api_method: api.files.list, parameters: {"folderId" => parent, "q" => "title='#{filename}'", "maxResults" => 1})
          rv = validate_file_entry(list)
        end

        rv ? {"id" => rv} : nil
      end

      private
        def validate_file_entry(results)
          items = results.data.items
          items.present? ? items[0]["id"] : nil
        end
    end
  end
end