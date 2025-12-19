describe('timeout', function()
    it('should error on timeout', function()
        local scheduler = Rx.Scheduler.new()
        local error_msg = nil
        
        Rx.Observable.create(function(observer)
            -- Never emits
        end)
        :timeout(100, scheduler)
        :subscribe(nil, function(err) error_msg = err end)
        
        scheduler:advance(100)
        expect(error_msg).to.match("Timeout")
    end)
    
    it('should reset timer on each emission', function()
        local scheduler = Rx.Scheduler.new()
        local subject = Rx.Subject.new()
        local error_msg = nil
        
        subject:timeout(100, scheduler)
            :subscribe(nil, function(err) error_msg = err end)
        
        scheduler:advance(50)
        subject:next(1)
        scheduler:advance(50)
        subject:next(2)
        
        expect(error_msg).to.equal(nil)
    end)
end)