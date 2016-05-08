require 'consul_stockpile/base'
require 'consul_stockpile/logger'
require 'fog/aws'
require 'fog/local' if ENV['FOG_LOCAL']

module ConsulStockpile
  class DownloadBackup < Base
    attr_accessor :bucket

    def initialize(bucket:)
      self.bucket = bucket
    end

    def call
      Logger.info "Downloading consul kv backup from bucket #{self.bucket}"

      bucket = nil
      if ENV['FOG_LOCAL']
        Logger.debug 'Using fog local storage'
        storage = Fog::Storage.new provider: 'Local', local_root: '/fog'
        bucket = storage.directories.create(key: self.bucket)
      else
        storage = Fog::Storage.new provider: 'AWS', use_iam_profile: true
        bucket = storage.directories.get(self.bucket)
      end

      body = nil
      last_modified = nil
      bucket.files.each do |file|
        next if last_modified != nil && file.last_modified < last_modified
        last_modified = file.last_modified
        body = file.body
      end

      Logger.info 'Download complete.'

      OpenStruct.new(
        json_body: body
      )
    end
  end
end
