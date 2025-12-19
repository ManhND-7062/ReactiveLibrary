describe('throttle', function()
    it('should throttle emissions', function()
        local scheduler = Rx.Scheduler.new()
        local subject = Rx.Subject.new()
        local values = {}
        
        subject:throttle(100, scheduler)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject:next(1)
        scheduler:advance(50)
        subject:next(2)
        scheduler:advance(50)
        subject:next(3)
        scheduler:advance(50)
        
        expect(values[1]).to.equal(1)
    end)
    
    it('should handle leading and trailing config', function()
        local scheduler = Rx.Scheduler.new()
        local subject = Rx.Subject.new()
        local values = {}
        
        subject:throttle(100, scheduler, {leading = false, trailing = true})
            :subscribe(function(x) table.insert(values, x) end)
        
        subject:next(1)
        subject:next(2)
        scheduler:advance(100)
        
        expect(#values).to.be.a('number')
    end)
end)