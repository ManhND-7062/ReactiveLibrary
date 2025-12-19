describe('map', function()
        it('should transform values', function()
            local values = {}
            Rx.Observable.of(1, 2, 3)
                :map(function(x) return x * 2 end)
                :subscribe(function(x) table.insert(values, x) end)
            expect(values).to.equal({2, 4, 6})
        end)
        
        it('should handle errors in transform function', function()
            local error_caught = nil
            Rx.Observable.of(1, 2, 3)
                :map(function(x) error("map error") end)
                :subscribe(nil, function(err) error_caught = err end)
            expect(error_caught).to_not.equal(nil)
        end)
    end)