describe('race', function()
    it('should take first to emit', function()
        local scheduler = Rx.Scheduler.new()
        local values = {}
        
        Rx.Observable.race(
            Rx.Observable.timer(100, nil, scheduler),
            Rx.Observable.timer(50, nil, scheduler)
        ):subscribe(function(x) table.insert(values, x) end)
        
        scheduler:advance(50)
        scheduler:advance(50)
        
        expect(#values).to.equal(1)
    end)
end)
