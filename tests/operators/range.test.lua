describe('Observable.range', function()
    it('should emit range', function()
        local values = {}
        Rx.Observable.range(5, 3):subscribe(function(x)
            table.insert(values, x)
        end)
        expect(values).to.equal({5, 6, 7})
    end)
    
    it('should handle zero count', function()
        local values = {}
        Rx.Observable.range(1, 0):subscribe(function(x)
            table.insert(values, x)
        end)
        expect(#values).to.equal(0)
    end)
end)