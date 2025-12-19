describe('delay_when', function()
    it('should delay by dynamic duration', function()
        local values = {}
        local scheduler = Rx.Scheduler.new()
        
        Rx.Observable.of(1, 2)
            :delay_when(function(x)
                return Rx.Observable.timer(x * 10, nil, scheduler)
            end)
            :subscribe(
            function(x)
                table.insert(values, x)
             end,function(err) print("there is an error", err) end)
        
        scheduler:advance(10)
        expect(values[1]).to.equal(1)
        scheduler:advance(10)
        expect(values[2]).to.equal(2)
    end)
end)