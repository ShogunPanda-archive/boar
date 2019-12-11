# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# A Rails engine to handle local static pages and downloads on the cloud.
module Boar
  # The current version of boar, according to semantic versioning.
  #
  # @see http://semver.org
  module Version
    # The major version.
    MAJOR = 1

    # The minor version.
    MINOR = 0

    # The patch version.
    PATCH = 1

    # The current version of boar.
    STRING = [MAJOR, MINOR, PATCH].compact.join(".")
  end
end
