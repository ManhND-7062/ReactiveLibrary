describe('delay', function()
    it('should delay emissions', function()
        local scheduler = Rx.Scheduler.new()
        local values = {}
        
        Rx.Observable.of(1, 2, 3)
            :delay(100, scheduler)
            :subscribe(function(x) table.insert(values, x) end)
        
        expect(#values).to.equal(0)
        scheduler:advance(100)
        expect(values).to.equal({1, 2, 3})
    end)
    
    it('should delay errors', function()
        local scheduler = Rx.Scheduler.new()
        local error_caught = nil
        
        Rx.Observable.create(function(obs) obs:error("test") end)
            :delay(100, scheduler)
            :subscribe(nil, function(err) error_caught = err end)
        
        expect(error_caught).to.equal(nil)
        scheduler:advance(100)
        expect(error_caught).to_not.equal(nil)
    end)
end)
