describe('partition', function()
    it('should split into two streams', function()
        local evens, odds = Rx.Observable.of(1, 2, 3, 4, 5, 6)
            :partition(function(x) return x % 2 == 0 end)
        
        local even_values = {}
        local odd_values = {}
        
        evens:subscribe(function(x) table.insert(even_values, x) end)
        odds:subscribe(function(x) table.insert(odd_values, x) end)
        
        expect(even_values).to.equal({2, 4, 6})
        expect(odd_values).to.equal({1, 3, 5})
    end)
end)