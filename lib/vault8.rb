require "vault8/version"
require 'uri'

class Vault8
  def self.create!(public_key: , secret_key: , service_url:)
    self.new(public_key, secret_key, service_url)
  end

  def initialize(public_key, secret_key, service_url)
    @public_key = public_key
    @secret_key = secret_key
    @service_url = service_url
  end

  def image_url(uid, filters=[], image_name='name.jpg')
    URI.join(@service_url, image_path(uid, filters, image_name)).to_s
  end

  def encode_token(p:, s:, path:, current_time: nil, until_time: nil)
    Digest::SHA256.hexdigest([p, s, path, current_time, until_time].compact.join('|')).reverse
  end

  def image_path(uid, filters=[], image_name='image.jpg')
    [uid, merged_filters(filters), image_name].compact.join('/')
  end

  def merged_filters(filters=[])
    return nil if filters.empty?
    filters.map do |filter|
      filter.map do |k, v|
        [k, (v.nil? || v.empty?) ? nil : v].compact.join('-')
      end.join(',')
    end.join(',')
  end
end
