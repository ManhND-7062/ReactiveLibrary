--- Horrible script to concatenate everything in /src into a single rx.lua file.
-- @usage lua tools/build.lua [distribution=base]
-- @arg {string='base'} distribution - Type of distribution to build, either 'base' or 'luvit'.

local files = {
    'src/observer.lua',
    'src/subscription.lua',
    'src/scheduler.lua',
    'src/observable.lua',

    'src/Subjects/subject.lua',
    'src/Subjects/behaviorsubject.lua',
    'src/Subjects/replaysubject.lua',

    'src/Operators/Creation/of.lua',
    'src/Operators/Creation/from.lua',
    'src/Operators/Creation/interval.lua',
    'src/Operators/Creation/timer.lua',
    'src/Operators/Creation/range.lua',
    'src/Operators/Creation/marble_to_observable.lua',

    'src/Operators/Combination/combine_with.lua',
    'src/Operators/Combination/concat.lua',
    'src/Operators/Combination/merge_with.lua',
    'src/Operators/Combination/partition.lua',
    'src/Operators/Combination/publish.lua',
    'src/Operators/Combination/race.lua',
    'src/Operators/Combination/share.lua',
    'src/Operators/Combination/share_replay.lua',
    'src/Operators/Combination/start_with.lua',
    'src/Operators/Combination/with_lastest_from.lua',
    'src/Operators/Combination/zip.lua',

    'src/Operators/Transformation/buffer_count.lua',
    'src/Operators/Transformation/buffer_time.lua',
    'src/Operators/Transformation/concat_map.lua',
    'src/Operators/Transformation/dematerialize.lua',
    'src/Operators/Transformation/exhaust_map.lua',
    'src/Operators/Transformation/flat_map.lua',
    'src/Operators/Transformation/group_by.lua',
    'src/Operators/Transformation/map.lua',
    'src/Operators/Transformation/materialize.lua',
    'src/Operators/Transformation/pairwise.lua',
    'src/Operators/Transformation/reduce.lua',
    'src/Operators/Transformation/scan.lua',
    'src/Operators/Transformation/switch_map.lua',
    'src/Operators/Transformation/window_time.lua',

    'src/Operators/Filtering/default_if_empty.lua',
    'src/Operators/Filtering/distinct_until_changed.lua',
    'src/Operators/Filtering/distinct.lua',
    'src/Operators/Filtering/element_at.lua',
    'src/Operators/Filtering/every.lua',
    'src/Operators/Filtering/filter.lua',
    'src/Operators/Filtering/find_index.lua',
    'src/Operators/Filtering/find.lua',
    'src/Operators/Filtering/first.lua',
    'src/Operators/Filtering/ignore_elements.lua',
    'src/Operators/Filtering/is_empty.lua',
    'src/Operators/Filtering/last.lua',
    'src/Operators/Filtering/skip_until.lua',
    'src/Operators/Filtering/skip_while.lua',
    'src/Operators/Filtering/skip.lua',
    'src/Operators/Filtering/some.lua',
    'src/Operators/Filtering/take_until.lua',
    'src/Operators/Filtering/take_while.lua',
    'src/Operators/Filtering/take.lua',

    'src/Operators/Error Handling/catch_error.lua',
    'src/Operators/Error Handling/finalize.lua',
    'src/Operators/Error Handling/retry.lua',

    'src/Operators/Time/audit.lua',
    'src/Operators/Time/debounce.lua',
    'src/Operators/Time/delay_when.lua',
    'src/Operators/Time/delay.lua',
    'src/Operators/Time/sample.lua',
    'src/Operators/Time/throttle.lua',
    'src/Operators/Time/timeout.lua',

    'src/Operators/Utility/collect.lua',
    'src/Operators/Utility/count.lua',
    'src/Operators/Utility/log.lua',
    'src/Operators/Utility/tap.lua',
    'src/Operators/Utility/to_array.lua',

    'src/utils.lua',
}

local header = [[
-- RxLua - Reactive Extensions for lua
]]



local footer = [[return {
  Utils = Utils,
  Subscription = Subscription,
  Observer = Observer,
  Observable = Observable,
  Scheduler = Scheduler,
  Subject = Subject,
  BehaviorSubject = BehaviorSubject,
  ReplaySubject = ReplaySubject
}]]

local output = ''

for _, filename in ipairs(files) do
  local file = io.open(filename)

  if not file then
    error('error opening "' .. filename .. '"')
  end

  local str = file:read('*all')
  file:close()

  str = '\n' .. str .. '\n'
  str = str:gsub('\n(local[^\n]+require.[^\n]+)', '')
  str = str:gsub('\n(return[^\n]+)', '')
  str = str:gsub('^%s+', ''):gsub('%s+$', '')
  output = output .. str .. '\n\n'
end

local distribution = arg[1] or 'base'
local destination, components

if distribution == 'base' then
  destination = 'rx.lua'
  components = { header, output, footer }
else
  error('Invalid distribution specified.')
end

local file = io.open(destination, 'w')

if file then
  file:write(table.concat(components, ''))
  file:close()
end