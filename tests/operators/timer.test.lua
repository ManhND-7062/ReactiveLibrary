describe('Observable.timer', function()
    it('should emit after delay', function()
        local scheduler = Rx.Scheduler.new()
        local value = nil
        
        Rx.Observable.timer(100, nil, scheduler):subscribe(function(x)
            value = x
        end)
        
        expect(value).to.equal(nil)
        scheduler:advance(100)
        expect(value).to.equal(0)
    end)
    
    it('should emit periodically', function()
        local scheduler = Rx.Scheduler.new()
        local count = 0
        
        local sub = Rx.Observable.timer(50, 25, scheduler):subscribe(function(x)
            count = count + 1
        end)
        
        scheduler:advance(50)
        expect(count).to.equal(1)
        scheduler:advance(25)
        expect(count).to.equal(2)
        sub:unsubscribe()
    end)
end)