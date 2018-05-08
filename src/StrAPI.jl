__precompile__(true)
"""
StrAPI package

Copyright 2017-2018 Gandalf Software, Inc., Scott P. Jones
Licensed under MIT License, see LICENSE.md
"""
module StrAPI

const api_ext = Symbol[] # Symbols that define the public API (import to extend)
const api_def = Symbol[] # Symbols that define the public API (can't extend)
const dev_ext = Symbol[] # Symbols that define the development API (import to extend)
const dev_def = Symbol[] # Symbols that define the development API (can't extend)

const V6_COMPAT = VERSION < v"0.7.0-DEV"
const BIG_ENDIAN    = (ENDIAN_BOM == 0x01020304)
const LITTLE_ENDIAN = !BIG_ENDIAN

const mp = V6_COMPAT ? parse : Meta.parse

const MaybeSub{T} = Union{T, SubString{T}} where {T<:AbstractString}

const CodeUnitTypes = Union{UInt8, UInt16, UInt32}

symstr(s...)   = Symbol(string(s...))
quotesym(s...) = Expr(:quote, symstr(s...))

joinvec(mod, list) = join([join(eval(mod, val), ",") for val in list], ",")
joinmod(cur, mod, list) = joinvec(eval(cur, mod), list)

export @using_list, @import_list, @export_list

function handle_list(cmd, mod, list)
    cur = @static V6_COMPAT ? current_module() : @__MODULE__
    println("cmd=$cmd, mod=$mod, cur=$cur, list=$list")
    mp(string(cmd, joinvec(eval(cur, mod), list)))
end

macro using_list(mod, symlist...)
    handle_list("using $mod: ", mod, symlist)
end
macro import_list(mod, symlist...)
    handle_list("import $mod: ", mod, symlist)
end
macro export_list(mod, symlist...)
    handle_list("export ", mod, symlist)
end

push!(dev_def,
      :V6_COMPAT, :BIG_ENDIAN, :LITTLE_ENDIAN, :CodeUnitTypes,
      :MaybeSub, Symbol("@preserve"), :symstr, :quotesym)

const base_dev_ext =
    Symbol[:containsnul, :unsafe_convert, :cconvert, :IteratorSize]

eval(mp("import Base: $(join(base_dev_ext, ","))"))

const base_api_ext =
    Symbol[:convert, :getindex, :length, :map, :collect, :in, :hash, :sizeof, :size, :strides,
           :pointer, :unsafe_load, :string, :read, :write, :start, :next, :done, :reverse,
           :nextind, :prevind, :typemin, :typemax, :rem, :size, :ndims, :first, :last, :eltype,
           :isless, :isequal, :(==), :-, :+, :*, :^, :cmp, :promote_rule, :one, :repeat, :filter,
           :print, :show, :isimmutable, :chop, :chomp, :replace, :ascii, :uppercase, :lowercase,
           :lstrip, :rstrip, :strip, :lpad, :rpad, :split, :rsplit, :join, :IOBuffer]

eval(mp("import Base: $(join(base_api_ext, ","))"))

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

end # !V6_COMPAT

push!(dev_def, :unsafe_crc32c, :Fix2)
push!(api_ext, :is_lowercase, :is_uppercase, :lowercase_first, :uppercase_first)

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

push!(api_ext, :found, :find_result, :basetype, :charset, :encoding, :cse)

include("error.jl")
include("traits.jl")
include("uni.jl")

# Conditionally import or export names that are only in v0.6 or in master
for sym in (:codeunit, :codeunits, :ncodeunits, :codepoint,
            :thisind, :firstindex, :lastindex)
    push!(api_ext, sym)
    isdefined(Base, sym) || eval(Expr(:function, sym))
end

# Possibly import functions, give new names with underscores

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

     (2, (:ascii, :digit, :space, :alpha, :numeric,
          :valid, :defined, :assigned, :empty,
          :latin, :bmp, :unicode))
     ), nam in lst

    oldname, newname =
        (pref == 0 ? nam : pref == 1
         ? (symstr("is", nam[1]), symstr("is_", nam[2]))
         : (symstr("is", nam), symstr("is_", nam)))

     if isdefined(Base, oldname)
         eval(Expr(:import, :Base, oldname))
         eval(Expr(:const, Expr(:(=), newname, oldname)))
     else
         eval(Expr(:function, newname))
     end
     push!(api_ext, newname)
end

# Handle renames where function was deprecated

for nam in (:is_alphanumeric, :is_graphic)
    eval(Expr(:function, nam))
    push!(api_ext, nam)
end

# import and add new names with underscores

const ucnams = (:graphemes, :category_code, :category_abbrev, :category_string)
for nam in ucnams ; eval(mp("const $nam = UC.$nam")) ; end
append!(api_ext, ucnams)
const is_grapheme_break  = UC.isgraphemebreak
const is_grapheme_break! = UC.isgraphemebreak!
    
const fnd = find

push!(dev_def, :utf8crc, :create_vector, :outhex, :get_iobuffer)
push!(dev_ext, :ind2chr, :chr2ind)
push!(api_ext, :fnd, :find, :is_grapheme_break, :is_grapheme_break!)

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

push!(api_def, :FindOp, :Direction, :Fwd, :Rev, :First, :Last, :Next, :Prev, :Each, :All)

end # module StrAPI
