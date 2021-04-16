### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ f3e387f4-a6c9-4d20-bd84-501c2d957c45
md"""
# [Documentation](@id man-documentation)
"""

# ╔═╡ 08e90b56-7ab1-4135-9c5e-35953c48e482
md"""
Julia enables package developers and users to document functions, types and other objects easily via a built-in documentation system.
"""

# ╔═╡ 41e8d0d0-4298-453b-a90e-2980f24aabe0
md"""
The basic syntax is simple: any string appearing at the toplevel right before an object (function, macro, type or instance) will be interpreted as documenting it (these are called *docstrings*). Note that no blank lines or comments may intervene between a docstring and the documented object. Here is a basic example:
"""

# ╔═╡ 9238b030-7c9d-4e96-a945-6cf43a3a2d6d
md"""
```julia
\"Tell whether there are too foo items in the array.\"
foo(xs::Array) = ...
```
"""

# ╔═╡ fbeb1050-1b5a-48ca-9d16-a3c02e802b51
md"""
Documentation is interpreted as [Markdown](https://en.wikipedia.org/wiki/Markdown), so you can use indentation and code fences to delimit code examples from text. Technically, any object can be associated with any other as metadata; Markdown happens to be the default, but one can construct other string macros and pass them to the `@doc` macro just as well.
"""

# ╔═╡ d88a7d15-9119-4746-8269-75857f8e42db
md"""
!!! note
    Markdown support is implemented in the `Markdown` standard library and for a full list of supported syntax see the [documentation](@ref markdown_stdlib).
"""

# ╔═╡ ee76e55a-9bbc-4f47-9d96-2b83219295c6
md"""
Here is a more complex example, still using Markdown:
"""

# ╔═╡ d2594209-8d69-4261-826a-7da51c65c99a
md"""
````julia
\"\"\"
    bar(x[, y])

Compute the Bar index between `x` and `y`.

If `y` is unspecified, compute the Bar index between all pairs of columns of `x`.

# Examples
```julia-repl
julia> bar([1, 2], [1, 2])
1
```
\"\"\"
function bar(x, y) ...
````
"""

# ╔═╡ b78ba905-f818-4e8e-aaa1-8e66039d57e5
md"""
As in the example above, we recommend following some simple conventions when writing documentation:
"""

# ╔═╡ b8ad27e6-4b32-4aa7-85b2-daf7d6ee8195
md"""
1. Always show the signature of a function at the top of the documentation, with a four-space indent so that it is printed as Julia code.

    This can be identical to the signature present in the Julia code (like `mean(x::AbstractArray)`), or a simplified form. Optional arguments should be represented with their default values (i.e. `f(x, y=1)`) when possible, following the actual Julia syntax. Optional arguments which do not have a default value should be put in brackets (i.e. `f(x[, y])` and `f(x[, y[, z]])`). An alternative solution is to use several lines: one without optional arguments, the other(s) with them. This solution can also be used to document several related methods of a given function. When a function accepts many keyword arguments, only include a `<keyword arguments>` placeholder in the signature (i.e. `f(x; <keyword arguments>)`), and give the complete list under an `# Arguments` section (see point 4 below).
2. Include a single one-line sentence describing what the function does or what the object represents after the simplified signature block. If needed, provide more details in a second paragraph, after a blank line.

    The one-line sentence should use the imperative form (\"Do this\", \"Return that\") instead of the third person (do not write \"Returns the length...\") when documenting functions. It should end with a period. If the meaning of a function cannot be summarized easily, splitting it into separate composable parts could be beneficial (this should not be taken as an absolute requirement for every single case though).
3. Do not repeat yourself.

    Since the function name is given by the signature, there is no need to start the documentation with \"The function `bar`...\": go straight to the point. Similarly, if the signature specifies the types of the arguments, mentioning them in the description is redundant.
4. Only provide an argument list when really necessary.

    For simple functions, it is often clearer to mention the role of the arguments directly in the description of the function's purpose. An argument list would only repeat information already provided elsewhere. However, providing an argument list can be a good idea for complex functions with many arguments (in particular keyword arguments). In that case, insert it after the general description of the function, under an `# Arguments` header, with one `-` bullet for each argument. The list should mention the types and default values (if any) of the arguments:

    ```julia
    \"\"\"
    ...
    # Arguments
    - `n::Integer`: the number of elements to compute.
    - `dim::Integer=1`: the dimensions along which to perform the computation.
    ...
    \"\"\"
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
    \"\"\"
    Some nice documentation here.

    # Examples
    ```jldoctest
    julia> a = [1 2; 3 4]
    2×2 Array{Int64,2}:
     1  2
     3  4
    ```
    \"\"\"
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
8. Place the starting and ending `\"\"\"` characters on lines by themselves.

    That is, write:

    ```julia
    \"\"\"
    ...

    ...
    \"\"\"
    f(x, y) = ...
    ```

    rather than:

    ```julia
    \"\"\"...

    ...\"\"\"
    f(x, y) = ...
    ```

    This makes it clearer where docstrings start and end.
9. Respect the line length limit used in the surrounding code.

    Docstrings are edited using the same tools as code. Therefore, the same conventions should apply. It is recommended that lines are at most 92 characters wide.
10. Provide information allowing custom types to implement the function in an `# Implementation` section. These implementation details are intended for developers rather than users, explaining e.g. which functions should be overridden and which functions automatically use appropriate fallbacks. Such details are best kept separate from the main description of the function's behavior.
11. For long docstrings, consider splitting the documentation with an `# Extended help` header. The typical help-mode will show only the material above the header; you can access the full help by adding a '?' at the beginning of the expression (i.e., \"??foo\" rather than \"?foo\").
"""

