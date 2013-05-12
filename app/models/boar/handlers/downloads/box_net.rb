# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    module Downloads
      class BoxNet < Base
        def initialize(service, options)
          super(service, options)
          configuration = self.load_credentials

          # Open the session and refresh the token
          @session = RubyBox::Session.new({client_id: configuration[:client_id], client_secret: configuration[:client_secret], access_token: configuration[:access_token]})
          token = @session.refresh_token(configuration[:refresh_token])

          # Save the token and schedule an update to avoid expiration
          self.update_credentials({access_token: token.token, refresh_token: token.refresh_token})
          # TODO: Reschedule token refreshing after 13 days

          @client = RubyBox::Client.new(@session)
        end

        def call(path, entry, skip_cache, _, _)
          # Read the URL from Redis
          key = @configuration.backend_key("downloads:box_net[#{path}]", self, @service.controller.request)
          url = @configuration.backend.get(key)

          if skip_cache || url.blank? then
            begin
              # Get the file
              file = @client.file(entry[:path])
              raise Boar::Exceptions::NotFound if file.nil?

              # Create the shared link
              shared_link = create_shared_link(file)
              raise Boar::Exceptions::NotFound if shared_link.nil?
              url = entry["disposition"] == "inline" ? shared_link["url"] : shared_link["download_url"]

              # Save the URL
              @configuration.backend.set(key, url) if url.present?
            rescue => e
              raise Boar::Exceptions::ServerError.new("[#{e.class}] #{e.message}")
            end
          end

          # Redirect to the final URL
          @service.controller.redirect_to(url)
        end

        private
          def create_shared_link(file)
            begin
              api_uri = URI.parse("#{RubyBox::API_URL}/files/#{file.id}")
              request = Net::HTTP::Put.new(api_uri.path, {"Content-Type" => 'application/json'})
              request.body = JSON.dump({shared_link: {access: "open"}})
              @session.request(api_uri, request).fetch("shared_link")
            rescue
              nil
            end
          end
      end
    end
  end
end