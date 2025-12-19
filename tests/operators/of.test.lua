describe('Observable.of', function()
    it('should emit values', function()
        local values = {}
        Rx.Observable.of(1, 2, 3):subscribe(function(x)
            table.insert(values, x)
        end)
        expect(values).to.equal({1, 2, 3})
    end)
    
    it('should handle empty list', function()
        local completed = false
        Rx.Observable.of():subscribe(nil, nil, function()
            completed = true
        end)
        expect(completed).to.equal(true)
    end)
end)