# ╔═╡ 6373cdbd-82c9-4726-b1f2-f896bd5eb41a
md"""
## Accessing Documentation
"""

# ╔═╡ 67b9cf67-28c7-4811-be86-d94f9bbcb643
md"""
Documentation can be accessed at the REPL or in [IJulia](https://github.com/JuliaLang/IJulia.jl) by typing `?` followed by the name of a function or macro, and pressing `Enter`. For example,
"""

# ╔═╡ bf60e96f-aa64-4a82-b602-6fb4661d0763
md"""
```julia
?cos
?@time
?r\"\"
```
"""

# ╔═╡ ee902920-dafd-4655-9906-4a8c7fda44a0
md"""
will show documentation for the relevant function, macro or string macro respectively. In [Juno](http://junolab.org) using `Ctrl-J, Ctrl-D` will show the documentation for the object under the cursor.
"""

# ╔═╡ 78d437eb-76c1-4a45-a85b-101c68f3d099
md"""
## Functions & Methods
"""

# ╔═╡ ed396963-a076-458d-814f-d5fd6cea89e1
md"""
Functions in Julia may have multiple implementations, known as methods. While it's good practice for generic functions to have a single purpose, Julia allows methods to be documented individually if necessary. In general, only the most generic method should be documented, or even the function itself (i.e. the object created without any methods by `function bar end`). Specific methods should only be documented if their behaviour differs from the more generic ones. In any case, they should not repeat the information provided elsewhere. For example:
"""

