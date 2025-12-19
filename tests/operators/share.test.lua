describe('share', function()
    it('should multicast to multiple subscribers', function()
        local call_count = 0
        local obs = Rx.Observable.create(function(observer)
            call_count = call_count + 1
            observer:next(1)
            observer:complete()
        end):share()
        
        obs:subscribe(function() end)
        obs:subscribe(function() end)
        
        expect(call_count).to.equal(1)
    end)
end)
    