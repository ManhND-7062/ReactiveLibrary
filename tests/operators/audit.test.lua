describe('audit / audit_time', function()
    it('should emit most recent after silence', function()
        local scheduler = Rx.Scheduler.new()
        local subject = Rx.Subject.new()
        local values = {}
        
        subject:audit(50, scheduler)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject:next(1)
        subject:next(2)
        scheduler:advance(50)
        
        expect(values[1]).to.equal(2)
    end)
end)