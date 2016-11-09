using TimeSeries: TimeArray, collapse
using TimeFrames: TimeFrame, dt_grouper
import Base: mean, sum

type TimeArrayResampler
    ta::TimeArray
    tf::TimeFrame
end

function resample(ta::TimeArray, tf::TimeFrame)
    TimeArrayResampler(ta, tf)
end

function ohlc(resampler::TimeArrayResampler)
    ta = resampler.ta
    f_group = resampler.tf.f_group
    ta_o = collapse(ta, f_group, first, first)
    ta_h = collapse(ta, f_group, first, maximum)
    ta_l = collapse(ta, f_group, first, minimum)
    ta_c = collapse(ta, f_group, first, last)
    a_ohlc = hcat(ta_o.values, ta_h.values, ta_l.values, ta_c.values)
    ta_ohlc = TimeArray(ta_o.timestamp, a_ohlc, ["Open", "High", "Low", "Close"])
end

function mean(resampler::TimeArrayResampler)
    collapse(resampler.ta, dt_grouper(resampler.tf), first, mean)
end

function sum(resampler::TimeArrayResampler)
    collapse(resampler.ta, dt_grouper(resampler.tf), first, sum)
end
