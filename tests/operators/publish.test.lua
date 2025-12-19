describe('publish', function()
    it('should create connectable observable', function()
        local values = {}
        local published = Rx.Observable.of(1, 2, 3):publish()
        
        published.observable:subscribe(function(x) table.insert(values, x) end)
        expect(#values).to.equal(0)
        
        published.connect()
        expect(values).to.equal({1, 2, 3})
    end)
end)