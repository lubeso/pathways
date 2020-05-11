# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.4.2
#   kernelspec:
#     display_name: Julia 1.4.0
#     language: julia
#     name: julia-1.4
# ---

using CSV, DataFrames; rd, wr = CSV.read, CSV.write
using DataStructures
using Statistics

ctrace = rd("../../data/info/ctrace.csv") |> DataFrame
ctenrl = rd("../../data/info/ctenroll.csv") |> DataFrame
ctincm = rd("../../data/info/ctincome.csv") |> DataFrame

names(ctrace)

# race statistics
races = names(ctrace)[3:9]
race_prcnt = OrderedDict((:name => ctrace[:,:NAME]),
                    [(race => ctrace[:,race] ./ ctrace[:,:Total]) for race in races]...,
                    (:tract => ctrace[:,:tract]))
ctrace_prcnt = DataFrame(race_prcnt)

ctrace_prcnt |> wr("../../data/info/ctrace-percent.csv")

# +
# enrollment statistics
public = (ctenrl[:,Symbol("Male (Public)")] .+ ctenrl[:,Symbol("Female (Public)")])
private = (ctenrl[:,Symbol("Male (Private)")] .+ ctenrl[:,Symbol("Female (Private)")])

enrl_prcnt = OrderedDict((:name => ctenrl[:,:NAME]),
                          (:public => public),(:private => private),
                          (:tract => ctenrl[:,:tract]))

ctenrl_prcnt = DataFrame(enrl_prcnt)
# -

ctenrl_prcnt |> wr("../../data/info/ctenroll-stats.csv")

# +
# income statistics
brackets = [Symbol("<\$10,000"),Symbol("\$10,000-\$14,999"),Symbol("\$15,000-\$19,999"),
            Symbol("\$20,000-\$24,999"),Symbol("\$25,000-\$29,999"),Symbol("\$30,000-\$34,999"),
            Symbol("\$35,000-\$39,999"),Symbol("\$40,000-\$44,999"),Symbol("\$45,000-\$49,999"),
            Symbol("\$50,000-\$59,999"),Symbol("\$60,000-\$74,999"),Symbol("\$75,000-\$99,999"),
            Symbol("\$100,000-\$124,999"),Symbol("\$125,000-\$149,999"),
            Symbol("\$150,000-\$199,999"),Symbol("\$200,000+")]

incomes = [5000.0,12500.0,17500.0,22500.0,27500.0,32500.0,37500.0,42500.0,
           47500.0,55000.0,67500.0,87500.0,112500.0,137500.0,175000.0,250000.0]

n = nrow(ctincm); mean_income = zeros(n)
b = length(brackets)
for i ∈ 1:n
    row = Array(ctincm[i,brackets]); income = Float64[]
    for j ∈ 1:b
        _income = repeat([incomes[j]],row[j])
        income = vcat(income,_income)
    end
    !isempty(income) ? mean_income[i] = mean(income) : nothing
end
# -

minc = OrderedDict((:name => ctincm[:,:NAME]),
                   (:mean_income => mean_income),
                   (:tract => ctincm[:,:tract]))
ctminc = DataFrame(minc); first(ctminc,6)

ctminc |> wr("../../data/info/ctmean-income.csv")
