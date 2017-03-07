using FactCheck, Parser
for n in names(Parser, true, true)
    eval(:(import Parser.$n))
end

function test_span(x)
    if x isa EXPR
        cnt = 0
        for a in x
            test_span(a)
        end
        @assert x.span == (length(x) == 0 ? 0 : sum(a.span for a in x)) "$(x.head)  $(x.span)  $(sum(a.span for a in x))"
    end
    true
end

function test_parse(str)
    x = Parser.parse(str)
    @fact Expr(x)      --> remlineinfo!(Base.parse(str))
    @fact sizeof(str)  --> x.span
    @fact test_span(x) --> true
end



include("operators.jl")
include("curly.jl")
include("tuples.jl")
include("functions.jl")
include("modules.jl")
include("generators.jl")
include("macros.jl")
include("types.jl")
include("do.jl")
include("keywords.jl")

const examplemodule = readstring("fullspecexample.jl")

function timeParser(n)
    for i =1:n
        Parser.parse(examplemodule)
    end
end

function timeBase(n)
    for i =1:n
        Base.parse(examplemodule)
    end
end

function timeTokenize(n)
    for i =1:n
        collect(Tokenize.tokenize(examplemodule))
    end
end

# using BenchmarkTools

timeParser(1)
timeBase(1)
timeTokenize(1)
tp = @elapsed timeParser(500)
tb = @elapsed timeBase(500)
tt = @elapsed timeTokenize(500)
println(tb/tp)



facts("fullspec") do
    x = Parser.parse(examplemodule)
    sizeof(examplemodule)
    @fact x.span --> sizeof(examplemodule)

end
