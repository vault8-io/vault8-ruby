require 'uri'

module Vault8
  class Client
    def initialize(public_key, secret_key, service_url)
      @public_key = public_key
      @secret_key = secret_key
      @service_url = service_url
    end

    def image_url(uid, filters=[], image_name='name.jpg')
      URI.join(@service_url, image_path(uid, filters, image_name)).to_s
    end

    def image_path(uid, filters=[], image_name='image.jpg')
      [uid, merged_filters(filters), image_name].compact.join('/')
    end

    def merged_filters(filters=[])
      return nil if filters.empty?
      filters.map do |filter|
        [filter.keys.first, filter.values.first].join('-')
      end.join(',')
    end
  end
end
