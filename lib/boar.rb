# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "mbrao"
require "mustache"
require "mime-types"
require "redis"
require "oj"

require "clavem"
require "dropbox_sdk"
require "google/api_client"
require "aws-sdk"

require "boar/version" if !defined?(Boar::Version)
require "boar/configuration"
require "boar/router"
require "boar/engine"
require "boar/exceptions"

require "boar/credentials/base"
require "boar/credentials/dropbox"
require "boar/credentials/google_drive"
