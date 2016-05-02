module ConsulStockpile
  module ConsulLock
    extend self

    def with_lock(key:)
      sessionid = nil
      locked = false
      sessionid = Diplomat::Session.create(Name: "#{key}.lock")
      locked = Diplomat::Lock.wait_to_acquire(key, sessionid)

      yield
    ensure
      if sessionid != nil
        Diplomat::Lock.release(key, sessionid) if locked
        Diplomat::Session.destroy(sessionid)
      end
    end

  end
end
