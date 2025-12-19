describe('find_index', function()
    it('should find index of first match', function()
        local index = nil
        Rx.Observable.of(10, 20, 30, 40)
            :find_index(function(x) return x > 25 end)
            :subscribe(function(x) index = x end)
        expect(index).to.equal(2)
    end)
    
    it('should return -1 if no match', function()
        local index = nil
        Rx.Observable.of(1, 2, 3)
            :find_index(function(x) return x > 10 end)
            :subscribe(function(x) index = x end)
        expect(index).to.equal(-1)
    end)
end)