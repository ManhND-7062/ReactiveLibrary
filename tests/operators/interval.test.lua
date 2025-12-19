describe('Observable.interval', function()
        it('should emit with scheduler', function()
            local scheduler = Rx.Scheduler.new()
            local values = {}
            
            local sub = Rx.Observable.interval(10, scheduler):subscribe(function(x)
                table.insert(values, x)
            end)
            
            scheduler:advance(10)
            scheduler:advance(10)
            sub:unsubscribe()
            
            expect(#values).to.equal(2)
        end)
    end)