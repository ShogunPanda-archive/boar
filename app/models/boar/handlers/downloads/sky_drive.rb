# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    module Downloads
      class SkyDrive < Base
        def initialize(service, options)
          super(service, options)

          @client = Boar::Providers::SkyDrive.authorized_client(self.load_credentials, self.credentials_params)
        end

        def call(path, entry, skip_cache, _, _)
          # Read the URL from Redis
          key = @configuration.backend_key("downloads:sky_drive[#{path}]", self, @service.controller.request)
          url = @configuration.backend.get(key)

          if skip_cache || url.blank? then
            begin
              # Get the file
              file = @client.get("/" + entry[:id]) rescue nil
              raise Boar::Exceptions::NotFound if file.blank?

              url = entry["disposition"] == "inline" ? file.link : file.download_link
              raise Boar::Exceptions::NotFound if url.blank?

              # Save the URL
              @configuration.backend.set(key, url) if url.present?
            rescue => e
              raise e
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