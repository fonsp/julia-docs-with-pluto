### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03c2a296-9e19-11eb-0c65-47c7d1461464
md"""
# [Documentation](@id man-documentation)
"""

# ╔═╡ 03c2a2c0-9e19-11eb-190c-37d318cdb6be
md"""
Julia enables package developers and users to document functions, types and other objects easily via a built-in documentation system.
"""

# ╔═╡ 03c2a2e8-9e19-11eb-3a62-8584948a85f0
md"""
The basic syntax is simple: any string appearing at the toplevel right before an object (function, macro, type or instance) will be interpreted as documenting it (these are called *docstrings*). Note that no blank lines or comments may intervene between a docstring and the documented object. Here is a basic example:
"""

# ╔═╡ 03c2a310-9e19-11eb-3d06-07d574991ac0
md"""
```julia
"Tell whether there are too foo items in the array."
foo(xs::Array) = ...
```
"""

# ╔═╡ 03c2a33a-9e19-11eb-3f3b-2b0b1489f92c
md"""
Documentation is interpreted as [Markdown](https://en.wikipedia.org/wiki/Markdown), so you can use indentation and code fences to delimit code examples from text. Technically, any object can be associated with any other as metadata; Markdown happens to be the default, but one can construct other string macros and pass them to the `@doc` macro just as well.
"""

# ╔═╡ 03c2a3c4-9e19-11eb-23b0-b3fddc6960c6
md"""
!!! note
    Markdown support is implemented in the `Markdown` standard library and for a full list of supported syntax see the [documentation](@ref markdown_stdlib).
"""

# ╔═╡ 03c2a3cc-9e19-11eb-3bb3-43d8869d9aa7
md"""
Here is a more complex example, still using Markdown:
"""

# ╔═╡ 03c2a40a-9e19-11eb-26d3-a3911654be39
md"""
````julia
"""
    bar(x[, y])

Compute the Bar index between `x` and `y`.

If `y` is unspecified, compute the Bar index between all pairs of columns of `x`.

# Examples
```julia-repl
julia> bar([1, 2], [1, 2])
1
```
"""
function bar(x, y) ...
````
"""

# ╔═╡ 03c2a414-9e19-11eb-1082-3f7369c5c41c
md"""
As in the example above, we recommend following some simple conventions when writing documentation:
"""

