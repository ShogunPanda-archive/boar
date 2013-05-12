# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    module Downloads
      class GoogleDrive < Base
        def initialize(service, options)
          super(service, options)
          configuration = self.load_credentials
          @client = Boar::Providers::GoogleDrive.authorized_client(configuration)
          @api = @client.discovered_api('drive', 'v2')
        end

        def call(path, entry, skip_cache, _, _)
          # Read the URL from Redis
          key = @configuration.backend_key("downloads:google_drive[#{path}]", self, @service.controller.request)
          url = @configuration.backend.get(key)

          if skip_cache || url.blank? then
            begin
              # Get the file
              result = @client.execute(api_method: @api.files.get, parameters: {"fileId" => entry[:id]})
              raise Boar::Exceptions::NotFound if result.status == 404

              # Get the share link
              file = result.data
              url = file.web_content_link || file.alternate_link
              url = file.alternate_link if entry["disposition"] == "inline"
              raise Boar::Exceptions::NotFound if url.blank?

              # Save the URL
              @configuration.backend.set(key, url) if url.present?
            rescue => e
              raise Boar::Exceptions::ServerError.new("[#{e.class}] #{e.message}")
            end
          end

          # Redirect to the final URL
          @service.controller.redirect_to(url)
        end
      end
    end
  end
end