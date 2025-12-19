describe('switch_map', function()
    it('should switch to latest', function()
        local subject = Rx.Subject.new()
        local values = {}
        
        subject:switch_map(function(x)
            return Rx.Observable.of(x * 10)
        end)
        :subscribe(function(x) table.insert(values, x) end)
        
        subject:next(1)
        subject:next(2)
        subject:next(3)
        
        expect(values).to.equal({10, 20, 30})
    end)
    
    it('should handle errors in project function', function()
        local error_caught = nil
        Rx.Observable.of(1)
            :switch_map(function(x) error("switchmap error") end)
            :subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to_not.equal(nil)
    end)
end)