using DitherPunk
using Test

using JuliaFormatter: JuliaFormatter
using Aqua: Aqua
using JET: JET
using ExplicitImports: ExplicitImports

@testset "Code formatting" begin
    @info "...with JuliaFormatter.jl"
    @test JuliaFormatter.format(DitherPunk; verbose=false, overwrite=false)
end

@testset "Aqua tests" begin
    @info "...with Aqua.jl – this might print warnings from dependencies."
    Aqua.test_all(DitherPunk; ambiguities=false)
end

@testset "JET tests" begin
    @info "...with JET.jl"
    JET.test_package(DitherPunk; target_defined_modules=true)
end

@testset "ExplicitImports tests" begin
    @info "...with ExplicitImports.jl"
    @testset "Improper implicit imports" begin
        @test ExplicitImports.check_no_implicit_imports(DitherPunk) === nothing
    end
    @testset "Improper explicit imports" begin
        @test ExplicitImports.check_no_stale_explicit_imports(DitherPunk;) === nothing
        @test ExplicitImports.check_all_explicit_imports_via_owners(DitherPunk) === nothing
        # TODO: test in the future when `public` is more common
        # @test ExplicitImports.check_all_explicit_imports_are_public(DitherPunk) === nothing
    end
    @testset "Improper qualified accesses" begin
        @test ExplicitImports.check_all_qualified_accesses_via_owners(DitherPunk) ===
            nothing
        @test ExplicitImports.check_no_self_qualified_accesses(DitherPunk) === nothing
        # TODO: test in the future when `public` is more common
        @test ExplicitImports.check_all_qualified_accesses_are_public(DitherPunk) ===
            nothing
    end
end
