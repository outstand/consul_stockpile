require 'metaractor'
require 'consul_stockpile/logger'
require 'fog/aws'
require 'fog/local' if ENV['FOG_LOCAL']

module ConsulStockpile
  class BackupConsulKV
    include Metaractor

    EVENT_KEY = 'event/kv_update'.freeze

    required :bucket, :name

    def call
      Logger.tagged('Backup') do
        Logger.info 'Starting Consul KV Backup...'

        data = Diplomat::Kv.get('', {recurse: true}, :return)
        if data.nil? || data.empty?
          Logger.info 'Consul kv storage is empty.'
          return
        end

        data.reject!{|kv| kv[:key].start_with?(EVENT_KEY)}

        if data.empty?
          Logger.info 'Consul kv storage only has blacklisted keys.'
          return
        end

        Logger.info "Uploading consul kv backup to bucket #{bucket} as #{name}"

        directory = nil
        if ENV['FOG_LOCAL']
          Logger.debug 'Using fog local storage'
          storage = Fog::Storage.new provider: 'Local', local_root: '/fog'
          directory = storage.directories.create(key: bucket)
        else
          storage = Fog::Storage.new provider: 'AWS', use_iam_profile: true
          directory = storage.directories.get(bucket)
        end

        directory.files.create(
          key: "#{name}.json",
          body: data.to_json
        )

        Logger.info 'Backup complete.'
      end
    end

    private
    def bucket
      context.bucket
    end

    def name
      context.name
    end
  end
end
