# CodePoints iterator
#
# Copyright 2017-2018 Gandalf Software, Inc., Scott P. Jones
# Licensed under MIT License, see LICENSE.md

struct CodePoints{T<:AbstractString}
    xs::T
end

"""
    codepoints(str)

An iterator that generates the code points of a string

# Examples
```jldoctest
julia> a = str("abc\U1f596")

julia> collect(a)

julia> collect(codepoints(a))
```
"""
codepoints(xs) = CodePoints(xs)
eltype(::Type{<:CodePoints{S}}) where {S} = eltype(S)
length(it::CodePoints) = length(it.xs)
start(it::CodePoints) = start(it.xs)
done(it::CodePoints, state) = done(it.xs, state)
next(it::CodePoints, state) = next(it.xs, state)
