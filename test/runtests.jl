# This file is part of StrAPI, License is MIT: LICENSE.md

using StrAPI
@using_list StrAPI api_ext api_def dev_ext dev_def

@static V6_COMPAT ? (using Base.Test) : (using Test)

@test is_ascii     == isascii
@test is_hex_digit == isxdigit

@static if V6_COMPAT
    @test uppercase_first == ucfirst
    @test is_lowercase == islower
else
    @test uppercase_first == uppercasefirst
    @test is_lowercase == islowercase
end
    
@test AbstractChar <: Any
@test Each <: FindOp
@test First <: FindOp
@test Fwd <: Direction
