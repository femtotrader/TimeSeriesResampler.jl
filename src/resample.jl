using TimeSeries: TimeArray, collapse
using TimeFrames: TimeFrame, dt_grouper
import Base: mean, sum

immutable TimeArrayResampler
    ta::TimeArray
    tf::TimeFrame
end

function resample(ta::TimeArray, tf::TimeFrame)
    TimeArrayResampler(ta, tf)
end

function resample(ta::TimeArray, tf)
    resample(ta, TimeFrame(tf))
end

function ohlc(resampler::TimeArrayResampler)
    ta = resampler.ta
    f_group = dt_grouper(resampler.tf, eltype(ta.timestamp))
    ta_o = collapse(ta, f_group, first, first)
    ta_h = collapse(ta, f_group, first, maximum)
    ta_l = collapse(ta, f_group, first, minimum)
    ta_c = collapse(ta, f_group, first, last)
    a_ohlc = hcat(ta_o.values, ta_h.values, ta_l.values, ta_c.values)
    ts = map(f_group, ta_o.timestamp)
    ta_ohlc = TimeArray(ts, a_ohlc, ["Open", "High", "Low", "Close"])
end

function mean(resampler::TimeArrayResampler)
    f_group = dt_grouper(resampler.tf, eltype(resampler.ta.timestamp))
    collapse(resampler.ta, f_group, dt -> f_group(first(dt)), mean)
end

function sum(resampler::TimeArrayResampler)
    f_group = dt_grouper(resampler.tf, eltype(resampler.ta.timestamp))
    collapse(resampler.ta, f_group, dt -> f_group(first(dt)), sum)
end
