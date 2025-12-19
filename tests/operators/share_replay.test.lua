describe('share_replay', function()
    it('should replay to late subscribers', function()
        local obs = Rx.Observable.of(1, 2, 3):share_replay(2)
        
        obs:subscribe(function () end)  -- First subscriber consumes all values
        local values = {}
        obs:subscribe(function(x) table.insert(values, x) end)
        
        expect(#values).to.equal(2)
    end)
end)