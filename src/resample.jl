using TimeSeries: TimeArray, collapse
using TimeFrames: TimeFrame, dt_grouper
import Base: mean, sum, getindex

abstract AbstractAction

immutable TimeArrayResampler <: AbstractAction
    ta::TimeArray
    tf::TimeFrame
end

immutable GroupBy
    action::AbstractAction
    by
end

function resample(ta::TimeArray, tf::TimeFrame)
    TimeArrayResampler(ta, tf)
end

function resample(ta::TimeArray, tf)
    resample(ta, TimeFrame(tf))
end

function getindex(action::AbstractAction, by...)
    GroupBy(action, by)
end

function ohlc(grp::GroupBy)
    ohlc(grp.action)
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
    col_ohlc = ["Open", "High", "Low", "Close"]
    if length(ta.colnames) == 1
        colnames = col_ohlc
    else
        colnames = String[]
        for col in ta.colnames
            for col2 in col_ohlc
                push!(colnames, col * "." * col2)
            end
        end
    end
    ta_ohlc = TimeArray(ts, a_ohlc, colnames)
end

function mean(grp::GroupBy)
    ohlc(grp.action)
end

function mean(resampler::TimeArrayResampler)
    f_group = dt_grouper(resampler.tf, eltype(resampler.ta.timestamp))
    collapse(resampler.ta, f_group, dt -> f_group(first(dt)), mean)
end

function sum(grp::GroupBy)
    sum(grp.action)
end

function sum(resampler::TimeArrayResampler)
    f_group = dt_grouper(resampler.tf, eltype(resampler.ta.timestamp))
    collapse(resampler.ta, f_group, dt -> f_group(first(dt)), sum)
end
