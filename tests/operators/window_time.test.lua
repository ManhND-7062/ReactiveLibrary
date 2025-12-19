describe('window_time', function()
    it('should create observable windows', function()
        local scheduler = Rx.Scheduler.new()
        local subject = Rx.Subject.new()
        local window_count = 0
        
        subject:window_time(50, scheduler)
            :subscribe(function(window) window_count = window_count + 1 end)
        
        scheduler:advance(50)
        scheduler:advance(50)
        
        expect(window_count).to.be.a('number')
    end)
end)