__precompile__(true)
"""
StrAPI package

Copyright 2017-2018 Gandalf Software, Inc., Scott P. Jones
Licensed under MIT License, see LICENSE.md
"""
module StrAPI

using APITools

@api init

_stdout() = @static V6_COMPAT ? STDOUT : stdout

@static if V6_COMPAT
    const pwc = print_with_color
else
    pwc(c, io, str) = printstyled(io, str; color = c)
end
pwc(c, l) = pwc(c, _stdout(), l)

pr_ul(l)     = pwc(:underline, l)
pr_ul(io, l) = pwc(:underline, io, l)

const MaybeSub{T} = Union{T, SubString{T}} where {T<:AbstractString}

const CodeUnitTypes = Union{UInt8, UInt16, UInt32}

symstr(s...)   = Symbol(string(s...))
quotesym(s...) = Expr(:quote, symstr(s...))

@static if V6_COMPAT
    parse_error(s) = throw(ParseError(s))
    _sprint(f, s) = sprint(endof(s), f, s)
    _sprint(f, s, c) = sprint(endof(s), f, s, c)
else
    parse_error(s) = throw(Base.Meta.ParseError(s))
    _sprint(f, s) = sprint(f, s; sizehint=lastindex(s))
    _sprint(f, s, c) = sprint(f, s, c; sizehint=lastindex(s))
end

@api public found, find_result, basetype, charset, encoding, cse, codepoints

@api develop pwc, pr_ul

@api define_public StringError

@api define_develop CodeUnitTypes, CodePoints,
                    MaybeSub, symstr, quotesym, _stdout, _sprint, parse_error

# This trick is necessary to pass the symbol of the macro name, and not try to evaluate it
@eval @api define_develop $(Symbol("@preserve"))

@api base convert, getindex, length, map, collect, in, hash, sizeof, size, strides,
          pointer, unsafe_load, string, read, write, start, next, done, reverse,
          nextind, prevind, typemin, typemax, rem, size, ndims, first, last, eltype,
          isless, isequal, ==, -, +, *, ^, cmp, promote_rule, one, repeat, filter,
          print, show, isimmutable, chop, chomp, replace, ascii, uppercase, lowercase,
          lstrip, rstrip, strip, lpad, rpad, split, rsplit, join, IOBuffer,
          containsnul, unsafe_convert, cconvert

# Conditionally import or export names that are only in v0.6 or in master
@api maybe_public codeunit, codeunits, ncodeunits, codepoint, thisind, firstindex, lastindex

@static if V6_COMPAT
    include("compat.jl")
else # !V6_COMPAT

    using Random

    import Base.GC: @preserve

    function find end
    function ind2chr end
    function chr2ind end

    # Handle changes in array allocation
    create_vector(T, len)  = Vector{T}(undef, len)

    # Add new short name for deprecated hex function
    outhex(v, p=1) = string(v, base=16, pad=p)

    get_iobuffer(siz) = IOBuffer(sizehint=siz)

    const utf8crc         = Base._crc32c
    const is_lowercase    = islowercase
    const is_uppercase    = isuppercase
    const lowercase_first = lowercasefirst
    const uppercase_first = uppercasefirst

    using Base: unsafe_crc32c, Fix2

    # Location of some methods moved from Base.UTF8proc to Base.Unicode
    const UC = Base.Unicode
    const CodeUnits = Base.CodeUnits

    @api base IteratorSize

    const is_letter = isletter

end # !V6_COMPAT

@api define_develop unsafe_crc32c, Fix2, CodeUnits
@api public is_lowercase, is_uppercase, lowercase_first, uppercase_first

function found end
function find_result end

"""Get the base type (of CodeUnitTypes) of a character or aligned/swapped type"""
function basetype end

"""Get the character set used by a string or character type"""
function charset end

"""Get the character set used by a string type"""
function encoding end

"""Get the character set / encoding used by a string type"""
function cse end

function _write end
function _print end
function _isvalid end
function _lowercase end
function _uppercase end
function _titlecase end
@api develop _write, _print, _isvalid, _lowercase, _uppercase, _titlecase

include("errors.jl")
include("traits.jl")
include("codepoints.jl")
include("uni.jl")

@api define_module Uni, StrErrors, UC

# Possibly import functions, give new names with underscores

# Todo: Should probably have a @api function for importing/defining renamed functions
namlst = Symbol[]
for (pref, lst) in
    ((0,
      ((:textwidth,      :text_width),
       (:occursin,       :occurs_in),
       (:startswith,     :starts_with),
       (:endswith,       :ends_with))),

     (1,
      ((:xdigit, :hex_digit),
       (:cntrl,  :control),
       (:punct,  :punctuation),
       (:print,  :printable))),

     (2, (:ascii, :digit, :space, :numeric,
          :valid, :defined, :assigned, :empty,
          :latin, :bmp, :unicode))
     ), nam in lst

    oldname, newname =
        (pref == 0 ? nam : pref == 1
         ? (symstr("is", nam[1]), symstr("is_", nam[2]))
         : (symstr("is", nam), symstr("is_", nam)))

    if isdefined(Base, oldname)
        eval(Expr(:const, Expr(:(=), newname, oldname)))
    else
        eval(Expr(:function, newname))
    end
    push!(namlst, newname)
end
@eval @api public $(namlst...)

# Handle renames where function was deprecated

# Todo: have function for defining and making public
function is_alphabetic end
function is_alphanumeric end
function is_graphic end
@api public is_alphabetic, is_alphanumeric, is_graphic, is_letter

# import and add new names from UTF8proc/Unicode

const is_grapheme_break  = UC.isgraphemebreak
const is_grapheme_break! = UC.isgraphemebreak!
for nam in (:graphemes, :category_code, :category_abbrev, :category_string)
    eval(parse(Expr, "const $nam = UC.$nam"))
end

@api public graphemes, is_grapheme_break, is_grapheme_break!,
            category_code, category_abbrev, category_string

const fnd = find
@api public fnd, find

@api define_develop create_vector, outhex, get_iobuffer
@api develop utf8crc, ind2chr, chr2ind

# Operations for find/search operations

abstract type FindOp end

struct First <: FindOp end
struct Last  <: FindOp end
struct Next  <: FindOp end
struct Prev  <: FindOp end
struct Each  <: FindOp end
struct All   <: FindOp end

abstract type Direction <: FindOp end

struct Fwd   <: Direction end
struct Rev   <: Direction end

@api define_public FindOp, Direction, Fwd, Rev, First, Last, Next, Prev, Each, All

@api freeze

end # module StrAPI
