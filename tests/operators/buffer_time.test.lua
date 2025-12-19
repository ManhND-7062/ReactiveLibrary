describe('buffer_time', function()
    it('should buffer by time', function()
        local scheduler = Rx.Scheduler.new()
        local subject = Rx.Subject.new()
        local buffers = {}
        
        subject:buffer_time(50, scheduler)
            :subscribe(function(buf) table.insert(buffers, buf) end)
        
        subject:next(1)
        subject:next(2)
        scheduler:advance(50)
        subject:next(3)
        scheduler:advance(50)
        
        expect(#buffers).to.equal(2)
        expect(buffers[1]).to.equal({1, 2})
    end)
end)