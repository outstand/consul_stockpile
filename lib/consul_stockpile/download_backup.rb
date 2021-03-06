require 'metaractor'
require 'consul_stockpile/logger'
require 'fog/aws'
require 'fog/local' if ENV['FOG_LOCAL']

module ConsulStockpile
  class DownloadBackup
    include Metaractor

    required :bucket

    def call
      Logger.info "Downloading consul kv backup from bucket #{bucket}"

      directory = nil
      if ENV['FOG_LOCAL']
        Logger.debug 'Using fog local storage'
        storage = Fog::Storage.new provider: 'Local', local_root: '/fog'
        directory = storage.directories.create(key: bucket)
      else
        storage = Fog::Storage.new provider: 'AWS', use_iam_profile: true
        directory = storage.directories.get(bucket)
      end

      body = nil
      last_modified = nil
      directory.files.each do |file|
        next if last_modified != nil && file.last_modified < last_modified
        last_modified = file.last_modified
        body = file.body
      end

      Logger.info 'Download complete.'

      context.json_body = body
    end

    private
    def bucket
      context.bucket
    end
  end
end
