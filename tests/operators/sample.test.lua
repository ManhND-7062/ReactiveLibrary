describe('sample / sample_time', function()
    it('should sample at intervals', function()
        local scheduler = Rx.Scheduler.new()
        local subject = Rx.Subject.new()
        local values = {}
        
        subject:sample(50, scheduler)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject:next(1)
        scheduler:advance(50)
        subject:next(2)
        scheduler:advance(50)
        
        expect(#values).to.be.a('number')
    end)
end)