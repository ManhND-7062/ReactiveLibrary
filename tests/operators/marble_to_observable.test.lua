describe('marble_to_observable', function()
    it('should create observable from marble diagram', function()
        local scheduler = Rx.Scheduler.new()
        local values = {}
        
        Rx.Observable.marble_to_observable("a-b-c-|", scheduler, 10)
            :subscribe(function(x) table.insert(values, x) end)
        
        Rx.Utils.run_scheduler(scheduler, 70, 10)
        
        expect(#values).to.equal(3)
    end)
    
    it('should handle error marker', function()
        local scheduler = Rx.Scheduler.new()
        local error_caught = nil
        
        Rx.Observable.marble_to_observable("a-#", scheduler, 10)
            :subscribe(nil, function(err) error_caught = err end)
        
        Rx.Utils.run_scheduler(scheduler, 30, 10)
        
        expect(error_caught).to_not.equal(nil)
    end)
end)