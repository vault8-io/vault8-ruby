require "vault8/version"
require "vault8/client"

module Vault8
  def self.create!(public_key: , secret_key: , service_url:)
    Client.new(public_key, secret_key, service_url)
  end
end
