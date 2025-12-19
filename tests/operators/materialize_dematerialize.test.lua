describe('materialize / dematerialize', function()
    it('should convert to notifications', function()
        local notifications = {}
        Rx.Observable.of(1, 2)
            :materialize()
            :subscribe(function(n) table.insert(notifications, n) end)
        
        expect(notifications[1].kind).to.equal('next')
        expect(notifications[3].kind).to.equal('complete')
    end)
    
    it('should convert back from notifications', function()
        local values = {}
        Rx.Observable.of(1, 2)
            :materialize()
            :dematerialize()
            :subscribe(function(x) table.insert(values, x) end)
        
        expect(values).to.equal({1, 2})
    end)
end)