describe('take_until', function()
    it('should take until notifier emits', function()
        local subject = Rx.Subject.new()
        local notifier = Rx.Subject.new()
        local values = {}
        
        subject:take_until(notifier)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject:next(1)
        subject:next(2)
        notifier:next('stop')
        subject:next(3)
        
        expect(values).to.equal({1, 2})
    end)
end)