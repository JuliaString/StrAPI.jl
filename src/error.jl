# Based partly on code in LegacyStrings that used to be part of Julia
# Licensed under MIT License, see LICENSE.md

# (Mostly written by Scott P. Jones in series of PRs contributed to the Julia project in 2015)

## Error messages for Unicode / UTF support

const UTF_ERR_SHORT =
  "invalid UTF-8 sequence starting at index <<1>> (0x<<2>>) missing one or more continuation bytes"
const UTF_ERR_CONT =
  "invalid UTF-8 sequence starting at index <<1>> (0x<<2>>) is not a continuation byte"
const UTF_ERR_LONG =
  "invalid UTF-8 sequence, overlong encoding starting at index <<1>> (0x<<2>>)"
const UTF_ERR_NOT_LEAD =
  "not a leading Unicode surrogate code unit at index <<1>> (0x<<2>>)"
const UTF_ERR_NOT_TRAIL =
  "not a trailing Unicode surrogate code unit at index <<1>> (0x<<2>>)"
const UTF_ERR_NOT_SURROGATE =
  "not a valid Unicode surrogate code unit at index <<1>> (0x<<2>>)"
const UTF_ERR_MISSING_SURROGATE =
  "missing trailing Unicode surrogate code unit after index <<1>> (0x<<2>>)"
const UTF_ERR_INVALID =
  "invalid Unicode character starting at index <<1>> (0x<<2>> > 0x10ffff)"
const UTF_ERR_SURROGATE =
  "surrogate encoding not allowed in UTF-8 or UTF-32, at index <<1>> (0x<<2>>)"
const UTF_ERR_ODD_BYTES_16 =
  "UTF16String can't have odd number of bytes <<1>>"
const UTF_ERR_ODD_BYTES_32 =
  "UTF32String must have multiple of 4 bytes <<1>>"
const UTF_ERR_INVALID_ASCII =
  "invalid ASCII character at index <<1>> (0x<<2>> > 0x7f)"
const UTF_ERR_INVALID_LATIN1 =
  "invalid Latin1 character at index <<1>> (0x<<2>> > 0xff)"
const UTF_ERR_INVALID_CHAR =
  "invalid Unicode character (0x<<2>> > 0x10ffff)"
const UTF_ERR_INVALID_8 =
  "invalid UTF-8 data"
const UTF_ERR_INVALID_16 =
  "invalid UTF-16 data"
const UTF_ERR_INVALID_UCS2 =
  "invalid UCS-2 character (surrogate present)"
const UTF_ERR_INVALID_INDEX =
  "invalid character index <<1>>"

@static if isdefined(Base, :UnicodeError)
    Base.UnicodeError(msg) = UnicodeError(msg, 0%Int32, 0%UInt32)
else

struct UnicodeError <: Exception
    errmsg::AbstractString   ##< A UTF_ERR_ message
    errpos::Int32            ##< Position of invalid character
    errchr::UInt32           ##< Invalid character
    UnicodeError(msg, pos, chr) = new(msg, pos%Int32, chr%UInt32)
    UnicodeError(msg) = new(msg, 0%Int32, 0%UInt32)
end

_repmsg(msg, pos, chr) =
    replace(replace(msg, "<<1>>" => string(pos)), "<<2>>" =>  outhex(chr))
Base.show(io::IO, exc::UnicodeError) =
    print(io, "UnicodeError: ", _repmsg(exc.errmsg, exc.errpos, exc.errchr))
end

const UTF_ERR_DECOMPOSE_COMPOSE = "only one of decompose or compose may be true"
const UTF_ERR_COMPAT_STRIPMARK  = "compat or stripmark true requires compose or decompose true"
const UTF_ERR_NL_CONVERSION     = "only one newline conversion may be specified"
const UTF_ERR_NORMALIZE         = " is not one of :NFC, :NFD, :NFKC, :NFKD"

@noinline boundserr(s, pos)      = throw(BoundsError(s, pos))
@noinline unierror(err)          = throw(UnicodeError(err))
@noinline unierror(err, pos, ch) = throw(UnicodeError(err, pos, ch))
@noinline unierror(err, v)       = unierror(string(":", v, err))
@noinline nulerr()               = unierror("cannot convert NULL to string")
@noinline neginderr(s, n)        = unierror("Index ($n) must be non negative")
@noinline codepoint_error(T, v)  = unierror(string("Invalid CodePoint: ", T, " 0x", outhex(v)))
@noinline argerror(startpos, endpos) =
    unierror(string("End position ", endpos, " is less than start position (", startpos, ")"))

@noinline ascii_err()    = throw(ArgumentError("Not a valid ASCII string"))
@noinline ncharerr(n)    = throw(ArgumentError(string("nchar (", n, ") must be not be negative")))
@noinline repeaterr(cnt) = throw(ArgumentError("repeat count $cnt must be >= 0"))

@static isdefined(Base, :string_index_err) && (const index_error = Base.string_index_err)

@api define_develop boundserr, unierror, nulerr, neginderr, codepoint_error,
                    argerror, ascii_err, ncharerr, repeaterr, index_error
