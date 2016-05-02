require 'consul_stockpile/base'
require 'fog/aws'
require 'fog/local' if ENV['FOG_LOCAL']

module ConsulStockpile
  class BackupConsulKV < Base
    EVENT_KEY = 'event/kv_update'.freeze

    attr_accessor :bucket, :name

    def initialize(bucket:, name:)
      self.bucket = bucket
      self.name = name
    end

    def call
      puts 'Starting Consul KV Backup...'

      data = Diplomat::Kv.get('', {recurse: true}, :return)
      if data.empty?
        puts 'Consul kv storage is empty.'
        return
      end

      data.reject!{|kv| kv[:key].start_with?(EVENT_KEY)}

      if data.empty?
        puts 'Consul kv storage only has blacklisted keys.'
        return
      end

      puts "Uploading consul kv backup to bucket #{self.bucket} as #{self.name}"

      bucket = nil
      if ENV['FOG_LOCAL']
        puts 'Using fog local storage'
        storage = Fog::Storage.new provider: 'Local', local_root: '/fog'
        bucket = storage.directories.create(key: self.bucket)
      else
        storage = Fog::Storage.new provider: 'AWS', use_iam_profile: true
        bucket = storage.directories.get(self.bucket)
      end

      bucket.files.create(
        key: "#{self.name}.json",
        body: data.to_json
      )

      puts 'Backup complete.'
    end
  end
end
