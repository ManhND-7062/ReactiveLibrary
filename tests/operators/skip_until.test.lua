describe('skip_until', function()
    it('should skip until notifier emits', function()
        local subject = Rx.Subject.new()
        local notifier = Rx.Subject.new()
        local values = {}
        
        subject:skip_until(notifier)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject:next(1)
        notifier:next('start')
        subject:next(2)
        subject:next(3)
        
        expect(values).to.equal({2, 3})
    end)
end)