# ╔═╡ 03c2ab58-9e19-11eb-2120-0fd7c81cade2
md"""
1. Always show the signature of a function at the top of the documentation, with a four-space indent so that it is printed as Julia code.

    This can be identical to the signature present in the Julia code (like `mean(x::AbstractArray)`), or a simplified form. Optional arguments should be represented with their default values (i.e. `f(x, y=1)`) when possible, following the actual Julia syntax. Optional arguments which do not have a default value should be put in brackets (i.e. `f(x[, y])` and `f(x[, y[, z]])`). An alternative solution is to use several lines: one without optional arguments, the other(s) with them. This solution can also be used to document several related methods of a given function. When a function accepts many keyword arguments, only include a `<keyword arguments>` placeholder in the signature (i.e. `f(x; <keyword arguments>)`), and give the complete list under an `# Arguments` section (see point 4 below).
2. Include a single one-line sentence describing what the function does or what the object represents after the simplified signature block. If needed, provide more details in a second paragraph, after a blank line.

    The one-line sentence should use the imperative form ("Do this", "Return that") instead of the third person (do not write "Returns the length...") when documenting functions. It should end with a period. If the meaning of a function cannot be summarized easily, splitting it into separate composable parts could be beneficial (this should not be taken as an absolute requirement for every single case though).
3. Do not repeat yourself.

    Since the function name is given by the signature, there is no need to start the documentation with "The function `bar`...": go straight to the point. Similarly, if the signature specifies the types of the arguments, mentioning them in the description is redundant.
4. Only provide an argument list when really necessary.

    For simple functions, it is often clearer to mention the role of the arguments directly in the description of the function's purpose. An argument list would only repeat information already provided elsewhere. However, providing an argument list can be a good idea for complex functions with many arguments (in particular keyword arguments). In that case, insert it after the general description of the function, under an `# Arguments` header, with one `-` bullet for each argument. The list should mention the types and default values (if any) of the arguments:

    ```julia
    """
    ...
    # Arguments
    - `n::Integer`: the number of elements to compute.
    - `dim::Integer=1`: the dimensions along which to perform the computation.
    ...
    """
    ```
5. Provide hints to related functions.

    Sometimes there are functions of related functionality. To increase discoverability please provide a short list of these in a `See also:` paragraph.

    ```
    See also: [`bar!`](@ref), [`baz`](@ref), [`baaz`](@ref)
    ```
6. Include any code examples in an `# Examples` section.

    Examples should, whenever possible, be written as *doctests*. A *doctest* is a fenced code block (see [Code blocks](@ref)) starting with ````` ```jldoctest````` and contains any number of `julia>` prompts together with inputs and expected outputs that mimic the Julia REPL.

    !!! note
        Doctests are enabled by [`Documenter.jl`](https://github.com/JuliaDocs/Documenter.jl). For more detailed documentation see Documenter's [manual](https://juliadocs.github.io/Documenter.jl/).


    For example in the following docstring a variable `a` is defined and the expected result, as printed in a Julia REPL, appears afterwards:

    ````julia
    """
    Some nice documentation here.

    # Examples
    ```jldoctest
    julia> a = [1 2; 3 4]
    2×2 Array{Int64,2}:
     1  2
     3  4
    ```
    """
    ````

    !!! warning
        Calling `rand` and other RNG-related functions should be avoided in doctests since they will not produce consistent outputs during different Julia sessions. If you would like to show some random number generation related functionality, one option is to explicitly construct and seed your own [`MersenneTwister`](@ref) (or other pseudorandom number generator) and pass it to the functions you are doctesting.

        Operating system word size ([`Int32`](@ref) or [`Int64`](@ref)) as well as path separator differences (`/` or `\`) will also affect the reproducibility of some doctests.

        Note that whitespace in your doctest is significant! The doctest will fail if you misalign the output of pretty-printing an array, for example.


    You can then run `make -C doc doctest=true` to run all the doctests in the Julia Manual and API documentation, which will ensure that your example works.

    To indicate that the output result is truncated, you may write `[...]` at the line where checking should stop. This is useful to hide a stacktrace (which contains non-permanent references to lines of julia code) when the doctest shows that an exception is thrown, for example:

    ````julia
    ```jldoctest
    julia> div(1, 0)
    ERROR: DivideError: integer division error
    [...]
    ```
    ````

    Examples that are untestable should be written within fenced code blocks starting with ````` ```julia````` so that they are highlighted correctly in the generated documentation.

    !!! tip
        Wherever possible examples should be **self-contained** and **runnable** so that readers are able to try them out without having to include any dependencies.
7. Use backticks to identify code and equations.

    Julia identifiers and code excerpts should always appear between backticks ``` ` ``` to enable highlighting. Equations in the LaTeX syntax can be inserted between double backticks ``` `` ```. Use Unicode characters rather than their LaTeX escape sequence, i.e. ``` ``α = 1`` ``` rather than ``` ``\\alpha = 1`` ```.
8. Place the starting and ending `"""` characters on lines by themselves.

    That is, write:

    ```julia
    """
    ...

    ...
    """
    f(x, y) = ...
    ```

    rather than:

    ```julia
    """...

    ..."""
    f(x, y) = ...
    ```

    This makes it clearer where docstrings start and end.
9. Respect the line length limit used in the surrounding code.

    Docstrings are edited using the same tools as code. Therefore, the same conventions should apply. It is recommended that lines are at most 92 characters wide.
10. Provide information allowing custom types to implement the function in an `# Implementation` section. These implementation details are intended for developers rather than users, explaining e.g. which functions should be overridden and which functions automatically use appropriate fallbacks. Such details are best kept separate from the main description of the function's behavior.
11. For long docstrings, consider splitting the documentation with an `# Extended help` header. The typical help-mode will show only the material above the header; you can access the full help by adding a '?' at the beginning of the expression (i.e., "??foo" rather than "?foo").
"""

# ╔═╡ 03c2ab80-9e19-11eb-3bc1-63a09f2de593
md"""
## Accessing Documentation
"""

# ╔═╡ 03c2ab9e-9e19-11eb-2b98-27da47592674
md"""
Documentation can be accessed at the REPL or in [IJulia](https://github.com/JuliaLang/IJulia.jl) by typing `?` followed by the name of a function or macro, and pressing `Enter`. For example,
"""

# ╔═╡ 03c2abb2-9e19-11eb-1618-1b6c87455e60
md"""
```julia
?cos
?@time
?r""
```
"""

# ╔═╡ 03c2abd0-9e19-11eb-340c-3d16006ef6ba
md"""
will show documentation for the relevant function, macro or string macro respectively. In [Juno](http://junolab.org) using `Ctrl-J, Ctrl-D` will show the documentation for the object under the cursor.
"""

# ╔═╡ 03c2abdc-9e19-11eb-301e-d7680af1c729
md"""
## Functions & Methods
"""

# ╔═╡ 03c2abee-9e19-11eb-2554-0115a31b8623
md"""
Functions in Julia may have multiple implementations, known as methods. While it's good practice for generic functions to have a single purpose, Julia allows methods to be documented individually if necessary. In general, only the most generic method should be documented, or even the function itself (i.e. the object created without any methods by `function bar end`). Specific methods should only be documented if their behaviour differs from the more generic ones. In any case, they should not repeat the information provided elsewhere. For example:
"""

# ╔═╡ 03c2ac16-9e19-11eb-19dd-ff2ee56e859a
md"""
```julia
"""
    *(x, y, z...)

Multiplication operator. `x * y * z *...` calls this function with multiple
arguments, i.e. `*(x, y, z...)`.
"""
function *(x, y, z...)
    # ... [implementation sold separately] ...
end

"""
    *(x::AbstractString, y::AbstractString, z::AbstractString...)

When applied to strings, concatenates them.
"""
function *(x::AbstractString, y::AbstractString, z::AbstractString...)
    # ... [insert secret sauce here] ...
end

help?> *
search: * .*

  *(x, y, z...)

  Multiplication operator. x * y * z *... calls this function with multiple
  arguments, i.e. *(x,y,z...).

  *(x::AbstractString, y::AbstractString, z::AbstractString...)

  When applied to strings, concatenates them.
```
"""

# ╔═╡ 03c2ac2a-9e19-11eb-039b-69983de27950
md"""
When retrieving documentation for a generic function, the metadata for each method is concatenated with the `catdoc` function, which can of course be overridden for custom types.
"""

# ╔═╡ 03c2ac34-9e19-11eb-3bdc-b5a71eebb4f6
md"""
## Advanced Usage
"""

# ╔═╡ 03c2ac5c-9e19-11eb-1944-05a6b9e216a4
md"""
The `@doc` macro associates its first argument with its second in a per-module dictionary called `META`.
"""

# ╔═╡ 03c2ac7a-9e19-11eb-1d10-af74cc6b6437
md"""
To make it easier to write documentation, the parser treats the macro name `@doc` specially: if a call to `@doc` has one argument, but another expression appears after a single line break, then that additional expression is added as an argument to the macro. Therefore the following syntax is parsed as a 2-argument call to `@doc`:
"""

# ╔═╡ 03c2ac8e-9e19-11eb-2fa8-a763b997da75
md"""
```julia
@doc raw"""
...
"""
f(x) = x
```
"""

# ╔═╡ 03c2acac-9e19-11eb-34e9-ebdc555c54de
md"""
This makes it possible to use expressions other than normal string literals (such as the `raw""` string macro) as a docstring.
"""

# ╔═╡ 03c2acca-9e19-11eb-007d-8f1555ce1c1a
md"""
When used for retrieving documentation, the `@doc` macro (or equally, the `doc` function) will search all `META` dictionaries for metadata relevant to the given object and return it. The returned object (some Markdown content, for example) will by default display itself intelligently. This design also makes it easy to use the doc system in a programmatic way; for example, to re-use documentation between different versions of a function:
"""

# ╔═╡ 03c2ace0-9e19-11eb-3f5d-f181e7a5ceda
md"""
```julia
@doc "..." foo!
@doc (@doc foo!) foo
```
"""

# ╔═╡ 03c2acf2-9e19-11eb-3c55-21a74f5ffe42
md"""
Or for use with Julia's metaprogramming functionality:
"""

# ╔═╡ 03c2ad06-9e19-11eb-042d-37305e92a781
md"""
```julia
for (f, op) in ((:add, :+), (:subtract, :-), (:multiply, :*), (:divide, :/))
    @eval begin
        $f(a,b) = $op(a,b)
    end
end
@doc "`add(a,b)` adds `a` and `b` together" add
@doc "`subtract(a,b)` subtracts `b` from `a`" subtract
```
"""

# ╔═╡ 03c2ad1a-9e19-11eb-21b0-9fe039d95205
md"""
Documentation written in non-toplevel blocks, such as `begin`, `if`, `for`, and `let`, is added to the documentation system as blocks are evaluated. For example:
"""

# ╔═╡ 03c2ad38-9e19-11eb-1997-b118fc144540
md"""
```julia
if condition()
    "..."
    f(x) = x
end
```
"""

# ╔═╡ 03c2ad4c-9e19-11eb-38b6-b301c1a7a59f
md"""
will add documentation to `f(x)` when `condition()` is `true`. Note that even if `f(x)` goes out of scope at the end of the block, its documentation will remain.
"""

# ╔═╡ 03c2ad6a-9e19-11eb-2583-7f1b21bb85c6
md"""
It is possible to make use of metaprogramming to assist in the creation of documentation. When using string-interpolation within the docstring you will need to use an extra `$` as shown with `$($name)`:
"""

# ╔═╡ 03c2ad7e-9e19-11eb-037d-493bddcee854
md"""
```julia
for func in (:day, :dayofmonth)
    name = string(func)
    @eval begin
        @doc """
            $($name)(dt::TimeType) -> Int64

        The day of month of a `Date` or `DateTime` as an `Int64`.
        """ $func(dt::Dates.TimeType)
    end
end
```
"""

# ╔═╡ 03c2adc4-9e19-11eb-3ccc-69ba2b5da117
md"""
### Dynamic documentation
"""

# ╔═╡ 03c2add8-9e19-11eb-3bd5-bd776aa23de5
md"""
Sometimes the appropriate documentation for an instance of a type depends on the field values of that instance, rather than just on the type itself. In these cases, you can add a method to `Docs.getdoc` for your custom type that returns the documentation on a per-instance basis. For instance,
"""

# ╔═╡ 03c2adec-9e19-11eb-3ac3-99a7e64dae90
md"""
```julia
struct MyType
    value::String
end

Docs.getdoc(t::MyType) = "Documentation for MyType with value $(t.value)"

x = MyType("x")
y = MyType("y")
```
"""

# ╔═╡ 03c2ae0a-9e19-11eb-262e-cd63dde0b820
md"""
`?x` will display "Documentation for MyType with value x" while `?y` will display "Documentation for MyType with value y".
"""

# ╔═╡ 03c2ae16-9e19-11eb-18a5-2f2d20881318
md"""
## Syntax Guide
"""

# ╔═╡ 03c2ae28-9e19-11eb-3aa2-9590c57d4ae3
md"""
This guide provides a comprehensive overview of how to attach documentation to all Julia syntax constructs for which providing documentation is possible.
"""

# ╔═╡ 03c2ae3c-9e19-11eb-0d57-e5278310bf16
md"""
In the following examples `"..."` is used to illustrate an arbitrary docstring.
"""

# ╔═╡ 03c2ae50-9e19-11eb-2d87-811996e2bfd4
md"""
### `$` and `\` characters
"""

# ╔═╡ 03c2ae6e-9e19-11eb-1cec-7bc76774ba3e
md"""
The `$` and `\` characters are still parsed as string interpolation or start of an escape sequence in docstrings too. The `raw""` string macro together with the `@doc` macro can be used to avoid having to escape them. This is handy when the docstrings include LaTeX or Julia source code examples containing interpolation:
"""

# ╔═╡ 03c2ae8c-9e19-11eb-3cf5-81a331929062
md"""
````julia
@doc raw"""
```math
\LaTeX
```
"""
function f end
````
"""

# ╔═╡ 03c2aea0-9e19-11eb-01dc-6f91e8a3f5a9
md"""
### Functions and Methods
"""

# ╔═╡ 03c2aea8-9e19-11eb-29e8-11fd3d141bdf
md"""
```julia
"..."
function f end

"..."
f
```
"""

# ╔═╡ 03c2aed2-9e19-11eb-1e52-7b3f632ddf76
md"""
Adds docstring `"..."` to the function `f`. The first version is the preferred syntax, however both are equivalent.
"""

# ╔═╡ 03c2aee6-9e19-11eb-386e-75912f5ca4a0
md"""
```julia
"..."
f(x) = x

"..."
function f(x)
    x
end

"..."
f(x)
```
"""

# ╔═╡ 03c2aef0-9e19-11eb-133f-7329fe5239c3
md"""
Adds docstring `"..."` to the method `f(::Any)`.
"""

# ╔═╡ 03c2af04-9e19-11eb-3de3-21d5a8751719
md"""
```julia
"..."
f(x, y = 1) = x + y
```
"""

# ╔═╡ 03c2af2c-9e19-11eb-08aa-bf6b18992fcd
md"""
Adds docstring `"..."` to two `Method`s, namely `f(::Any)` and `f(::Any, ::Any)`.
"""

# ╔═╡ 03c2af40-9e19-11eb-0d03-735c28c619d4
md"""
### Macros
"""

# ╔═╡ 03c2af54-9e19-11eb-27d3-f5de043b260f
md"""
```julia
"..."
macro m(x) end
```
"""

# ╔═╡ 03c2af68-9e19-11eb-0d99-f7d2a05cb6ac
md"""
Adds docstring `"..."` to the `@m(::Any)` macro definition.
"""

# ╔═╡ 03c2af7e-9e19-11eb-3935-cb2f1fde8b55
md"""
```julia
"..."
:(@m)
```
"""

# ╔═╡ 03c2af90-9e19-11eb-3f27-7dd73288131d
md"""
Adds docstring `"..."` to the macro named `@m`.
"""

# ╔═╡ 03c2afa4-9e19-11eb-2197-eb55a14860e0
md"""
### Types
"""

# ╔═╡ 03c2b1e8-9e19-11eb-3745-c37f0fbbcd15
"..."
abstract type T1 end

# ╔═╡ 03c2b206-9e19-11eb-1378-5508bc9006da
md"""
Adds the docstring `"..."` to types `T1`, `T2`, and `T3`.
"""

# ╔═╡ 03c2b21a-9e19-11eb-3349-17a2d4efd318
md"""
```julia
"..."
struct T
    "x"
    x
    "y"
    y
end
```
"""

# ╔═╡ 03c2b24e-9e19-11eb-216f-15cda0a7b464
md"""
Adds docstring `"..."` to type `T`, `"x"` to field `T.x` and `"y"` to field `T.y`. Also applicable to `mutable struct` types.
"""

# ╔═╡ 03c2b256-9e19-11eb-3ac2-7b2aea223898
md"""
### Modules
"""

# ╔═╡ 03c2b26a-9e19-11eb-0f63-afe255401b68
md"""
```julia
"..."
module M end

module M

"..."
M

end
```
"""

# ╔═╡ 03c2b288-9e19-11eb-3949-8f4e94c2a96e
md"""
Adds docstring `"..."` to the `Module` `M`. Adding the docstring above the `Module` is the preferred syntax, however both are equivalent.
"""

# ╔═╡ 03c2b29c-9e19-11eb-2b6a-7bfb161a35a8
md"""
```julia
"..."
baremodule M
# ...
end

baremodule M

import Base: @doc

"..."
f(x) = x

end
```
"""

# ╔═╡ 03c2b2ba-9e19-11eb-19c4-4fb329a02445
md"""
Documenting a `baremodule` by placing a docstring above the expression automatically imports `@doc` into the module. These imports must be done manually when the module expression is not documented. Empty `baremodule`s cannot be documented.
"""

# ╔═╡ 03c2b2ce-9e19-11eb-3e74-ab35c0ece4fd
md"""
### Global Variables
"""

# ╔═╡ 03c2b2e0-9e19-11eb-045f-439882ec3d0b
md"""
```julia
"..."
const a = 1

"..."
b = 2

"..."
global c = 3
```
"""

# ╔═╡ 03c2b2f6-9e19-11eb-1e88-6101fd44c94a
md"""
Adds docstring `"..."` to the `Binding`s `a`, `b`, and `c`.
"""

# ╔═╡ 03c2b312-9e19-11eb-3bf5-a378b7179a15
md"""
`Binding`s are used to store a reference to a particular `Symbol` in a `Module` without storing the referenced value itself.
"""

# ╔═╡ 03c2b3d2-9e19-11eb-3e05-797e33788a06
md"""
!!! note
    When a `const` definition is only used to define an alias of another definition, such as is the case with the function `div` and its alias `÷` in `Base`, do not document the alias and instead document the actual function.

    If the alias is documented and not the real definition then the docsystem (`?` mode) will not return the docstring attached to the alias when the real definition is searched for.

    For example you should write

    ```julia
    "..."
    f(x) = x + 1
    const alias = f
    ```

    rather than

    ```julia
    f(x) = x + 1
    "..."
    const alias = f
    ```
"""

# ╔═╡ 03c2b3e8-9e19-11eb-0a5e-9384c9f8938f
md"""
```julia
"..."
sym
```
"""

# ╔═╡ 03c2b40e-9e19-11eb-16bd-cf0a02c1275f
md"""
Adds docstring `"..."` to the value associated with `sym`. However, it is preferred that `sym` is documented where it is defined.
"""

# ╔═╡ 03c2b416-9e19-11eb-2953-b992833ded07
md"""
### Multiple Objects
"""

# ╔═╡ 03c2b42c-9e19-11eb-134a-a35a58f7e63f
md"""
```julia
"..."
a, b
```
"""

# ╔═╡ 03c2b448-9e19-11eb-3c4b-65d50e234eda
md"""
Adds docstring `"..."` to `a` and `b` each of which should be a documentable expression. This syntax is equivalent to
"""

# ╔═╡ 03c2b454-9e19-11eb-0f7c-8baa3797f7f8
md"""
```julia
"..."
a

"..."
b
```
"""

# ╔═╡ 03c2b472-9e19-11eb-3ab4-8b6d1ec072c0
md"""
Any number of expressions many be documented together in this way. This syntax can be useful when two functions are related, such as non-mutating and mutating versions `f` and `f!`.
"""

# ╔═╡ 03c2b47a-9e19-11eb-30f9-3955aa4e4e69
md"""
### Macro-generated code
"""

# ╔═╡ 03c2b4c2-9e19-11eb-3ccb-d511b9b9c245
md"""
```julia
"..."
@m expression
```
"""

# ╔═╡ 03c2b4e0-9e19-11eb-0b59-2f7cee330b96
md"""
Adds docstring `"..."` to the expression generated by expanding `@m expression`. This allows for expressions decorated with `@inline`, `@noinline`, `@generated`, or any other macro to be documented in the same way as undecorated expressions.
"""

# ╔═╡ 03c2b4f4-9e19-11eb-2778-557d9d067df2
md"""
Macro authors should take note that only macros that generate a single expression will automatically support docstrings. If a macro returns a block containing multiple subexpressions then the subexpression that should be documented must be marked using the [`@__doc__`](@ref Core.@__doc__) macro.
"""

# ╔═╡ 03c2b51e-9e19-11eb-360c-05d3bc779f3b
md"""
The [`@enum`](@ref) macro makes use of `@__doc__` to allow for documenting [`Enum`](@ref)s. Examining its definition should serve as an example of how to use `@__doc__` correctly.
"""

# ╔═╡ 03c2b65c-9e19-11eb-3a74-5dd846313752
Core.@__doc__

# ╔═╡ Cell order:
# ╟─03c2a296-9e19-11eb-0c65-47c7d1461464
# ╟─03c2a2c0-9e19-11eb-190c-37d318cdb6be
# ╟─03c2a2e8-9e19-11eb-3a62-8584948a85f0
# ╟─03c2a310-9e19-11eb-3d06-07d574991ac0
# ╟─03c2a33a-9e19-11eb-3f3b-2b0b1489f92c
# ╟─03c2a3c4-9e19-11eb-23b0-b3fddc6960c6
# ╟─03c2a3cc-9e19-11eb-3bb3-43d8869d9aa7
# ╟─03c2a40a-9e19-11eb-26d3-a3911654be39
# ╟─03c2a414-9e19-11eb-1082-3f7369c5c41c
# ╟─03c2ab58-9e19-11eb-2120-0fd7c81cade2
# ╟─03c2ab80-9e19-11eb-3bc1-63a09f2de593
# ╟─03c2ab9e-9e19-11eb-2b98-27da47592674
# ╟─03c2abb2-9e19-11eb-1618-1b6c87455e60
# ╟─03c2abd0-9e19-11eb-340c-3d16006ef6ba
# ╟─03c2abdc-9e19-11eb-301e-d7680af1c729
# ╟─03c2abee-9e19-11eb-2554-0115a31b8623
# ╟─03c2ac16-9e19-11eb-19dd-ff2ee56e859a
# ╟─03c2ac2a-9e19-11eb-039b-69983de27950
# ╟─03c2ac34-9e19-11eb-3bdc-b5a71eebb4f6
# ╟─03c2ac5c-9e19-11eb-1944-05a6b9e216a4
# ╟─03c2ac7a-9e19-11eb-1d10-af74cc6b6437
# ╟─03c2ac8e-9e19-11eb-2fa8-a763b997da75
# ╟─03c2acac-9e19-11eb-34e9-ebdc555c54de
# ╟─03c2acca-9e19-11eb-007d-8f1555ce1c1a
# ╟─03c2ace0-9e19-11eb-3f5d-f181e7a5ceda
# ╟─03c2acf2-9e19-11eb-3c55-21a74f5ffe42
# ╟─03c2ad06-9e19-11eb-042d-37305e92a781
# ╟─03c2ad1a-9e19-11eb-21b0-9fe039d95205
# ╟─03c2ad38-9e19-11eb-1997-b118fc144540
# ╟─03c2ad4c-9e19-11eb-38b6-b301c1a7a59f
# ╟─03c2ad6a-9e19-11eb-2583-7f1b21bb85c6
# ╟─03c2ad7e-9e19-11eb-037d-493bddcee854
# ╟─03c2adc4-9e19-11eb-3ccc-69ba2b5da117
# ╟─03c2add8-9e19-11eb-3bd5-bd776aa23de5
# ╟─03c2adec-9e19-11eb-3ac3-99a7e64dae90
# ╟─03c2ae0a-9e19-11eb-262e-cd63dde0b820
# ╟─03c2ae16-9e19-11eb-18a5-2f2d20881318
# ╟─03c2ae28-9e19-11eb-3aa2-9590c57d4ae3
# ╟─03c2ae3c-9e19-11eb-0d57-e5278310bf16
# ╟─03c2ae50-9e19-11eb-2d87-811996e2bfd4
# ╟─03c2ae6e-9e19-11eb-1cec-7bc76774ba3e
# ╟─03c2ae8c-9e19-11eb-3cf5-81a331929062
# ╟─03c2aea0-9e19-11eb-01dc-6f91e8a3f5a9
# ╟─03c2aea8-9e19-11eb-29e8-11fd3d141bdf
# ╟─03c2aed2-9e19-11eb-1e52-7b3f632ddf76
# ╟─03c2aee6-9e19-11eb-386e-75912f5ca4a0
# ╟─03c2aef0-9e19-11eb-133f-7329fe5239c3
# ╟─03c2af04-9e19-11eb-3de3-21d5a8751719
# ╟─03c2af2c-9e19-11eb-08aa-bf6b18992fcd
# ╟─03c2af40-9e19-11eb-0d03-735c28c619d4
# ╟─03c2af54-9e19-11eb-27d3-f5de043b260f
# ╟─03c2af68-9e19-11eb-0d99-f7d2a05cb6ac
# ╟─03c2af7e-9e19-11eb-3935-cb2f1fde8b55
# ╟─03c2af90-9e19-11eb-3f27-7dd73288131d
# ╟─03c2afa4-9e19-11eb-2197-eb55a14860e0
# ╠═03c2b1e8-9e19-11eb-3745-c37f0fbbcd15
# ╟─03c2b206-9e19-11eb-1378-5508bc9006da
# ╟─03c2b21a-9e19-11eb-3349-17a2d4efd318
# ╟─03c2b24e-9e19-11eb-216f-15cda0a7b464
# ╟─03c2b256-9e19-11eb-3ac2-7b2aea223898
# ╟─03c2b26a-9e19-11eb-0f63-afe255401b68
# ╟─03c2b288-9e19-11eb-3949-8f4e94c2a96e
# ╟─03c2b29c-9e19-11eb-2b6a-7bfb161a35a8
# ╟─03c2b2ba-9e19-11eb-19c4-4fb329a02445
# ╟─03c2b2ce-9e19-11eb-3e74-ab35c0ece4fd
# ╟─03c2b2e0-9e19-11eb-045f-439882ec3d0b
# ╟─03c2b2f6-9e19-11eb-1e88-6101fd44c94a
# ╟─03c2b312-9e19-11eb-3bf5-a378b7179a15
# ╟─03c2b3d2-9e19-11eb-3e05-797e33788a06
# ╟─03c2b3e8-9e19-11eb-0a5e-9384c9f8938f
# ╟─03c2b40e-9e19-11eb-16bd-cf0a02c1275f
# ╟─03c2b416-9e19-11eb-2953-b992833ded07
# ╟─03c2b42c-9e19-11eb-134a-a35a58f7e63f
# ╟─03c2b448-9e19-11eb-3c4b-65d50e234eda
# ╟─03c2b454-9e19-11eb-0f7c-8baa3797f7f8
# ╟─03c2b472-9e19-11eb-3ab4-8b6d1ec072c0
# ╟─03c2b47a-9e19-11eb-30f9-3955aa4e4e69
# ╟─03c2b4c2-9e19-11eb-3ccb-d511b9b9c245
# ╟─03c2b4e0-9e19-11eb-0b59-2f7cee330b96
# ╟─03c2b4f4-9e19-11eb-2778-557d9d067df2
# ╟─03c2b51e-9e19-11eb-360c-05d3bc779f3b
# ╠═03c2b65c-9e19-11eb-3a74-5dd846313752
