require "vault8/version"
require 'uri'

class Vault8
  attr_reader :public_key, :secret_key, :service_url

  def self.create!(public_key: , secret_key: , service_url:)
    self.new(public_key, secret_key, service_url)
  end

  def initialize(public_key, secret_key, service_url)
    @public_key = public_key
    @secret_key = secret_key
    @service_url = service_url
  end

  def image_url(uid:, filters: [], image_name: 'image.jpg', current_time: Time.current.to_i, until_time: Time.current.to_i + 86400)
    generate_url_for(path: image_path(uid, filters, image_name), current_time: current_time, until_time: until_time )
  end

  def upload_url(path: '/upload', current_time:, until_time:)
    generate_url_for(path: path, current_time: current_time, until_time: until_time)
  end

  def encode_token(path:, current_time: nil, until_time: nil)
    Digest::SHA1.hexdigest([public_key, secret_key, path, current_time, until_time].compact.join('|')).reverse
  end

  def image_path(uid, filters=[], image_name='image.jpg')
    '/' + [uid, merged_filters(filters), image_name].compact.join('/')
  end

  def merged_filters(filters=[])
    return nil if filters.empty?
    filters.flat_map do |filter|
      filter.map do |k, v|
        [k, v.to_s.empty? ? nil : v].compact.join('-')
      end
    end.join(',')
  end

  def generate_url_for(path:, current_time: nil, until_time: nil)
    uri = URI.join(service_url, path)
    uri.query = { p: public_key,
                  s: encode_token(path: path, current_time: current_time, until_time: until_time),
                  time: current_time,
                  until: until_time
                }.reduce([]) {|acc, x| acc << "#{x.first}=#{x.last}" unless x.last.nil?; acc}.join('&')
    uri.to_s
  end
end