# ╔═╡ bba91536-47b4-470e-9ca5-293d06a9974b
md"""
```julia
\"\"\"
    *(x, y, z...)

Multiplication operator. `x * y * z *...` calls this function with multiple
arguments, i.e. `*(x, y, z...)`.
\"\"\"
function *(x, y, z...)
    # ... [implementation sold separately] ...
end

\"\"\"
    *(x::AbstractString, y::AbstractString, z::AbstractString...)

When applied to strings, concatenates them.
\"\"\"
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

# ╔═╡ 47635048-4666-4dd4-9582-d2dce4dc7a39
md"""
When retrieving documentation for a generic function, the metadata for each method is concatenated with the `catdoc` function, which can of course be overridden for custom types.
"""

# ╔═╡ 964bdb8a-f65a-401d-875f-c67bb387ef5c
md"""
## Advanced Usage
"""

# ╔═╡ 8984a5e8-c9f4-4729-80ef-a022a3452ae9
md"""
The `@doc` macro associates its first argument with its second in a per-module dictionary called `META`.
"""

# ╔═╡ 0f4c4a3d-0f3d-4f59-931d-4ddc35756df9
md"""
To make it easier to write documentation, the parser treats the macro name `@doc` specially: if a call to `@doc` has one argument, but another expression appears after a single line break, then that additional expression is added as an argument to the macro. Therefore the following syntax is parsed as a 2-argument call to `@doc`:
"""

# ╔═╡ b38863ae-d913-4e0a-8033-45a44371a6e1
md"""
```julia
@doc raw\"\"\"
...
\"\"\"
f(x) = x
```
"""

# ╔═╡ cdc19292-5262-48c3-8ecd-56e43cdb1f83
md"""
This makes it possible to use expressions other than normal string literals (such as the `raw\"\"` string macro) as a docstring.
"""

# ╔═╡ 1605cfa7-4d85-41b1-aa4b-102576e7e5a1
md"""
When used for retrieving documentation, the `@doc` macro (or equally, the `doc` function) will search all `META` dictionaries for metadata relevant to the given object and return it. The returned object (some Markdown content, for example) will by default display itself intelligently. This design also makes it easy to use the doc system in a programmatic way; for example, to re-use documentation between different versions of a function:
"""

# ╔═╡ f959a845-2722-4825-93bc-d59a658c46fa
md"""
```julia
@doc \"...\" foo!
@doc (@doc foo!) foo
```
"""

# ╔═╡ 6c1b9417-c145-4fac-9b21-7dfcecb5b07a
md"""
Or for use with Julia's metaprogramming functionality:
"""

# ╔═╡ 33c9fc19-8097-4569-a8c9-99d629bc1f76
md"""
```julia
for (f, op) in ((:add, :+), (:subtract, :-), (:multiply, :*), (:divide, :/))
    @eval begin
        $f(a,b) = $op(a,b)
    end
end
@doc \"`add(a,b)` adds `a` and `b` together\" add
@doc \"`subtract(a,b)` subtracts `b` from `a`\" subtract
```
"""

# ╔═╡ 45b4046a-86c2-4046-b992-355f04ac159e
md"""
Documentation written in non-toplevel blocks, such as `begin`, `if`, `for`, and `let`, is added to the documentation system as blocks are evaluated. For example:
"""

# ╔═╡ 608225f8-de2e-4d7f-8ee3-d094b99ac5d4
md"""
```julia
if condition()
    \"...\"
    f(x) = x
end
```
"""

# ╔═╡ 516266f9-a492-45f4-a572-192576f0334e
md"""
will add documentation to `f(x)` when `condition()` is `true`. Note that even if `f(x)` goes out of scope at the end of the block, its documentation will remain.
"""

# ╔═╡ f306d16f-4a1e-4cda-bfd8-ca1435c7dc4e
md"""
It is possible to make use of metaprogramming to assist in the creation of documentation. When using string-interpolation within the docstring you will need to use an extra `$` as shown with `$($name)`:
"""

# ╔═╡ eb663cf5-0cf1-409d-ad19-38613d42d502
md"""
```julia
for func in (:day, :dayofmonth)
    name = string(func)
    @eval begin
        @doc \"\"\"
            $($name)(dt::TimeType) -> Int64

        The day of month of a `Date` or `DateTime` as an `Int64`.
        \"\"\" $func(dt::Dates.TimeType)
    end
end
```
"""

# ╔═╡ fb05e165-6641-459c-a5a7-7bdc3d431f74
md"""
### Dynamic documentation
"""

# ╔═╡ f8bf1c6a-659d-4884-8f47-49c5ebe3a649
md"""
Sometimes the appropriate documentation for an instance of a type depends on the field values of that instance, rather than just on the type itself. In these cases, you can add a method to `Docs.getdoc` for your custom type that returns the documentation on a per-instance basis. For instance,
"""

# ╔═╡ d2136ae3-b42d-492f-80a0-28e3f2d65463
md"""
```julia
struct MyType
    value::String
end

Docs.getdoc(t::MyType) = \"Documentation for MyType with value $(t.value)\"

x = MyType(\"x\")
y = MyType(\"y\")
```
"""

# ╔═╡ 742a3c82-d686-4495-be53-e9dbde600285
md"""
`?x` will display \"Documentation for MyType with value x\" while `?y` will display \"Documentation for MyType with value y\".
"""

# ╔═╡ c0297cce-28ec-40b8-a4a0-d035acead389
md"""
## Syntax Guide
"""

# ╔═╡ a7555344-71fa-4271-9dd8-34d1fea584ab
md"""
This guide provides a comprehensive overview of how to attach documentation to all Julia syntax constructs for which providing documentation is possible.
"""

# ╔═╡ 53537da4-6994-4eaa-829c-0d68dd6a02bb
md"""
In the following examples `\"...\"` is used to illustrate an arbitrary docstring.
"""

# ╔═╡ e0514271-f37d-46d0-b24f-709cbe46c907
md"""
### `$` and `\` characters
"""

# ╔═╡ 6162afc7-4331-4780-a602-f0c80a30bdd4
md"""
The `$` and `\` characters are still parsed as string interpolation or start of an escape sequence in docstrings too. The `raw\"\"` string macro together with the `@doc` macro can be used to avoid having to escape them. This is handy when the docstrings include LaTeX or Julia source code examples containing interpolation:
"""

# ╔═╡ 4098eed6-bf8c-43c9-9b87-cba4d470bed3
md"""
````julia
@doc raw\"\"\"
```math
\LaTeX
```
\"\"\"
function f end
````
"""

# ╔═╡ 69cf6b6b-70fa-4c90-844e-bece9423348a
md"""
### Functions and Methods
"""

# ╔═╡ bf31a15e-e14e-4ad8-aa11-bfbd76df5cf3
md"""
```julia
\"...\"
function f end

\"...\"
f
```
"""

# ╔═╡ e8ad9db1-6b94-4138-9ca4-016bd7d65cc0
md"""
Adds docstring `\"...\"` to the function `f`. The first version is the preferred syntax, however both are equivalent.
"""

# ╔═╡ 520c4b5f-2d21-4fb8-9be7-5be09810b4dd
md"""
```julia
\"...\"
f(x) = x

\"...\"
function f(x)
    x
end

\"...\"
f(x)
```
"""

# ╔═╡ 62e97132-5e9e-44f8-9506-36b4fa3aea9e
md"""
Adds docstring `\"...\"` to the method `f(::Any)`.
"""

# ╔═╡ 135dda81-a549-4b3b-8e09-d499b456d76b
md"""
```julia
\"...\"
f(x, y = 1) = x + y
```
"""

# ╔═╡ b1f2c14c-72f9-4ed5-8b5d-165a1a498c9f
md"""
Adds docstring `\"...\"` to two `Method`s, namely `f(::Any)` and `f(::Any, ::Any)`.
"""

# ╔═╡ 4a4917c3-57b4-4674-9246-f5e7da5a67e3
md"""
### Macros
"""

# ╔═╡ c3d67efc-dde4-4c04-b63e-e128949daa86
md"""
```julia
\"...\"
macro m(x) end
```
"""

# ╔═╡ fd1ded6e-f550-437a-9998-75f616579099
md"""
Adds docstring `\"...\"` to the `@m(::Any)` macro definition.
"""

# ╔═╡ 5d8c2aba-fe0e-4013-990d-c971883b10c7
md"""
```julia
\"...\"
:(@m)
```
"""

# ╔═╡ 5e5cd9ed-7405-4065-8e6b-6e9c4aad8173
md"""
Adds docstring `\"...\"` to the macro named `@m`.
"""

# ╔═╡ e11b0acb-1270-432a-b989-771f7a304874
md"""
### Types
"""

# ╔═╡ 442211e1-ac79-4883-8ed3-374c7ebb5372
md"""
```
\"...\"
abstract type T1 end

\"...\"
mutable struct T2
    ...
end

\"...\"
struct T3
    ...
end
```
"""

# ╔═╡ 02a6676c-b2de-419a-b445-9f0ceded145b
md"""
Adds the docstring `\"...\"` to types `T1`, `T2`, and `T3`.
"""

# ╔═╡ 02751e00-5911-4405-ad48-fdd5b7ec8c39
md"""
```julia
\"...\"
struct T
    \"x\"
    x
    \"y\"
    y
end
```
"""

# ╔═╡ 2bea28b9-2827-4ba4-b8d9-2ebf4d23c635
md"""
Adds docstring `\"...\"` to type `T`, `\"x\"` to field `T.x` and `\"y\"` to field `T.y`. Also applicable to `mutable struct` types.
"""

# ╔═╡ 6bebd6bd-f496-4983-8774-5ddde534a99d
md"""
### Modules
"""

# ╔═╡ 1c07c76a-4033-485c-bd03-40126116b0b9
md"""
```julia
\"...\"
module M end

module M

\"...\"
M

end
```
"""

# ╔═╡ e85e2c8c-d35a-4469-952a-376a3cab5bf9
md"""
Adds docstring `\"...\"` to the `Module` `M`. Adding the docstring above the `Module` is the preferred syntax, however both are equivalent.
"""

# ╔═╡ a6a76204-8fb4-4409-af6c-cb091d7a2ba6
md"""
```julia
\"...\"
baremodule M
# ...
end

baremodule M

import Base: @doc

\"...\"
f(x) = x

end
```
"""

# ╔═╡ 3c578dc5-9a9e-4043-961a-9a28f80f2935
md"""
Documenting a `baremodule` by placing a docstring above the expression automatically imports `@doc` into the module. These imports must be done manually when the module expression is not documented. Empty `baremodule`s cannot be documented.
"""

# ╔═╡ 5b87c40b-f703-4adb-92ae-d2bebc272f2e
md"""
### Global Variables
"""

# ╔═╡ db1cb123-9be7-4e0f-9ba4-38af545458d7
md"""
```julia
\"...\"
const a = 1

\"...\"
b = 2

\"...\"
global c = 3
```
"""

# ╔═╡ 0ec56ce3-b407-40b6-b10e-8f439e84a310
md"""
Adds docstring `\"...\"` to the `Binding`s `a`, `b`, and `c`.
"""

# ╔═╡ 77aa1ac9-5340-48ab-a93d-0d56f56ba939
md"""
`Binding`s are used to store a reference to a particular `Symbol` in a `Module` without storing the referenced value itself.
"""

# ╔═╡ 9051f66d-2b48-4b2b-a5d3-6d8ac73153cb
md"""
!!! note
    When a `const` definition is only used to define an alias of another definition, such as is the case with the function `div` and its alias `÷` in `Base`, do not document the alias and instead document the actual function.

    If the alias is documented and not the real definition then the docsystem (`?` mode) will not return the docstring attached to the alias when the real definition is searched for.

    For example you should write

    ```julia
    \"...\"
    f(x) = x + 1
    const alias = f
    ```

    rather than

    ```julia
    f(x) = x + 1
    \"...\"
    const alias = f
    ```
