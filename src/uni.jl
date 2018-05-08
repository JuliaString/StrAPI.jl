"""Unicode Normalization and Category constants and strings"""
module Uni

const CN = 0
const LU = 1
const LL = 2
const LT = 3
const LM = 4
const LO = 5
const MN = 6
const MC = 7
const ME = 8
const ND = 9
const NL = 10
const NO = 11
const PC = 12
const PD = 13
const PS = 14
const PE = 15
const PI = 16
const PF = 17
const PO = 18
const SM = 19
const SC = 20
const SK = 21
const SO = 22
const ZS = 23
const ZL = 24
const ZP = 25
const CC = 26
const CF = 27
const CS = 28
const CO = 29
const CI = 30
const CM = 31

# strings corresponding to the category constants
const catstrings = [
    "Other, not assigned",
    "Letter, uppercase",
    "Letter, lowercase",
    "Letter, titlecase",
    "Letter, modifier",
    "Letter, other",
    "Mark, nonspacing",
    "Mark, spacing combining",
    "Mark, enclosing",
    "Number, decimal digit",
    "Number, letter",
    "Number, other",
    "Punctuation, connector",
    "Punctuation, dash",
    "Punctuation, open",
    "Punctuation, close",
    "Punctuation, initial quote",
    "Punctuation, final quote",
    "Punctuation, other",
    "Symbol, math",
    "Symbol, currency",
    "Symbol, modifier",
    "Symbol, other",
    "Separator, space",
    "Separator, line",
    "Separator, paragraph",
    "Other, control",
    "Other, format",
    "Other, surrogate",
    "Other, private use",
    "Invalid, too high",
    "Malformed, bad data",
]

const STABLE    = 1<<1
const COMPAT    = 1<<2
const COMPOSE   = 1<<3
const DECOMPOSE = 1<<4
const IGNORE    = 1<<5
const REJECTNA  = 1<<6
const NLF2LS    = 1<<7
const NLF2PS    = 1<<8
const NLF2LF    = NLF2LS | NLF2PS
const STRIPCC   = 1<<9
const CASEFOLD  = 1<<10
const CHARBOUND = 1<<11
const LUMP      = 1<<12
const STRIPMARK = 1<<13
end
