describe('Observable.from', function()
    it('should emit from table', function()
        local values = {}
        Rx.Observable.from({10, 20, 30}):subscribe(function(x)
            table.insert(values, x)
        end)
        expect(values).to.equal({10, 20, 30})
    end)
    
    it('should handle empty table', function()
        local completed = false
        Rx.Observable.from({}):subscribe(nil, nil, function()
            completed = true
        end)
        expect(completed).to.equal(true)
    end)
end)