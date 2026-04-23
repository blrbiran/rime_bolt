-- br_datetime.lua
-- 整合日期和时间输入，可在方案中配置触发关键字
--
-- 触发关键字（可在 schema 中配置）:
--   date: d   日期
--   time: t   时间
--
-- 输入 d 输出:
--   20260422        (年月日紧凑格式)
--   260422          (年月日短格式)
--   0422            (月日格式)
--   2026年4月22日   (中文日期)
--   4月22日         (中文月日)
--   April 22nd, 2026 (英文日期)
--
-- 输入 t 输出:
--   14:30           (时:分)
--   1430            (时分紧凑)
--   14点30分        (中文时间)
--   14:30:00        (时:分:秒)

local function yield_cand(seg, text)
    local cand = Candidate('', seg.start, seg._end, text, '')
    cand.quality = 100
    yield(cand)
end

local M = {}

function M.init(env)
    local config = env.engine.schema.config
    env.name_space = env.name_space:gsub('^*', '')
    M.date = config:get_string(env.name_space .. '/date') or 'd'
    M.time = config:get_string(env.name_space .. '/time') or 't'
end

function M.func(input, seg, env)
    local current_time = os.time()

    -- 日期
    if input == M.date then
        yield_cand(seg, os.date('%Y%m%d', current_time))
        yield_cand(seg, string.sub(os.date('%Y%m%d', current_time), 3))
        yield_cand(seg, os.date('%m%d', current_time))

        local num_m = os.date('%m', current_time) + 0
        local num_d = os.date('%d', current_time) + 0
        yield_cand(seg, os.date('%Y年', current_time) .. tostring(num_m) .. '月' .. tostring(num_d) .. '日')
        yield_cand(seg, tostring(num_m) .. '月' .. tostring(num_d) .. '日')

        -- 英文日期
        local month_names = {
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        }
        local day = tonumber(os.date('%d', current_time))
        local month = tonumber(os.date('%m', current_time))
        local year = os.date('%Y', current_time)
        local suffix = 'th'
        if day % 10 == 1 and day ~= 11 then
            suffix = 'st'
        elseif day % 10 == 2 and day ~= 12 then
            suffix = 'nd'
        elseif day % 10 == 3 and day ~= 13 then
            suffix = 'rd'
        end
        yield_cand(seg, month_names[month] .. ' ' .. day .. suffix .. ', ' .. year)

    -- 时间
    elseif input == M.time then
        yield_cand(seg, os.date('%H:%M', current_time))
        yield_cand(seg, os.date('%H%M', current_time))
        yield_cand(seg, os.date('%H点%M分', current_time))
        yield_cand(seg, os.date('%H:%M:%S', current_time))
    end
end

return M
