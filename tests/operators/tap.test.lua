describe('tap', function()
    it('should perform side effects', function()
        local side_effects = {}
        local values = {}
        
        Rx.Observable.of(1, 2, 3)
            :tap(function(x) table.insert(side_effects, x) end)
            :subscribe(function(x) table.insert(values, x) end)
        
        expect(side_effects).to.equal({1, 2, 3})
        expect(values).to.equal({1, 2, 3})
    end)
    
    it('should not affect stream on error in tap', function()
        local values = {}
        
        Rx.Observable.of(1, 2, 3)
            :tap(function(x) error("tap error") end)
            :subscribe(function(x) table.insert(values, x) end)
        
        expect(values).to.equal({1, 2, 3})
    end)
end)