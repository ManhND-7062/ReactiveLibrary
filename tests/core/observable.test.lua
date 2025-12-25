describe('Observable', function()
    it('should create an observable', function()
        local obs = Rx.Observable.create(function(observer)
            observer:next(1)
            observer:complete()
        end)
        expect(obs).to.exist()
    end)
    
    it('should subscribe and emit values', function()
        local values = {}
        Rx.Observable.of(1, 2, 3):subscribe(function(x)
            table.insert(values, x)
        end)
        expect(values).to.equal({1, 2, 3})
    end)
    
    it('should handle errors', function()
        local error_msg = nil
        Rx.Observable.create(function(observer)
            observer:error("tests error")
        end):subscribe(nil, function(err)
            error_msg = err
        end)
        expect(error_msg).to.equal("tests error")
    end)
    
    it('should complete', function()
        local completed = false
        Rx.Observable.of(1):subscribe(nil, nil, function()
            completed = true
        end)
        expect(completed).to.equal(true)
    end)
    
    it('should handle error in subscribe function', function()
        local error_caught = nil
        Rx.Observable.create(function(observer)
            observer:error("subscribe error")
        end):subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to_not.equal(nil)
    end)
end)

--- creation operator group
dofile('tests/operators/from.test.lua')
dofile('tests/operators/interval.test.lua')
dofile('tests/operators/marble_to_observable.test.lua')
dofile('tests/operators/of.test.lua')
dofile('tests/operators/range.test.lua')
dofile('tests/operators/timer.test.lua')


--- combination operator group
dofile('tests/operators/combine_with.test.lua')
dofile('tests/operators/concat.test.lua')
dofile('tests/operators/merge_with.test.lua')
dofile('tests/operators/partition.test.lua')
dofile('tests/operators/publish.test.lua')
dofile('tests/operators/race.test.lua')
dofile('tests/operators/share_replay.test.lua')
dofile('tests/operators/share.test.lua')
dofile('tests/operators/start_with.test.lua')
dofile('tests/operators/with_lastest_from.test.lua')
dofile('tests/operators/zip.test.lua')

--- transfromation operator group
dofile('tests/operators/buffer_count.test.lua')
dofile('tests/operators/buffer_time.test.lua')
dofile('tests/operators/concat_map.test.lua')
dofile('tests/operators/exhaust_map.test.lua')
dofile('tests/operators/flat_map.test.lua')
dofile('tests/operators/group_by.test.lua')
dofile('tests/operators/map.test.lua')
dofile('tests/operators/materialize_dematerialize.test.lua')
dofile('tests/operators/pairwise.test.lua')
dofile('tests/operators/reduce.test.lua')
dofile('tests/operators/scan.test.lua')
dofile('tests/operators/switch_map.test.lua')
dofile('tests/operators/window_time.test.lua')

--- filtering operator group
dofile('tests/operators/default_if_empty.test.lua')
dofile('tests/operators/distinct_until_changed.test.lua')
dofile('tests/operators/distinct.test.lua')
dofile('tests/operators/element_at.test.lua')
dofile('tests/operators/every.test.lua')
dofile('tests/operators/filter.test.lua')
dofile('tests/operators/find.test.lua')
dofile('tests/operators/first.test.lua')
dofile('tests/operators/ignore_elements.test.lua')
dofile('tests/operators/is_empty.test.lua')
dofile('tests/operators/last.test.lua')
dofile('tests/operators/skip_until.test.lua')
dofile('tests/operators/skip_while.test.lua')
dofile('tests/operators/skip.test.lua')
dofile('tests/operators/some.test.lua')
dofile('tests/operators/take_until.test.lua')
dofile('tests/operators/take_while.test.lua')
dofile('tests/operators/sample.test.lua')
dofile('tests/operators/take.test.lua')

--- errors handling operator group
dofile('tests/operators/catch_error.test.lua')
dofile('tests/operators/retry.test.lua')
dofile('tests/operators/finalize.test.lua')

--- time operator group
dofile('tests/operators/audit.test.lua')
dofile('tests/operators/debounce.test.lua')
dofile('tests/operators/delay_when.test.lua')
dofile('tests/operators/delay.test.lua')
dofile('tests/operators/sample.test.lua')
dofile('tests/operators/throttle.test.lua')
dofile('tests/operators/timeout.test.lua')

--- utility operator group
dofile('tests/operators/collect.test.lua')
dofile('tests/operators/count.test.lua')
dofile('tests/operators/tap.test.lua')
dofile('tests/operators/to_array.test.lua')