"""

# ╔═╡ e7c759db-2828-445b-8fc1-5d22ef9bd711
md"""
```julia
\"...\"
sym
```
"""

# ╔═╡ 89fe9d96-b19d-4191-aa00-fa96386c8193
md"""
Adds docstring `\"...\"` to the value associated with `sym`. However, it is preferred that `sym` is documented where it is defined.
"""

# ╔═╡ fc2727cd-6d5f-4cd0-8c97-fa14af565b02
md"""
### Multiple Objects
"""

# ╔═╡ d563ef4d-a374-402b-92f7-c9e4c94db3d5
md"""
```julia
\"...\"
a, b
```
"""

# ╔═╡ 8300e270-3c60-46d2-8504-5b2dc24c0fcf
md"""
Adds docstring `\"...\"` to `a` and `b` each of which should be a documentable expression. This syntax is equivalent to
"""

# ╔═╡ 08a13c14-33e9-47f2-813e-e01e7586ac50
md"""
```julia
\"...\"
a

\"...\"
b
```
"""

# ╔═╡ 230b6227-26e3-4166-9f2c-24f07f62f8b1
md"""
Any number of expressions many be documented together in this way. This syntax can be useful when two functions are related, such as non-mutating and mutating versions `f` and `f!`.
"""

# ╔═╡ 25f93fc4-81c8-4576-ace7-0d832d0268a7
md"""
### Macro-generated code
"""

# ╔═╡ a27d4848-6651-4aa5-9f60-2ba6a22359a4
md"""
```julia
\"...\"
@m expression
```
"""

# ╔═╡ 3029d476-6ba6-4e1b-87c2-247109dca409
md"""
Adds docstring `\"...\"` to the expression generated by expanding `@m expression`. This allows for expressions decorated with `@inline`, `@noinline`, `@generated`, or any other macro to be documented in the same way as undecorated expressions.
"""

# ╔═╡ d9511067-0d2c-4b03-af55-b767a5b00cd6
md"""
Macro authors should take note that only macros that generate a single expression will automatically support docstrings. If a macro returns a block containing multiple subexpressions then the subexpression that should be documented must be marked using the [`@__doc__`](@ref Core.@__doc__) macro.
"""

# ╔═╡ 5a03561e-e8af-48e8-9a80-b443de2dcbbc
md"""
The [`@enum`](@ref) macro makes use of `@__doc__` to allow for documenting [`Enum`](@ref)s. Examining its definition should serve as an example of how to use `@__doc__` correctly.
"""

# ╔═╡ c1d43728-d35e-4471-8ed2-a431167f6106
md"""
```@docs
Core.@__doc__
```
"""

# ╔═╡ Cell order:
# ╟─f3e387f4-a6c9-4d20-bd84-501c2d957c45
# ╟─08e90b56-7ab1-4135-9c5e-35953c48e482
# ╟─41e8d0d0-4298-453b-a90e-2980f24aabe0
# ╟─9238b030-7c9d-4e96-a945-6cf43a3a2d6d
# ╟─fbeb1050-1b5a-48ca-9d16-a3c02e802b51
# ╟─d88a7d15-9119-4746-8269-75857f8e42db
# ╟─ee76e55a-9bbc-4f47-9d96-2b83219295c6
# ╟─d2594209-8d69-4261-826a-7da51c65c99a
# ╟─b78ba905-f818-4e8e-aaa1-8e66039d57e5
# ╟─b8ad27e6-4b32-4aa7-85b2-daf7d6ee8195
# ╟─6373cdbd-82c9-4726-b1f2-f896bd5eb41a
# ╟─67b9cf67-28c7-4811-be86-d94f9bbcb643
# ╟─bf60e96f-aa64-4a82-b602-6fb4661d0763
# ╟─ee902920-dafd-4655-9906-4a8c7fda44a0
# ╟─78d437eb-76c1-4a45-a85b-101c68f3d099
# ╟─ed396963-a076-458d-814f-d5fd6cea89e1
# ╟─bba91536-47b4-470e-9ca5-293d06a9974b
# ╟─47635048-4666-4dd4-9582-d2dce4dc7a39
# ╟─964bdb8a-f65a-401d-875f-c67bb387ef5c
# ╟─8984a5e8-c9f4-4729-80ef-a022a3452ae9
# ╟─0f4c4a3d-0f3d-4f59-931d-4ddc35756df9
# ╟─b38863ae-d913-4e0a-8033-45a44371a6e1
# ╟─cdc19292-5262-48c3-8ecd-56e43cdb1f83
# ╟─1605cfa7-4d85-41b1-aa4b-102576e7e5a1
# ╟─f959a845-2722-4825-93bc-d59a658c46fa
# ╟─6c1b9417-c145-4fac-9b21-7dfcecb5b07a
# ╟─33c9fc19-8097-4569-a8c9-99d629bc1f76
# ╟─45b4046a-86c2-4046-b992-355f04ac159e
# ╟─608225f8-de2e-4d7f-8ee3-d094b99ac5d4
# ╟─516266f9-a492-45f4-a572-192576f0334e
# ╟─f306d16f-4a1e-4cda-bfd8-ca1435c7dc4e
# ╟─eb663cf5-0cf1-409d-ad19-38613d42d502
# ╟─fb05e165-6641-459c-a5a7-7bdc3d431f74
# ╟─f8bf1c6a-659d-4884-8f47-49c5ebe3a649
# ╟─d2136ae3-b42d-492f-80a0-28e3f2d65463
# ╟─742a3c82-d686-4495-be53-e9dbde600285
# ╟─c0297cce-28ec-40b8-a4a0-d035acead389
# ╟─a7555344-71fa-4271-9dd8-34d1fea584ab
# ╟─53537da4-6994-4eaa-829c-0d68dd6a02bb
# ╟─e0514271-f37d-46d0-b24f-709cbe46c907
# ╟─6162afc7-4331-4780-a602-f0c80a30bdd4
# ╟─4098eed6-bf8c-43c9-9b87-cba4d470bed3
# ╟─69cf6b6b-70fa-4c90-844e-bece9423348a
# ╟─bf31a15e-e14e-4ad8-aa11-bfbd76df5cf3
# ╟─e8ad9db1-6b94-4138-9ca4-016bd7d65cc0
# ╟─520c4b5f-2d21-4fb8-9be7-5be09810b4dd
# ╟─62e97132-5e9e-44f8-9506-36b4fa3aea9e
# ╟─135dda81-a549-4b3b-8e09-d499b456d76b
# ╟─b1f2c14c-72f9-4ed5-8b5d-165a1a498c9f
# ╟─4a4917c3-57b4-4674-9246-f5e7da5a67e3
# ╟─c3d67efc-dde4-4c04-b63e-e128949daa86
# ╟─fd1ded6e-f550-437a-9998-75f616579099
# ╟─5d8c2aba-fe0e-4013-990d-c971883b10c7
# ╟─5e5cd9ed-7405-4065-8e6b-6e9c4aad8173
# ╟─e11b0acb-1270-432a-b989-771f7a304874
# ╟─442211e1-ac79-4883-8ed3-374c7ebb5372
# ╟─02a6676c-b2de-419a-b445-9f0ceded145b
# ╟─02751e00-5911-4405-ad48-fdd5b7ec8c39
# ╟─2bea28b9-2827-4ba4-b8d9-2ebf4d23c635
# ╟─6bebd6bd-f496-4983-8774-5ddde534a99d
# ╟─1c07c76a-4033-485c-bd03-40126116b0b9
# ╟─e85e2c8c-d35a-4469-952a-376a3cab5bf9
# ╟─a6a76204-8fb4-4409-af6c-cb091d7a2ba6
# ╟─3c578dc5-9a9e-4043-961a-9a28f80f2935
# ╟─5b87c40b-f703-4adb-92ae-d2bebc272f2e
# ╟─db1cb123-9be7-4e0f-9ba4-38af545458d7
# ╟─0ec56ce3-b407-40b6-b10e-8f439e84a310
# ╟─77aa1ac9-5340-48ab-a93d-0d56f56ba939
# ╟─9051f66d-2b48-4b2b-a5d3-6d8ac73153cb
# ╟─e7c759db-2828-445b-8fc1-5d22ef9bd711
# ╟─89fe9d96-b19d-4191-aa00-fa96386c8193
# ╟─fc2727cd-6d5f-4cd0-8c97-fa14af565b02
# ╟─d563ef4d-a374-402b-92f7-c9e4c94db3d5
# ╟─8300e270-3c60-46d2-8504-5b2dc24c0fcf
# ╟─08a13c14-33e9-47f2-813e-e01e7586ac50
# ╟─230b6227-26e3-4166-9f2c-24f07f62f8b1
# ╟─25f93fc4-81c8-4576-ace7-0d832d0268a7
# ╟─a27d4848-6651-4aa5-9f60-2ba6a22359a4
# ╟─3029d476-6ba6-4e1b-87c2-247109dca409
# ╟─d9511067-0d2c-4b03-af55-b767a5b00cd6
# ╟─5a03561e-e8af-48e8-9a80-b443de2dcbbc
# ╟─c1d43728-d35e-4471-8ed2-a431167f6106
