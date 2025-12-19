describe('debounce / debounce_time', function()
    it('should debounce emissions', function()
        local scheduler = Rx.Scheduler.new()
        local subject = Rx.Subject.new()
        local values = {}
        
        subject:debounce(50, scheduler)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject:next(1)
        scheduler:advance(20)
        subject:next(2)
        scheduler:advance(20)
        subject:next(3)
        scheduler:advance(50)
        
        expect(values).to.equal({3})
    end)
    
    it('should emit last value on complete', function()
        local scheduler = Rx.Scheduler.new()
        local subject = Rx.Subject.new()
        local values = {}
        
        subject:debounce(50, scheduler)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject:next(1)
        subject:complete()
        
        expect(values).to.equal({1})
    end)
end)    