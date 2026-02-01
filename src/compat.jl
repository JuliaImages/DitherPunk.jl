# Backward compatibility with `public` keyword, as suggested in
# https://discourse.julialang.org/t/is-compat-jl-worth-it-for-the-public-keyword/119041/22
macro public(ex)
    return if VERSION >= v"1.11.0-DEV.469"
        args = if ex isa Symbol
            (ex,)
        elseif Base.isexpr(ex, :tuple)
            ex.args
        else
            error("Failed to mark $ex as public")
        end
        esc(Expr(:public, args...))
    else
        nothing
    end
end
