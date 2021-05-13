# CodePoints iterator
#
# Copyright 2017-2020 Gandalf Software, Inc., Scott P. Jones
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
iterate(it::CodePoints, state=1) = iterate(it.xs, state)
