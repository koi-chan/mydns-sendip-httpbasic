#!/usr/bin/ruby

require 'yaml'
require 'net/https'

MYDNS_ENDPOINTS = {
  v4: 'https://ipv4.mydns.jp/login.html',
  v6: 'https://ipv6.mydns.jp/login.html',
  auto: 'https://www.mydns.jp/login.html'
}.freeze

config = YAML.load_file(
  File.expand_path('config.yaml', __dir__)
).to_hash.freeze

config.each do |title, account|
  account['protocols'] = ['auto'] if(account['protocols'].include?('auto'))

  account['protocols'].each do |p|
    url = URI.parse(MYDNS_ENDPOINTS[p.to_sym])

    req = Net::HTTP::Get.new(url.path)
    req.basic_auth(account['username'], account['password'])

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')

    header = "#{title}(#{p}): "
    begin
      res = http.request(req)
      puts "#{header}#{res.message}"
    rescue => e
      puts "#{header}#{e}"
    end
  end
end
