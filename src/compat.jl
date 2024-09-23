# Backward compatibility with `public` keyword, as suggested in 
# https://discourse.julialang.org/t/is-compat-jl-worth-it-for-the-public-keyword/119041/22
macro public(ex)
    if VERSION >= v"1.11.0-DEV.469"
        args = ex isa Symbol ? (ex,) :
               Base.isexpr(ex, :tuple) ? ex.args : error("Failed to mark $ex as public")
        esc(Expr(:public, args...))
    else
        nothing
    end
end
