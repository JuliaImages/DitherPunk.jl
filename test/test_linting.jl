using DitherPunk
using Test

using Aqua: Aqua
using JET: JET
using ExplicitImports: ExplicitImports

@testset "Aqua tests" begin
    @info "...with Aqua.jl"
    Aqua.test_all(DitherPunk; ambiguities = false)
end

if VERSION >= v"1.11"
    @testset "JET tests" begin
        @info "...with JET.jl"
        JET.test_package(DitherPunk; target_defined_modules = true)
    end
end

@testset "ExplicitImports tests" begin
    @info "...with ExplicitImports.jl"
    @testset "Improper implicit imports" begin
        @test ExplicitImports.check_no_implicit_imports(DitherPunk) === nothing
    end
    @testset "Improper explicit imports" begin
        @test ExplicitImports.check_no_stale_explicit_imports(DitherPunk) === nothing
        @test ExplicitImports.check_all_explicit_imports_via_owners(DitherPunk) === nothing
        # TODO: test in the future when `public` is more common
        # @test ExplicitImports.check_all_explicit_imports_are_public(DitherPunk) === nothing
    end
    @testset "Improper qualified accesses" begin
        @test ExplicitImports.check_all_qualified_accesses_via_owners(DitherPunk) === nothing
        @test ExplicitImports.check_no_self_qualified_accesses(DitherPunk) === nothing
        @test ExplicitImports.check_all_qualified_accesses_are_public(DitherPunk) === nothing
    end
end
