# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    module Downloads
      class Remote < Base
        def call(path, entry, _, _)
          # Get the url
          url = entry[:url]

          # We can't download a directory
          raise Boar::Exceptions::NotFound.new(path) if url.blank?

          # Redirect to the remote URL
          @service.controller.redirect_to(self.interpolate(url, {path: path, entry: entry, options: @provider_options}))
        end
      end
    end
  end
end