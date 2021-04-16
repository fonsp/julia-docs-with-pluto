### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 4a329a4e-1fe3-431d-98ec-8161764a3ee1
md"""
# Metaprogramming
"""

# ╔═╡ fcf7fb90-a229-4a34-af4d-e1da308a1e78
md"""
The strongest legacy of Lisp in the Julia language is its metaprogramming support. Like Lisp, Julia represents its own code as a data structure of the language itself. Since code is represented by objects that can be created and manipulated from within the language, it is possible for a program to transform and generate its own code. This allows sophisticated code generation without extra build steps, and also allows true Lisp-style macros operating at the level of [abstract syntax trees](https://en.wikipedia.org/wiki/Abstract_syntax_tree). In contrast, preprocessor \"macro\" systems, like that of C and C++, perform textual manipulation and substitution before any actual parsing or interpretation occurs. Because all data types and code in Julia are represented by Julia data structures, powerful [reflection](https://en.wikipedia.org/wiki/Reflection_%28computer_programming%29) capabilities are available to explore the internals of a program and its types just like any other data.
"""

# ╔═╡ 7e910758-9b9d-4eb0-a161-f1b7eac39129
md"""
## Program representation
"""

# ╔═╡ 0167e817-d8d3-4c51-87fe-9bf0619dcff2
md"""
Every Julia program starts life as a string:
"""

# ╔═╡ 36097fc2-d38d-4a6f-9c59-5942f2758803
prog = "1 + 1"

# ╔═╡ 11d110f1-7629-4af9-b3d9-703dcd1b387d
md"""
**What happens next?**
"""

# ╔═╡ 96b8f192-6774-4dde-87a2-64a81f8dbf1f
md"""
The next step is to [parse](https://en.wikipedia.org/wiki/Parsing#Computer_languages) each string into an object called an expression, represented by the Julia type [`Expr`](@ref):
"""

# ╔═╡ 8fcfafa3-f229-44c9-a431-2214b02726d0
ex1 = Meta.parse(prog)

# ╔═╡ 7859f9f6-1443-46db-9657-9f1615e279d6
typeof(ex1)

# ╔═╡ 15a2df63-e2ff-46df-9369-baad4e4dc748
md"""
`Expr` objects contain two parts:
"""

# ╔═╡ 54613218-df4b-4419-a139-cbfc03600cee
md"""
  * a [`Symbol`](@ref) identifying the kind of expression. A symbol is an [interned string](https://en.wikipedia.org/wiki/String_interning) identifier (more discussion below).
"""

# ╔═╡ 36ef56a5-6220-4626-92d5-bee76a2328f7
ex1.head

# ╔═╡ 55904141-a6a2-4cb4-b062-73783a1f5cbf
md"""
  * the expression arguments, which may be symbols, other expressions, or literal values:
"""

# ╔═╡ 4e1a9122-0c7f-4f28-93f5-656daf84ecf7
ex1.args

# ╔═╡ e7318bff-ae20-4ddc-b0d9-2ad950123f1a
md"""
Expressions may also be constructed directly in [prefix notation](https://en.wikipedia.org/wiki/Polish_notation):
"""

# ╔═╡ 33ee25b5-147f-40ec-a245-10752bdf73d5
ex2 = Expr(:call, :+, 1, 1)

# ╔═╡ 6187fc22-7e83-4b7d-876f-e1b18f597a56
md"""
The two expressions constructed above – by parsing and by direct construction – are equivalent:
"""

# ╔═╡ f3db3506-1417-4d5c-9d3c-550ce11b12a2
ex1 == ex2

# ╔═╡ d5505c6f-8897-467b-aec3-ac106f7d2a81
md"""
**The key point here is that Julia code is internally represented as a data structure that is accessible from the language itself.**
"""

# ╔═╡ da20398b-0959-4024-be1a-cd336f6fd596
md"""
The [`dump`](@ref) function provides indented and annotated display of `Expr` objects:
"""

# ╔═╡ 208960e1-6204-4df6-93e3-5586c8111e54
dump(ex2)

# ╔═╡ 0f99abc3-4700-4846-8128-572e88c1c426
md"""
`Expr` objects may also be nested:
"""

# ╔═╡ 1c3802e8-d7e9-4454-9729-dd108c1fdf8f
ex3 = Meta.parse("(4 + 4) / 2")

# ╔═╡ 620275f6-5e71-4a48-8df8-cc8e6e3d91e9
md"""
Another way to view expressions is with `Meta.show_sexpr`, which displays the [S-expression](https://en.wikipedia.org/wiki/S-expression) form of a given `Expr`, which may look very familiar to users of Lisp. Here's an example illustrating the display on a nested `Expr`:
"""

# ╔═╡ fefeb34f-3d1e-4b18-bb37-26f7a08de741
Meta.show_sexpr(ex3)

# ╔═╡ 5a251167-1ca2-4311-800c-8a65fd8bce27
md"""
### Symbols
"""

# ╔═╡ c3875772-7266-475c-82f0-f574df3e00f9
md"""
The `:` character has two syntactic purposes in Julia. The first form creates a [`Symbol`](@ref), an [interned string](https://en.wikipedia.org/wiki/String_interning) used as one building-block of expressions:
"""

# ╔═╡ 53c5a159-79ad-4fbb-be77-28d9f5ce355a
s = :foo

# ╔═╡ 0ed50b34-bf20-4cae-abbf-a23bb2a6b3e1
typeof(s)

# ╔═╡ 77270b5d-db24-4034-9acb-df32bfc0046e
md"""
The [`Symbol`](@ref) constructor takes any number of arguments and creates a new symbol by concatenating their string representations together:
"""

# ╔═╡ b8e25ef0-31e4-45ca-8641-94a722dcd04c
:foo == Symbol("foo")

# ╔═╡ 37039812-4c1a-4a83-b226-de3e3bb46708
Symbol("func",10)

# ╔═╡ 55b7d0c1-2313-4aab-a91d-3f8df3aad0f8
Symbol(:var,'_',"sym")

# ╔═╡ d69d7939-28af-4d27-8160-5ce95352d0f5
md"""
Note that to use `:` syntax, the symbol's name must be a valid identifier. Otherwise the `Symbol(str)` constructor must be used.
"""

# ╔═╡ 80d66efe-4dfd-4b2b-9c8f-086d89c0f57c
md"""
In the context of an expression, symbols are used to indicate access to variables; when an expression is evaluated, a symbol is replaced with the value bound to that symbol in the appropriate [scope](@ref scope-of-variables).
"""

# ╔═╡ 3ad47a4e-c1a0-40f6-b060-6e81ba4b5fce
md"""
Sometimes extra parentheses around the argument to `:` are needed to avoid ambiguity in parsing:
"""

# ╔═╡ 0d2d15b7-a8db-409c-b583-55ad3b31f7b7
:(:)

# ╔═╡ 89162a72-fc8a-4ae8-b879-92257bfab63f
:(::)

# ╔═╡ bb530cb9-1ca7-4c97-8d16-18390d77ceb9
md"""
## Expressions and evaluation
"""

# ╔═╡ bd81c653-8361-40b8-9ce7-5996a124fe67
md"""
### Quoting
"""

# ╔═╡ 7aee02ac-e84f-4e07-9fd6-29864de59dfd
md"""
The second syntactic purpose of the `:` character is to create expression objects without using the explicit [`Expr`](@ref) constructor. This is referred to as *quoting*. The `:` character, followed by paired parentheses around a single statement of Julia code, produces an `Expr` object based on the enclosed code. Here is example of the short form used to quote an arithmetic expression:
"""

# ╔═╡ 1018af97-73a3-4e9e-9e7e-a2249a37abb9
ex = :(a+b*c+1)

# ╔═╡ e8db5d80-7350-40e3-812d-42fa5293abb0
typeof(ex)

# ╔═╡ ceeea500-f6c8-4743-9d22-9b72c7da7ed7
md"""
(to view the structure of this expression, try `ex.head` and `ex.args`, or use [`dump`](@ref) as above or [`Meta.@dump`](@ref))
"""

# ╔═╡ 37827ba6-65ab-4dd9-82f5-310cb30a0712
md"""
Note that equivalent expressions may be constructed using [`Meta.parse`](@ref) or the direct `Expr` form:
"""

# ╔═╡ 5a6edb10-f59a-4874-8eaa-a52eb8991771
:(a + b*c + 1)       ==
 Meta.parse("a + b*c + 1") ==
 Expr(:call, :+, :a, Expr(:call, :*, :b, :c), 1)

# ╔═╡ 52404149-600f-48f8-9e8d-5e8c9b0b0a04
md"""
Expressions provided by the parser generally only have symbols, other expressions, and literal values as their args, whereas expressions constructed by Julia code can have arbitrary run-time values without literal forms as args. In this specific example, `+` and `a` are symbols, `*(b,c)` is a subexpression, and `1` is a literal 64-bit signed integer.
"""

# ╔═╡ 3fcb66c2-4e66-4f45-a7e7-65036efca00a
md"""
There is a second syntactic form of quoting for multiple expressions: blocks of code enclosed in `quote ... end`.
"""

# ╔═╡ d958acef-73fe-4109-9967-24e5f4ca569f
ex = quote
     x = 1
     y = 2
     x + y
 end

# ╔═╡ ba42645b-fb45-4221-8d40-9840cb02264c
typeof(ex)

# ╔═╡ 2128a38f-7b95-449c-b561-06268ddc755b
md"""
### [Interpolation](@id man-expression-interpolation)
"""

# ╔═╡ 03d378b5-4419-41e2-91e9-cd0ba96e3f0c
md"""
Direct construction of [`Expr`](@ref) objects with value arguments is powerful, but `Expr` constructors can be tedious compared to \"normal\" Julia syntax. As an alternative, Julia allows *interpolation* of literals or expressions into quoted expressions. Interpolation is indicated by a prefix `$`.
"""

# ╔═╡ 44e77b14-6cab-46fb-adb7-67e75dc0857b
md"""
In this example, the value of variable `a` is interpolated:
"""

# ╔═╡ 63ff3614-7d0f-4c5e-9bb5-49170e5aa724
a = 1;

# ╔═╡ 4d55b495-251d-4306-a7de-96517a0f27db
ex = :($a + b)

# ╔═╡ 38ceea8c-8c47-40eb-93bd-f1b4d2fb1dd7
md"""
Interpolating into an unquoted expression is not supported and will cause a compile-time error:
"""

# ╔═╡ d9435823-a23b-4a48-9b20-a8a60cbd5642
$a + b

# ╔═╡ 452953e8-0b5e-4ec1-b186-920c3c3a6a92
md"""
In this example, the tuple `(1,2,3)` is interpolated as an expression into a conditional test:
"""

# ╔═╡ 4252a8c4-fbc1-478e-9853-bd14ae34028b
ex = :(a in $:((1,2,3)) )

# ╔═╡ ade9fd13-8cae-4fa4-9177-4d4f95e648fa
md"""
The use of `$` for expression interpolation is intentionally reminiscent of [string interpolation](@ref string-interpolation) and [command interpolation](@ref command-interpolation). Expression interpolation allows convenient, readable programmatic construction of complex Julia expressions.
"""

# ╔═╡ a3abc7e4-82dc-44f9-a36d-2bb887485366
md"""
### Splatting interpolation
"""

# ╔═╡ 43cc1bf6-bb71-4283-bcac-9f1e5beb6320
md"""
Notice that the `$` interpolation syntax allows inserting only a single expression into an enclosing expression. Occasionally, you have an array of expressions and need them all to become arguments of the surrounding expression. This can be done with the syntax `$(xs...)`. For example, the following code generates a function call where the number of arguments is determined programmatically:
"""

# ╔═╡ ee9cdf5f-fbe3-4739-9a0f-0807a71832e1
args = [:x, :y, :z];

# ╔═╡ 8c80e767-c31e-4b90-a796-3bd172807b99
:(f(1, $(args...)))

# ╔═╡ e9060435-8f4d-4d3b-a712-6d4c996ed5a5
md"""
### Nested quote
"""

# ╔═╡ 159f3cb2-3db5-4353-a856-653feacb5e92
md"""
Naturally, it is possible for quote expressions to contain other quote expressions. Understanding how interpolation works in these cases can be a bit tricky. Consider this example:
"""

# ╔═╡ b9ad3232-5587-4a03-89cf-98538cf6768e
x = :(1 + 2);

# ╔═╡ 42e7f30a-da9e-431a-8f3d-6a86c37a42a8
e = quote quote $x end end

# ╔═╡ f3eee563-1bca-49e9-892a-02f0f7f383fb
md"""
Notice that the result contains `$x`, which means that `x` has not been evaluated yet. In other words, the `$` expression \"belongs to\" the inner quote expression, and so its argument is only evaluated when the inner quote expression is:
"""

# ╔═╡ c4955aff-fe45-4f25-ba4a-76cf37cbf313
eval(e)

# ╔═╡ 8f3c873c-ea0a-476b-b976-c4952d0862c4
md"""
However, the outer `quote` expression is able to interpolate values inside the `$` in the inner quote. This is done with multiple `$`s:
"""

# ╔═╡ ccf86fe2-36fb-4cc4-9896-f57908929057
e = quote quote $$x end end

# ╔═╡ f1f4f452-3a8b-460d-90c4-a8051081baa5
md"""
Notice that `(1 + 2)` now appears in the result instead of the symbol `x`. Evaluating this expression yields an interpolated `3`:
"""

# ╔═╡ 9eb4d9b8-8d0e-45aa-918f-a4c15f0fc7dd
eval(e)

# ╔═╡ 6eb1be2c-1380-40c4-9ad4-97df4bd0c00e
md"""
The intuition behind this behavior is that `x` is evaluated once for each `$`: one `$` works similarly to `eval(:x)`, giving `x`'s value, while two `$`s do the equivalent of `eval(eval(:x))`.
"""

# ╔═╡ e2fc1d1c-8926-4d6d-b98c-272513971354
md"""
### [QuoteNode](@id man-quote-node)
"""

# ╔═╡ be25c407-2da0-4a73-8d61-f397809c6a0d
md"""
The usual representation of a `quote` form in an AST is an [`Expr`](@ref) with head `:quote`:
"""

# ╔═╡ 555a7c0a-19b9-4fa5-bfed-18e87b944a08
dump(Meta.parse(":(1+2)"))

# ╔═╡ 613595ed-d306-4c9b-a02c-002d8adbfc7c
md"""
As we have seen, such expressions support interpolation with `$`. However, in some situations it is necessary to quote code *without* performing interpolation. This kind of quoting does not yet have syntax, but is represented internally as an object of type `QuoteNode`:
"""

# ╔═╡ f7e81888-47e6-46fc-8328-1fb859e60541
eval(Meta.quot(Expr(:$, :(1+2))))

# ╔═╡ 86cf0594-0cb9-4385-9eac-931ef2ec7230
eval(QuoteNode(Expr(:$, :(1+2))))

# ╔═╡ ee702c43-2fb0-4772-858d-cf8c914a82bf
md"""
The parser yields `QuoteNode`s for simple quoted items like symbols:
"""

# ╔═╡ 56964666-aaa8-4e5b-9032-27899e9e9021
dump(Meta.parse(":x"))

# ╔═╡ 92b11cbe-9bd5-4ffa-b847-1e49bc399c64
md"""
`QuoteNode` can also be used for certain advanced metaprogramming tasks.
"""

# ╔═╡ bdd51c19-3ac2-42ee-bce2-cc63d25c45f1
md"""
### Evaluating expressions
"""

# ╔═╡ 8c70bcc3-1f62-43c2-875a-10e0349f6ff7
md"""
Given an expression object, one can cause Julia to evaluate (execute) it at global scope using [`eval`](@ref):
"""

# ╔═╡ 1bc594e5-f04a-41de-8ae0-83d5e0a0b1c9
ex1 = :(1 + 2)

# ╔═╡ e21a813e-1f35-4e61-9d24-dfe075e20bfa
eval(ex1)

# ╔═╡ 6537044b-c279-4e5b-8b8d-aeece11678de
ex = :(a + b)

# ╔═╡ 0a5e1a3e-9613-4972-b8e5-eebd16fc2538
eval(ex)

# ╔═╡ 633972c2-e96d-482e-8a36-55b090d6f31e
a = 1; b = 2;

# ╔═╡ 094811c3-f379-482c-8e2b-2e31d2b2dae6
eval(ex)

# ╔═╡ 1810881a-502d-44d0-9f25-e179b0a3fdc3
md"""
Every [module](@ref modules) has its own [`eval`](@ref) function that evaluates expressions in its global scope. Expressions passed to [`eval`](@ref) are not limited to returning values – they can also have side-effects that alter the state of the enclosing module's environment:
"""

# ╔═╡ b4d7164c-5ebc-4e03-8750-d4303d5040fc
ex = :(x = 1)

# ╔═╡ 9174d44b-3cb8-481d-8625-89a34974fc5b
x

# ╔═╡ 4f685b00-8535-462a-b017-342a94f38c37
eval(ex)

# ╔═╡ 408fbb67-959f-4a68-a8b3-1630f41d24d1
x

# ╔═╡ ac140b00-a8c3-4e81-8d83-b65155d1f8a0
md"""
Here, the evaluation of an expression object causes a value to be assigned to the global variable `x`.
"""

# ╔═╡ 5511e05a-be65-4295-b1ff-b1204bbf6e8a
md"""
Since expressions are just `Expr` objects which can be constructed programmatically and then evaluated, it is possible to dynamically generate arbitrary code which can then be run using [`eval`](@ref). Here is a simple example:
"""

# ╔═╡ af23182f-10e9-4dfb-ac33-6e161a2f4889
a = 1;

# ╔═╡ 48f159ac-073c-4b4e-bdac-f6d65d24ef6d
ex = Expr(:call, :+, a, :b)

# ╔═╡ d4f5c5d2-b6af-4d6c-b1c1-729580dbb94f
a = 0; b = 2;

# ╔═╡ 590c8581-b7d5-4cb4-acda-b1ceafbd113b
eval(ex)

# ╔═╡ 7655bf82-840f-48e0-a0ba-fc2063bc2307
md"""
The value of `a` is used to construct the expression `ex` which applies the `+` function to the value 1 and the variable `b`. Note the important distinction between the way `a` and `b` are used:
"""

# ╔═╡ 0a5469c9-ccef-4b62-9f0f-d3552fb3b986
md"""
  * The value of the *variable* `a` at expression construction time is used as an immediate value in the expression. Thus, the value of `a` when the expression is evaluated no longer matters: the value in the expression is already `1`, independent of whatever the value of `a` might be.
  * On the other hand, the *symbol* `:b` is used in the expression construction, so the value of the variable `b` at that time is irrelevant – `:b` is just a symbol and the variable `b` need not even be defined. At expression evaluation time, however, the value of the symbol `:b` is resolved by looking up the value of the variable `b`.
"""

# ╔═╡ 91b8a80e-5f65-4387-acf2-5fb87692789d
md"""
### Functions on `Expr`essions
"""

# ╔═╡ 9ee35586-1af3-43ab-b1ba-5b3bb67ebb34
md"""
As hinted above, one extremely useful feature of Julia is the capability to generate and manipulate Julia code within Julia itself. We have already seen one example of a function returning [`Expr`](@ref) objects: the [`parse`](@ref) function, which takes a string of Julia code and returns the corresponding `Expr`. A function can also take one or more `Expr` objects as arguments, and return another `Expr`. Here is a simple, motivating example:
"""

# ╔═╡ 5e0c39cc-b506-45de-897e-afd46895836d
function math_expr(op, op1, op2)
     expr = Expr(:call, op, op1, op2)
     return expr
 end

# ╔═╡ 8b221b0f-36b2-4ac5-9957-68b2168ba517
ex = math_expr(:+, 1, Expr(:call, :*, 4, 5))

# ╔═╡ f8cefa6a-eece-4aca-930f-455eb7fe1914
eval(ex)

# ╔═╡ 5e3b7f2c-e329-4273-9a03-6d8a73608111
md"""
As another example, here is a function that doubles any numeric argument, but leaves expressions alone:
"""

# ╔═╡ 3e01b90a-d9eb-4b71-809b-0dc9be003933
function make_expr2(op, opr1, opr2)
     opr1f, opr2f = map(x -> isa(x, Number) ? 2*x : x, (opr1, opr2))
     retexpr = Expr(:call, op, opr1f, opr2f)
     return retexpr
 end

# ╔═╡ 73f1405c-a7c0-498a-a038-dadec51ecd27
make_expr2(:+, 1, 2)

# ╔═╡ 4ded730f-d9bf-4c02-8631-c7c51afe9a87
ex = make_expr2(:+, 1, Expr(:call, :*, 5, 8))

# ╔═╡ c3e1d72f-f4a9-49a8-9463-f339cb0b7b2c
eval(ex)

# ╔═╡ 64f2099f-1105-44a7-81a6-a994a9a04d42
md"""
## [Macros](@id man-macros)
"""

# ╔═╡ f048bbf0-6d7a-4a59-9399-d54097ccf829
md"""
Macros provide a method to include generated code in the final body of a program. A macro maps a tuple of arguments to a returned *expression*, and the resulting expression is compiled directly rather than requiring a runtime [`eval`](@ref) call. Macro arguments may include expressions, literal values, and symbols.
"""

# ╔═╡ 3ce27869-3376-43d9-b7f2-8f7fec825e2e
md"""
### Basics
"""

# ╔═╡ ecf455bc-76fe-4cbe-b953-67371e614292
md"""
Here is an extraordinarily simple macro:
"""

# ╔═╡ 75c33720-2ad3-4b7f-a793-a9c2d92a984a
macro sayhello()
     return :( println("Hello, world!") )
 end

# ╔═╡ e22c2662-6933-4715-98cd-6d7c4db46a0c
md"""
Macros have a dedicated character in Julia's syntax: the `@` (at-sign), followed by the unique name declared in a `macro NAME ... end` block. In this example, the compiler will replace all instances of `@sayhello` with:
"""

# ╔═╡ ed26c3c1-a93f-4f69-b654-2b419503d422
md"""
```julia
:( println(\"Hello, world!\") )
```
"""

# ╔═╡ 3513f124-bec4-48fc-bf89-f9dafe70f9f4
md"""
When `@sayhello` is entered in the REPL, the expression executes immediately, thus we only see the evaluation result:
"""

# ╔═╡ 71415783-382f-4f44-88b5-61d4d60faa30
@sayhello()

# ╔═╡ 0963a1f3-aac8-40e6-93d5-6fd6e8ba0730
md"""
Now, consider a slightly more complex macro:
"""

# ╔═╡ 3047d86a-1a72-414d-a07e-da6bd9201be9
macro sayhello(name)
     return :( println("Hello, ", $name) )
 end

# ╔═╡ b46ab3b3-8046-4e89-af4a-50f0b312c9b7
md"""
This macro takes one argument: `name`. When `@sayhello` is encountered, the quoted expression is *expanded* to interpolate the value of the argument into the final expression:
"""

# ╔═╡ f77e4f70-c123-4c6e-b796-9c04bddf1109
@sayhello("human")

# ╔═╡ fee9f20b-9215-4d74-b8d1-dda548e424d6
md"""
We can view the quoted return expression using the function [`macroexpand`](@ref) (**important note:** this is an extremely useful tool for debugging macros):
"""

# ╔═╡ 14921103-4720-44b9-bd67-c390278cc0e4
ex = macroexpand(Main, :(@sayhello("human")) )

# ╔═╡ 0c866a9a-e612-4730-b528-9d506ea19fe7
typeof(ex)

# ╔═╡ 63471543-034d-4f19-811b-32d64d4fd115
md"""
We can see that the `\"human\"` literal has been interpolated into the expression.
"""

# ╔═╡ fb4452b8-c16a-4bbf-a6dc-c142c11998cf
md"""
There also exists a macro [`@macroexpand`](@ref) that is perhaps a bit more convenient than the `macroexpand` function:
"""

# ╔═╡ bc63e678-3b03-4330-bb5c-b00fd610bd46
@macroexpand @sayhello "human"

# ╔═╡ 294ac76a-e11c-43f8-b9b9-1fc5b9a36871
md"""
### Hold up: why macros?
"""

# ╔═╡ cd2366f7-6528-4ae6-83cb-dc82b89287b1
md"""
We have already seen a function `f(::Expr...) -> Expr` in a previous section. In fact, [`macroexpand`](@ref) is also such a function. So, why do macros exist?
"""

# ╔═╡ f978c9c7-ec5b-4162-92b4-95b16efed6ad
md"""
Macros are necessary because they execute when code is parsed, therefore, macros allow the programmer to generate and include fragments of customized code *before* the full program is run. To illustrate the difference, consider the following example:
"""

# ╔═╡ c7a9233d-374a-4981-8e43-166d8a3ff042
macro twostep(arg)
     println("I execute at parse time. The argument is: ", arg)
     return :(println("I execute at runtime. The argument is: ", $arg))
 end

# ╔═╡ f72565d4-8f25-4cb4-9f7f-19dff4cf78da
ex = macroexpand(Main, :(@twostep :(1, 2, 3)) );

# ╔═╡ 30004803-2216-4b8d-9267-1d3dbd7ab072
md"""
The first call to [`println`](@ref) is executed when [`macroexpand`](@ref) is called. The resulting expression contains *only* the second `println`:
"""

# ╔═╡ 2d4bfe38-5121-4128-a0e0-165f16cacd70
typeof(ex)

# ╔═╡ 6e65d136-ad27-4db6-abf3-f8e6bfc7b83c
ex

# ╔═╡ d650ea8f-589b-4cf3-9c55-d4f24a6b9a3d
eval(ex)

# ╔═╡ 95e0e154-7479-4216-952f-55c33200ab17
md"""
### Macro invocation
"""

# ╔═╡ 364f58d3-706b-4a99-83a7-d72d2c2acc1b
md"""
Macros are invoked with the following general syntax:
"""

# ╔═╡ b90e2c60-561a-4afd-a41f-c0b0b87ca60c
md"""
```julia
@name expr1 expr2 ...
@name(expr1, expr2, ...)
```
"""

# ╔═╡ 589dbb6d-bfa0-449f-8bfe-da83ebaa6f6e
md"""
Note the distinguishing `@` before the macro name and the lack of commas between the argument expressions in the first form, and the lack of whitespace after `@name` in the second form. The two styles should not be mixed. For example, the following syntax is different from the examples above; it passes the tuple `(expr1, expr2, ...)` as one argument to the macro:
"""

# ╔═╡ cc8f4ed9-7dac-45d2-8d59-4171939c9915
md"""
```julia
@name (expr1, expr2, ...)
```
"""

# ╔═╡ 4be03b12-208b-4034-9056-3100b69486d1
md"""
An alternative way to invoke a macro over an array literal (or comprehension) is to juxtapose both without using parentheses. In this case, the array will be the only expression fed to the macro. The following syntax is equivalent (and different from `@name [a b] * v`):
"""

# ╔═╡ 1c556d0a-5525-4e2c-80f2-0207af774553
md"""
```julia
@name[a b] * v
@name([a b]) * v
```
"""

# ╔═╡ 309a286b-78d9-4ff0-859c-a6a6f0abf34b
md"""
It is important to emphasize that macros receive their arguments as expressions, literals, or symbols. One way to explore macro arguments is to call the [`show`](@ref) function within the macro body:
"""

# ╔═╡ 336da33b-aa63-4bae-a82a-f847fa40b9b0
macro showarg(x)
     show(x)
     # ... remainder of macro, returning an expression
 end

# ╔═╡ 560f7df8-821d-43cc-8077-ab98b0779296
@showarg(a)

# ╔═╡ 8953fe37-0e8b-4d00-816e-a1050acc8635
@showarg(1+1)

# ╔═╡ a64d78c8-8728-4fbe-9bb6-311bde057a43
@showarg(println("Yo!"))

# ╔═╡ 58a065aa-b40e-46e9-be19-733bdad3837b
md"""
In addition to the given argument list, every macro is passed extra arguments named `__source__` and `__module__`.
"""

# ╔═╡ 9aba8e4a-3f76-45ed-add5-e0f5f6fc5485
md"""
The argument `__source__` provides information (in the form of a `LineNumberNode` object) about the parser location of the `@` sign from the macro invocation. This allows macros to include better error diagnostic information, and is commonly used by logging, string-parser macros, and docs, for example, as well as to implement the [`@__LINE__`](@ref), [`@__FILE__`](@ref), and [`@__DIR__`](@ref) macros.
"""

# ╔═╡ 884121d0-9980-40bc-bcb3-c941ca75f206
md"""
The location information can be accessed by referencing `__source__.line` and `__source__.file`:
"""

# ╔═╡ a66a975e-1af7-4403-b9ce-c88ba9695a86
macro __LOCATION__(); return QuoteNode(__source__); end

# ╔═╡ df7198a4-b334-44c5-9396-ca0dc79f2395
dump(
      @__LOCATION__(
 ))

# ╔═╡ 2211b1cc-d9dd-4bd5-bf55-0dcdab169317
md"""
The argument `__module__` provides information (in the form of a `Module` object) about the expansion context of the macro invocation. This allows macros to look up contextual information, such as existing bindings, or to insert the value as an extra argument to a runtime function call doing self-reflection in the current module.
"""

# ╔═╡ 1a620020-ab6d-4454-bc60-fa727d2be594
md"""
### Building an advanced macro
"""

# ╔═╡ 9057076e-ab4f-46d2-9f50-9b56f86f9445
md"""
Here is a simplified definition of Julia's [`@assert`](@ref) macro:
"""

# ╔═╡ 214b0788-a678-482a-b9e1-ba388ee41207
macro assert(ex)
     return :( $ex ? nothing : throw(AssertionError($(string(ex)))) )
 end

# ╔═╡ 91bc0ab4-44ca-4bb6-8543-4dcd0eb042ed
md"""
This macro can be used like this:
"""

# ╔═╡ 3fb1e2a0-393b-4051-8fc1-caf74e997ca2
@assert 1 == 1.0

# ╔═╡ 38f53163-88f0-4532-b6c0-cda08ed9f551
@assert 1 == 0

# ╔═╡ cb20682c-1d0c-4d88-b5e8-6792ec54bbd9
md"""
In place of the written syntax, the macro call is expanded at parse time to its returned result. This is equivalent to writing:
"""

# ╔═╡ bb43e482-196c-4864-a0ff-40e767914429
md"""
```julia
1 == 1.0 ? nothing : throw(AssertionError(\"1 == 1.0\"))
1 == 0 ? nothing : throw(AssertionError(\"1 == 0\"))
```
"""

# ╔═╡ 1c4f7db3-c88a-4bde-a418-5bfdc7809409
md"""
That is, in the first call, the expression `:(1 == 1.0)` is spliced into the test condition slot, while the value of `string(:(1 == 1.0))` is spliced into the assertion message slot. The entire expression, thus constructed, is placed into the syntax tree where the `@assert` macro call occurs. Then at execution time, if the test expression evaluates to true, then [`nothing`](@ref) is returned, whereas if the test is false, an error is raised indicating the asserted expression that was false. Notice that it would not be possible to write this as a function, since only the *value* of the condition is available and it would be impossible to display the expression that computed it in the error message.
"""

# ╔═╡ e8777260-736f-4006-a3ed-23e2b61b52de
md"""
The actual definition of `@assert` in Julia Base is more complicated. It allows the user to optionally specify their own error message, instead of just printing the failed expression. Just like in functions with a variable number of arguments ([Varargs Functions](@ref)), this is specified with an ellipses following the last argument:
"""

# ╔═╡ c0e000b2-f297-47c3-9ad5-5570494a6204
macro assert(ex, msgs...)
     msg_body = isempty(msgs) ? ex : msgs[1]
     msg = string(msg_body)
     return :($ex ? nothing : throw(AssertionError($msg)))
 end

# ╔═╡ ff48656f-4367-49ca-bea6-65d5113fd0cc
md"""
Now `@assert` has two modes of operation, depending upon the number of arguments it receives! If there's only one argument, the tuple of expressions captured by `msgs` will be empty and it will behave the same as the simpler definition above. But now if the user specifies a second argument, it is printed in the message body instead of the failing expression. You can inspect the result of a macro expansion with the aptly named [`@macroexpand`](@ref) macro:
"""

# ╔═╡ 5f71e871-d6d7-4de5-94f4-226d83741df7
@macroexpand @assert a == b

# ╔═╡ b6db6abb-0c47-4c36-b533-fb23b51cad5c
@macroexpand @assert a==b "a should equal b!"

# ╔═╡ 5b78bbfc-41f2-4073-8903-e538da17d0e0
md"""
There is yet another case that the actual `@assert` macro handles: what if, in addition to printing \"a should equal b,\" we wanted to print their values? One might naively try to use string interpolation in the custom message, e.g., `@assert a==b \"a ($a) should equal b ($b)!\"`, but this won't work as expected with the above macro. Can you see why? Recall from [string interpolation](@ref string-interpolation) that an interpolated string is rewritten to a call to [`string`](@ref). Compare:
"""

# ╔═╡ 51429238-d677-471f-b73b-fde1828ed060
typeof(:("a should equal b"))

# ╔═╡ f0191618-680f-47c0-b6fa-6e4a6edf3f2f
typeof(:("a ($a) should equal b ($b)!"))

# ╔═╡ 2d5f5dbc-10a6-4f37-96bb-af98cfeadc42
dump(:("a ($a) should equal b ($b)!"))

# ╔═╡ c46af693-c9fc-405f-8b05-70b395f5b8b2
md"""
So now instead of getting a plain string in `msg_body`, the macro is receiving a full expression that will need to be evaluated in order to display as expected. This can be spliced directly into the returned expression as an argument to the [`string`](@ref) call; see [`error.jl`](https://github.com/JuliaLang/julia/blob/master/base/error.jl) for the complete implementation.
"""

# ╔═╡ 72c5f262-09ed-4865-acc0-7819b3e439bd
md"""
The `@assert` macro makes great use of splicing into quoted expressions to simplify the manipulation of expressions inside the macro body.
"""

# ╔═╡ b02f2238-11bd-4e82-a8d8-e3ba2218dffb
md"""
### Hygiene
"""

# ╔═╡ f2568ed4-a219-4d42-be7d-cae074280740
md"""
An issue that arises in more complex macros is that of [hygiene](https://en.wikipedia.org/wiki/Hygienic_macro). In short, macros must ensure that the variables they introduce in their returned expressions do not accidentally clash with existing variables in the surrounding code they expand into. Conversely, the expressions that are passed into a macro as arguments are often *expected* to evaluate in the context of the surrounding code, interacting with and modifying the existing variables. Another concern arises from the fact that a macro may be called in a different module from where it was defined. In this case we need to ensure that all global variables are resolved to the correct module. Julia already has a major advantage over languages with textual macro expansion (like C) in that it only needs to consider the returned expression. All the other variables (such as `msg` in `@assert` above) follow the [normal scoping block behavior](@ref scope-of-variables).
"""

# ╔═╡ a4697205-d518-4704-a6f0-26d3152da54a
md"""
To demonstrate these issues, let us consider writing a `@time` macro that takes an expression as its argument, records the time, evaluates the expression, records the time again, prints the difference between the before and after times, and then has the value of the expression as its final value. The macro might look like this:
"""

# ╔═╡ 0ebea417-c177-4636-9d09-5315487a908d
md"""
```julia
macro time(ex)
    return quote
        local t0 = time_ns()
        local val = $ex
        local t1 = time_ns()
        println(\"elapsed time: \", (t1-t0)/1e9, \" seconds\")
        val
    end
end
```
"""

# ╔═╡ 495471b9-722d-420b-b2f6-2bebb570637e
md"""
Here, we want `t0`, `t1`, and `val` to be private temporary variables, and we want `time_ns` to refer to the [`time_ns`](@ref) function in Julia Base, not to any `time_ns` variable the user might have (the same applies to `println`). Imagine the problems that could occur if the user expression `ex` also contained assignments to a variable called `t0`, or defined its own `time_ns` variable. We might get errors, or mysteriously incorrect behavior.
"""

# ╔═╡ 5410304a-635a-4a46-97b3-3f186e548212
md"""
Julia's macro expander solves these problems in the following way. First, variables within a macro result are classified as either local or global. A variable is considered local if it is assigned to (and not declared global), declared local, or used as a function argument name. Otherwise, it is considered global. Local variables are then renamed to be unique (using the [`gensym`](@ref) function, which generates new symbols), and global variables are resolved within the macro definition environment. Therefore both of the above concerns are handled; the macro's locals will not conflict with any user variables, and `time_ns` and `println` will refer to the Julia Base definitions.
"""

# ╔═╡ 59e0100b-34cb-4169-b56e-72b405b47254
md"""
One problem remains however. Consider the following use of this macro:
"""

# ╔═╡ ef62fc92-8fc8-4979-a224-d0681fb4c4cb
md"""
```julia
module MyModule
import Base.@time

time_ns() = ... # compute something

@time time_ns()
end
```
"""

# ╔═╡ 5242bb32-5da5-4bc7-a2f7-a742bcd8dba1
md"""
Here the user expression `ex` is a call to `time_ns`, but not the same `time_ns` function that the macro uses. It clearly refers to `MyModule.time_ns`. Therefore we must arrange for the code in `ex` to be resolved in the macro call environment. This is done by \"escaping\" the expression with [`esc`](@ref):
"""

# ╔═╡ fe083f76-0186-483c-88fb-8cf452c9c572
md"""
```julia
macro time(ex)
    ...
    local val = $(esc(ex))
    ...
end
```
"""

# ╔═╡ 315e2bcf-b794-4f34-b158-9b03d3560907
md"""
An expression wrapped in this manner is left alone by the macro expander and simply pasted into the output verbatim. Therefore it will be resolved in the macro call environment.
"""

# ╔═╡ 30f8abfb-b8f5-4e3a-95e9-493254f393e1
md"""
This escaping mechanism can be used to \"violate\" hygiene when necessary, in order to introduce or manipulate user variables. For example, the following macro sets `x` to zero in the call environment:
"""

# ╔═╡ a35e724c-990f-4285-803d-8b0f9416c210
macro zerox()
     return esc(:(x = 0))
 end

# ╔═╡ bc43c33b-c8c5-4c87-830d-f399e3045829
function foo()
     x = 1
     @zerox
     return x # is zero
 end

# ╔═╡ 9e5a5f02-740e-489e-87d0-f36ac029e73a
foo()

# ╔═╡ 227d08c8-0058-4da3-a590-5092da62c776
md"""
This kind of manipulation of variables should be used judiciously, but is occasionally quite handy.
"""

# ╔═╡ c4c18d92-a287-4824-99ba-df08bf1f726e
md"""
Getting the hygiene rules correct can be a formidable challenge. Before using a macro, you might want to consider whether a function closure would be sufficient. Another useful strategy is to defer as much work as possible to runtime. For example, many macros simply wrap their arguments in a `QuoteNode` or other similar [`Expr`](@ref). Some examples of this include `@task body` which simply returns `schedule(Task(() -> $body))`, and `@eval expr`, which simply returns `eval(QuoteNode(expr))`.
"""

# ╔═╡ 22d6de99-7df5-4c8f-b7e0-52d469f94c83
md"""
To demonstrate, we might rewrite the `@time` example above as:
"""

# ╔═╡ 124b5200-4a27-45b7-bd16-10ed18deab49
md"""
```julia
macro time(expr)
    return :(timeit(() -> $(esc(expr))))
end
function timeit(f)
    t0 = time_ns()
    val = f()
    t1 = time_ns()
    println(\"elapsed time: \", (t1-t0)/1e9, \" seconds\")
    return val
end
```
"""

# ╔═╡ a016c4cb-3c51-4b13-a303-a399c7b9a72e
md"""
However, we don't do this for a good reason: wrapping the `expr` in a new scope block (the anonymous function) also slightly changes the meaning of the expression (the scope of any variables in it), while we want `@time` to be usable with minimum impact on the wrapped code.
"""

# ╔═╡ 1c72d267-1d88-4133-896a-9ff51a3b4a04
md"""
### Macros and dispatch
"""

# ╔═╡ cc237a28-d512-4cca-b529-45771cc5b4de
md"""
Macros, just like Julia functions, are generic. This means they can also have multiple method definitions, thanks to multiple dispatch:
"""

# ╔═╡ 71771d99-ad11-4ea5-93f6-4f0254548d61
macro m end

# ╔═╡ de94ec4d-04c9-4568-9ce4-ab938cdb1ac1
macro m(args...)
     println("$(length(args)) arguments")
 end

# ╔═╡ ebf78bef-6d08-4d95-8cd8-35352698d2b4
macro m(x,y)
     println("Two arguments")
 end

# ╔═╡ 3ebe7ef8-b9e8-48cf-99c9-d4437299d28f
@m "asd"

# ╔═╡ ddd41fa7-5f8a-4ed6-bef9-39c2ed9943d0
@m 1 2

# ╔═╡ 86facd67-9b0a-417a-9afc-d2aeef1b1f8d
md"""
However one should keep in mind, that macro dispatch is based on the types of AST that are handed to the macro, not the types that the AST evaluates to at runtime:
"""

# ╔═╡ 0d9fb05c-a900-4d87-adfd-1ff2c0138095
macro m(::Int)
     println("An Integer")
 end

# ╔═╡ b66f0390-cf77-4c99-bc01-18369767114e
@m 2

# ╔═╡ 37736dbd-b54a-4f4a-adee-289177b16a40
x = 2

# ╔═╡ bf82c5af-44c1-4e4e-8f71-112ed0d33ead
@m x

# ╔═╡ fad933a9-a92e-4dd9-ba0b-93454a2e6c35
md"""
## Code Generation
"""

# ╔═╡ 4dcd6922-0e9e-47c3-b967-c54ec43e294b
md"""
When a significant amount of repetitive boilerplate code is required, it is common to generate it programmatically to avoid redundancy. In most languages, this requires an extra build step, and a separate program to generate the repetitive code. In Julia, expression interpolation and [`eval`](@ref) allow such code generation to take place in the normal course of program execution. For example, consider the following custom type
"""

# ╔═╡ fb92155a-98b4-4245-9e0a-d36a1a67b6b5
struct MyNumber
    x::Float64
end

# ╔═╡ d18777b3-b477-4194-b9dc-c2e769444776
md"""
for which we want to add a number of methods to. We can do this programmatically in the following loop:
"""

# ╔═╡ a905eca7-1b19-4a2b-a944-07e5820b67c7
for op = (:sin, :cos, :tan, :log, :exp)
    eval(quote
  Base.$op(a::MyNumber) = MyNumber($op(a.x))
    end)
end

# ╔═╡ 1fbb990a-40b7-4b9f-bf2f-ef75e03f9dd0
md"""
and we can now use those functions with our custom type:
"""

# ╔═╡ 7782f382-d8c8-41a3-b73e-ed7cfbc9c884
x = MyNumber(π)

# ╔═╡ f280d06b-66ac-407b-9911-cc9539e96eb0
sin(x)

# ╔═╡ 30e8b5c6-4d36-4134-8b1f-37febfeb39af
cos(x)

# ╔═╡ 3375f5bc-6098-41fc-a0c7-29ce2eea289f
md"""
In this manner, Julia acts as its own [preprocessor](https://en.wikipedia.org/wiki/Preprocessor), and allows code generation from inside the language. The above code could be written slightly more tersely using the `:` prefix quoting form:
"""

# ╔═╡ 78c95206-2805-44dc-87fd-511243b22c7b
md"""
```julia
for op = (:sin, :cos, :tan, :log, :exp)
    eval(:(Base.$op(a::MyNumber) = MyNumber($op(a.x))))
end
```
"""

# ╔═╡ fc581913-770e-4d3b-839c-752396bc21f3
md"""
This sort of in-language code generation, however, using the `eval(quote(...))` pattern, is common enough that Julia comes with a macro to abbreviate this pattern:
"""

# ╔═╡ d2340c5a-3466-4f38-8c78-96e6ec55dfcf
md"""
```julia
for op = (:sin, :cos, :tan, :log, :exp)
    @eval Base.$op(a::MyNumber) = MyNumber($op(a.x))
end
```
"""

# ╔═╡ 38dbb4e3-5496-40b8-aa01-4fe77b879634
md"""
The [`@eval`](@ref) macro rewrites this call to be precisely equivalent to the above longer versions. For longer blocks of generated code, the expression argument given to [`@eval`](@ref) can be a block:
"""

# ╔═╡ 5aca3a9f-d70a-4f71-b09a-8e8e474f2e4c
md"""
```julia
@eval begin
    # multiple lines
end
```
"""

# ╔═╡ ef356125-0832-4834-b45f-59950912367f
md"""
## Non-Standard String Literals
"""

# ╔═╡ aff468e4-bb07-4f42-9560-a3faffd4f807
md"""
Recall from [Strings](@ref non-standard-string-literals) that string literals prefixed by an identifier are called non-standard string literals, and can have different semantics than un-prefixed string literals. For example:
"""

# ╔═╡ e9e7d114-047c-4492-a111-ab7b5ce1f2a2
md"""
  * `r\"^\s*(?:#|$)\"` produces a regular expression object rather than a string
  * `b\"DATA\xff\u2200\"` is a byte array literal for `[68,65,84,65,255,226,136,128]`.
"""

# ╔═╡ d7298da2-2ca3-4c48-93d4-0b7e175c5d8f
md"""
Perhaps surprisingly, these behaviors are not hard-coded into the Julia parser or compiler. Instead, they are custom behaviors provided by a general mechanism that anyone can use: prefixed string literals are parsed as calls to specially-named macros. For example, the regular expression macro is just the following:
"""

# ╔═╡ deb8ca7d-0f33-4884-a66f-0b4b3072137a
md"""
```julia
macro r_str(p)
    Regex(p)
end
```
"""

# ╔═╡ 8bdcdd62-8c39-4ef1-b9e2-21f176f49cc4
md"""
That's all. This macro says that the literal contents of the string literal `r\"^\s*(?:#|$)\"` should be passed to the `@r_str` macro and the result of that expansion should be placed in the syntax tree where the string literal occurs. In other words, the expression `r\"^\s*(?:#|$)\"` is equivalent to placing the following object directly into the syntax tree:
"""

# ╔═╡ d6e7eb38-a2d4-4846-878a-f78cfc2b5004
md"""
```julia
Regex(\"^\\s*(?:#|\$)\")
```
"""

# ╔═╡ 501c6b95-4e46-48d6-bc70-be780c9d2aab
md"""
Not only is the string literal form shorter and far more convenient, but it is also more efficient: since the regular expression is compiled and the `Regex` object is actually created *when the code is compiled*, the compilation occurs only once, rather than every time the code is executed. Consider if the regular expression occurs in a loop:
"""

# ╔═╡ 5693c15b-81d9-4c36-84cd-3ef7f3a8f0eb
md"""
```julia
for line = lines
    m = match(r\"^\s*(?:#|$)\", line)
    if m === nothing
        # non-comment
    else
        # comment
    end
end
```
"""

# ╔═╡ 15c73617-caa2-4b52-a10c-bd0a0e45453d
md"""
Since the regular expression `r\"^\s*(?:#|$)\"` is compiled and inserted into the syntax tree when this code is parsed, the expression is only compiled once instead of each time the loop is executed. In order to accomplish this without macros, one would have to write this loop like this:
"""

# ╔═╡ b15381b7-ac69-43fd-b7ab-c77dc6f866cf
md"""
```julia
re = Regex(\"^\\s*(?:#|\$)\")
for line = lines
    m = match(re, line)
    if m === nothing
        # non-comment
    else
        # comment
    end
end
```
"""

# ╔═╡ 3e031818-f012-4748-bcd9-74a717623375
md"""
Moreover, if the compiler could not determine that the regex object was constant over all loops, certain optimizations might not be possible, making this version still less efficient than the more convenient literal form above. Of course, there are still situations where the non-literal form is more convenient: if one needs to interpolate a variable into the regular expression, one must take this more verbose approach; in cases where the regular expression pattern itself is dynamic, potentially changing upon each loop iteration, a new regular expression object must be constructed on each iteration. In the vast majority of use cases, however, regular expressions are not constructed based on run-time data. In this majority of cases, the ability to write regular expressions as compile-time values is invaluable.
"""

# ╔═╡ fad0230b-41d7-4c1a-855b-6f72690cf1f0
md"""
Like non-standard string literals, non-standard command literals exist using a prefixed variant of the command literal syntax. The command literal ```custom`literal` ``` is parsed as `@custom_cmd \"literal\"`. Julia itself does not contain any non-standard command literals, but packages can make use of this syntax. Aside from the different syntax and the `_cmd` suffix instead of the `_str` suffix, non-standard command literals behave exactly like non-standard string literals.
"""

# ╔═╡ b60b7528-0cd6-477b-a9f1-966c1b819a67
md"""
In the event that two modules provide non-standard string or command literals with the same name, it is possible to qualify the string or command literal with a module name. For instance, if both `Foo` and `Bar` provide non-standard string literal `@x_str`, then one can write `Foo.x\"literal\"` or `Bar.x\"literal\"` to disambiguate between the two.
"""

# ╔═╡ 3acd84f8-5063-442b-8c6d-84d9fa3da551
md"""
The mechanism for user-defined string literals is deeply, profoundly powerful. Not only are Julia's non-standard literals implemented using it, but also the command literal syntax (``` `echo \"Hello, $person\"` ```) is implemented with the following innocuous-looking macro:
"""

# ╔═╡ d52dc4c0-320e-4312-b1c8-9957fbcbe0ec
md"""
```julia
macro cmd(str)
    :(cmd_gen($(shell_parse(str)[1])))
end
```
"""

# ╔═╡ 4d33de66-b849-42f8-adc3-172e3c082e40
md"""
Of course, a large amount of complexity is hidden in the functions used in this macro definition, but they are just functions, written entirely in Julia. You can read their source and see precisely what they do – and all they do is construct expression objects to be inserted into your program's syntax tree.
"""

# ╔═╡ e2d74274-6701-45cf-8fca-726dca6d05ab
md"""
Another way to define a macro would be like this:
"""

# ╔═╡ da981e1e-91e7-4d46-a20c-61a652c38b90
md"""
```julia
macro foo_str(str, flag)
    # do stuff
end
```
"""

# ╔═╡ 64b7d7e0-4ebe-4509-be04-d584610ca55e
md"""
This macro can then be called with the following syntax:
"""

# ╔═╡ 8a03cf63-4fa6-43da-8321-937b33852ad5
md"""
```julia
foo\"str\"flag
```
"""

# ╔═╡ e03fdba1-f58f-48d3-b05f-78097460a707
md"""
The type of flag in the above mentioned syntax would be a `String` with contents of whatever trails after the string literal.
"""

# ╔═╡ 7d2fa4ec-e581-4787-9e55-265982dba199
md"""
## Generated functions
"""

# ╔═╡ e9e6eb0b-e7cc-457f-8608-e9b5fd3ceeb7
md"""
A very special macro is [`@generated`](@ref), which allows you to define so-called *generated functions*. These have the capability to generate specialized code depending on the types of their arguments with more flexibility and/or less code than what can be achieved with multiple dispatch. While macros work with expressions at parse time and cannot access the types of their inputs, a generated function gets expanded at a time when the types of the arguments are known, but the function is not yet compiled.
"""

# ╔═╡ 19a984ab-194f-48a0-aff6-a6b69dab98e3
md"""
Instead of performing some calculation or action, a generated function declaration returns a quoted expression which then forms the body for the method corresponding to the types of the arguments. When a generated function is called, the expression it returns is compiled and then run. To make this efficient, the result is usually cached. And to make this inferable, only a limited subset of the language is usable. Thus, generated functions provide a flexible way to move work from run time to compile time, at the expense of greater restrictions on allowed constructs.
"""

# ╔═╡ e4e8daba-8130-4f21-a707-9ef2e4f1a192
md"""
When defining generated functions, there are five main differences to ordinary functions:
"""

# ╔═╡ f6de1aea-5714-4ca3-b478-cb5eee5054b1
md"""
1. You annotate the function declaration with the `@generated` macro. This adds some information to the AST that lets the compiler know that this is a generated function.
2. In the body of the generated function you only have access to the *types* of the arguments – not their values.
3. Instead of calculating something or performing some action, you return a *quoted expression* which, when evaluated, does what you want.
4. Generated functions are only permitted to call functions that were defined *before* the definition of the generated function. (Failure to follow this may result in getting `MethodErrors` referring to functions from a future world-age.)
5. Generated functions must not *mutate* or *observe* any non-constant global state (including, for example, IO, locks, non-local dictionaries, or using [`hasmethod`](@ref)). This means they can only read global constants, and cannot have any side effects. In other words, they must be completely pure. Due to an implementation limitation, this also means that they currently cannot define a closure or generator.
"""

# ╔═╡ 16ac01e2-6beb-4e0e-9773-2fa302043dc3
md"""
It's easiest to illustrate this with an example. We can declare a generated function `foo` as
"""

# ╔═╡ b2ec8dfd-041b-4a57-bcfe-0906c019b353
@generated function foo(x)
     Core.println(x)
     return :(x * x)
 end

# ╔═╡ 242e2d58-eafb-43a3-bf8b-ed3f26691fd3
md"""
Note that the body returns a quoted expression, namely `:(x * x)`, rather than just the value of `x * x`.
"""

# ╔═╡ 8922b5b5-70d0-42c4-8034-5dbb5ef2dd20
md"""
From the caller's perspective, this is identical to a regular function; in fact, you don't have to know whether you're calling a regular or generated function. Let's see how `foo` behaves:
"""

# ╔═╡ 41fb6483-a8a7-419c-abea-980d87f8ed5d
x = foo(2); # note: output is from println() statement in the body

# ╔═╡ b2654112-85e1-405b-8420-60180adf4b35
x           # now we print x

# ╔═╡ 34c1984f-aa9c-4258-9e99-7e8b41498c31
y = foo("bar");

# ╔═╡ 84b13f6d-2b85-4589-ab82-29a7ecb08a00
y

# ╔═╡ 7914eb3d-060c-495a-ba47-e7204b3a7373
md"""
So, we see that in the body of the generated function, `x` is the *type* of the passed argument, and the value returned by the generated function, is the result of evaluating the quoted expression we returned from the definition, now with the *value* of `x`.
"""

# ╔═╡ a1f74101-99e5-48ce-be90-f1b545f5868d
md"""
What happens if we evaluate `foo` again with a type that we have already used?
"""

# ╔═╡ 3a415fce-84c3-4efa-bdaa-aa0c2782d1a7
foo(4)

# ╔═╡ 3d9585f3-3996-4e7d-a4ca-7ba635743347
md"""
Note that there is no printout of [`Int64`](@ref). We can see that the body of the generated function was only executed once here, for the specific set of argument types, and the result was cached. After that, for this example, the expression returned from the generated function on the first invocation was re-used as the method body. However, the actual caching behavior is an implementation-defined performance optimization, so it is invalid to depend too closely on this behavior.
"""

# ╔═╡ 9012e6b7-d2c1-44e7-bc78-23d535b6a18a
md"""
The number of times a generated function is generated *might* be only once, but it *might* also be more often, or appear to not happen at all. As a consequence, you should *never* write a generated function with side effects - when, and how often, the side effects occur is undefined. (This is true for macros too - and just like for macros, the use of [`eval`](@ref) in a generated function is a sign that you're doing something the wrong way.) However, unlike macros, the runtime system cannot correctly handle a call to [`eval`](@ref), so it is disallowed.
"""

# ╔═╡ 838e8e45-8fb4-485b-8d11-73310a1314d2
md"""
It is also important to see how `@generated` functions interact with method redefinition. Following the principle that a correct `@generated` function must not observe any mutable state or cause any mutation of global state, we see the following behavior. Observe that the generated function *cannot* call any method that was not defined prior to the *definition* of the generated function itself.
"""

# ╔═╡ 933605ca-5578-475a-9169-3bebb045e51c
md"""
Initially `f(x)` has one definition
"""

# ╔═╡ bd0504fa-bcb2-46c0-85ca-3621fe1d9830
f(x) = "original definition";

# ╔═╡ 806fb8ea-3fd8-4027-a186-57c7e0743c82
md"""
Define other operations that use `f(x)`:
"""

# ╔═╡ 210cc6be-378c-4dfb-88a7-1765a7a14851
g(x) = f(x);

# ╔═╡ ad530ede-8977-4f58-890c-8030f960bc32
@generated gen1(x) = f(x);

# ╔═╡ 439ab82d-58e1-403e-8970-5839552cd8b2
@generated gen2(x) = :(f(x));

# ╔═╡ a83906a7-14ca-43e2-b834-a8ec2b98a5dd
md"""
We now add some new definitions for `f(x)`:
"""

# ╔═╡ 4c4316da-6f1a-4b25-96ee-f6e9dc3abac0
f(x::Int) = "definition for Int";

# ╔═╡ 5b7b3927-4835-440a-9e3d-584e743f4f54
f(x::Type{Int}) = "definition for Type{Int}";

# ╔═╡ c738db8f-c24f-4d13-b000-3117feae379b
md"""
and compare how these results differ:
"""

# ╔═╡ 77f7e7b3-796a-4beb-a914-e6633e56a7dd
f(1)

# ╔═╡ be9c7a89-1e8c-4727-9589-ab0b6af16afd
g(1)

# ╔═╡ 4f314c1b-b440-4f32-babc-4682c89923ce
gen1(1)

# ╔═╡ 9274d996-a232-4260-b99a-59ce173b63dd
gen2(1)

# ╔═╡ c23e0eb2-4161-4644-bc61-3c6a219d02ed
md"""
Each method of a generated function has its own view of defined functions:
"""

# ╔═╡ 60ba4628-3485-44a7-aa8d-67d1e8a17f8a
@generated gen1(x::Real) = f(x);

# ╔═╡ b237b619-f911-4320-baeb-652e1406dbca
gen1(1)

# ╔═╡ 742b5b59-2c44-41d8-95d7-79e530c65721
md"""
The example generated function `foo` above did not do anything a normal function `foo(x) = x * x` could not do (except printing the type on the first invocation, and incurring higher overhead). However, the power of a generated function lies in its ability to compute different quoted expressions depending on the types passed to it:
"""

# ╔═╡ 7671f642-4a26-4a46-9c8b-6b2817477dee
@generated function bar(x)
     if x <: Integer
         return :(x ^ 2)
     else
         return :(x)
     end
 end

# ╔═╡ a99a377c-ad48-47e7-bdff-3b8c0207170c
bar(4)

# ╔═╡ 23bebd84-e366-4f2e-a99a-968d30b1f490
bar("baz")

# ╔═╡ 37276c83-dfb9-4002-9ca3-a417c219ca11
md"""
(although of course this contrived example would be more easily implemented using multiple dispatch...)
"""

# ╔═╡ 98c1e77c-c7e8-49a5-b4dc-3e19eea29093
md"""
Abusing this will corrupt the runtime system and cause undefined behavior:
"""

# ╔═╡ db663f82-e093-438f-bbcd-5cebc2a0548d
@generated function baz(x)
     if rand() < .9
         return :(x^2)
     else
         return :("boo!")
     end
 end

# ╔═╡ 6e5143ee-076e-49c4-845e-14b458287a8e
md"""
Since the body of the generated function is non-deterministic, its behavior, *and the behavior of all subsequent code* is undefined.
"""

# ╔═╡ 63990f70-c15f-4bc2-9e5a-097fd5b5716f
md"""
*Don't copy these examples!*
"""

# ╔═╡ ba3c037c-450b-4077-855c-1a640f78adb2
md"""
These examples are hopefully helpful to illustrate how generated functions work, both in the definition end and at the call site; however, *don't copy them*, for the following reasons:
"""

# ╔═╡ 16e28d47-1ef9-4dc6-a065-e3c0a743b977
md"""
  * the `foo` function has side-effects (the call to `Core.println`), and it is undefined exactly when, how often or how many times these side-effects will occur
  * the `bar` function solves a problem that is better solved with multiple dispatch - defining `bar(x) = x` and `bar(x::Integer) = x ^ 2` will do the same thing, but it is both simpler and faster.
  * the `baz` function is pathological
"""

# ╔═╡ 354ffe45-cff7-4f73-9b55-78eca85bb41e
md"""
Note that the set of operations that should not be attempted in a generated function is unbounded, and the runtime system can currently only detect a subset of the invalid operations. There are many other operations that will simply corrupt the runtime system without notification, usually in subtle ways not obviously connected to the bad definition. Because the function generator is run during inference, it must respect all of the limitations of that code.
"""

# ╔═╡ a66c9cd1-664c-46d1-a0c2-c1a10f519a37
md"""
Some operations that should not be attempted include:
"""

# ╔═╡ 4b42461c-b12c-41e0-8081-b7daf9c3c3b2
md"""
1. Caching of native pointers.
2. Interacting with the contents or methods of `Core.Compiler` in any way.
3. Observing any mutable state.

      * Inference on the generated function may be run at *any* time, including while your code is attempting to observe or mutate this state.
4. Taking any locks: C code you call out to may use locks internally, (for example, it is not problematic to call `malloc`, even though most implementations require locks internally) but don't attempt to hold or acquire any while executing Julia code.
5. Calling any function that is defined after the body of the generated function. This condition is relaxed for incrementally-loaded precompiled modules to allow calling any function in the module.
"""

# ╔═╡ f57ef7f0-9445-4faf-863c-d94b13376af1
md"""
Alright, now that we have a better understanding of how generated functions work, let's use them to build some more advanced (and valid) functionality...
"""

# ╔═╡ 80c28ca8-b2d8-4ff8-b986-86f0e2e787dc
md"""
### An advanced example
"""

# ╔═╡ e9f91650-e273-43c1-b2d5-286c4b2525d9
md"""
Julia's base library has an internal `sub2ind` function to calculate a linear index into an n-dimensional array, based on a set of n multilinear indices - in other words, to calculate the index `i` that can be used to index into an array `A` using `A[i]`, instead of `A[x,y,z,...]`. One possible implementation is the following:
"""

# ╔═╡ 02f6bb46-bf93-49db-969d-50a5af73c457
function sub2ind_loop(dims::NTuple{N}, I::Integer...) where N
     ind = I[N] - 1
     for i = N-1:-1:1
         ind = I[i]-1 + dims[i]*ind
     end
     return ind + 1
 end

# ╔═╡ 6f085ece-1eb4-47a5-90a0-4d80324d2ff9
sub2ind_loop((3, 5), 1, 2)

# ╔═╡ e045ff5a-a8cf-4cde-bbb5-0c9464a37e4b
md"""
The same thing can be done using recursion:
"""

# ╔═╡ ce38fa53-bad6-47d0-9886-a34313efaef2
sub2ind_rec(dims::Tuple{}) = 1;

# ╔═╡ 28aed164-1400-4dd6-b099-5ac4e8572933
sub2ind_rec(dims::Tuple{}, i1::Integer, I::Integer...) =
     i1 == 1 ? sub2ind_rec(dims, I...) : throw(BoundsError());

# ╔═╡ 408352ef-8851-4b93-8b2d-404c9946ad49
sub2ind_rec(dims::Tuple{Integer, Vararg{Integer}}, i1::Integer) = i1;

# ╔═╡ 353360c4-941a-42f1-8b3a-8521033be9b3
sub2ind_rec(dims::Tuple{Integer, Vararg{Integer}}, i1::Integer, I::Integer...) =
     i1 + dims[1] * (sub2ind_rec(Base.tail(dims), I...) - 1);

# ╔═╡ 226d50ce-e797-45f4-8b67-17c3b717ded2
sub2ind_rec((3, 5), 1, 2)

# ╔═╡ 5abc77ec-21f2-408b-963b-8d99c61566c8
md"""
Both these implementations, although different, do essentially the same thing: a runtime loop over the dimensions of the array, collecting the offset in each dimension into the final index.
"""

# ╔═╡ 1b7bc694-dbb6-4d81-91a0-b8f858f399cb
md"""
However, all the information we need for the loop is embedded in the type information of the arguments. Thus, we can utilize generated functions to move the iteration to compile-time; in compiler parlance, we use generated functions to manually unroll the loop. The body becomes almost identical, but instead of calculating the linear index, we build up an *expression* that calculates the index:
"""

# ╔═╡ 10574023-f668-424a-8e62-450a2a333e0a
@generated function sub2ind_gen(dims::NTuple{N}, I::Integer...) where N
     ex = :(I[$N] - 1)
     for i = (N - 1):-1:1
         ex = :(I[$i] - 1 + dims[$i] * $ex)
     end
     return :($ex + 1)
 end

# ╔═╡ 0bc77d7b-8e7f-4270-876b-09e6ee331829
sub2ind_gen((3, 5), 1, 2)

# ╔═╡ 03f3e1ef-c878-47cf-8167-7d192076bc98
md"""
**What code will this generate?**
"""

# ╔═╡ 809c0aae-d8e3-4b9c-a0a7-2ebc97723808
md"""
An easy way to find out is to extract the body into another (regular) function:
"""

# ╔═╡ 752f1e07-b45f-4be9-802d-c8c26a42ea4b
@generated function sub2ind_gen(dims::NTuple{N}, I::Integer...) where N
     return sub2ind_gen_impl(dims, I...)
 end

# ╔═╡ 9cfe79cd-4754-4f86-a616-53a38e084d26
function sub2ind_gen_impl(dims::Type{T}, I...) where T <: NTuple{N,Any} where N
     length(I) == N || return :(error("partial indexing is unsupported"))
     ex = :(I[$N] - 1)
     for i = (N - 1):-1:1
         ex = :(I[$i] - 1 + dims[$i] * $ex)
     end
     return :($ex + 1)
 end

# ╔═╡ 0820e03a-6840-46e8-a082-d592fb1b0037
md"""
We can now execute `sub2ind_gen_impl` and examine the expression it returns:
"""

# ╔═╡ d93b1e4c-414a-460d-8f8b-9b12b54a5de8
sub2ind_gen_impl(Tuple{Int,Int}, Int, Int)

# ╔═╡ 62aa2363-a8df-4615-9787-e2ecba4097be
md"""
So, the method body that will be used here doesn't include a loop at all - just indexing into the two tuples, multiplication and addition/subtraction. All the looping is performed compile-time, and we avoid looping during execution entirely. Thus, we only loop *once per type*, in this case once per `N` (except in edge cases where the function is generated more than once - see disclaimer above).
"""

# ╔═╡ 18ab1044-01a6-4c5a-baec-2cf83cae7563
md"""
### Optionally-generated functions
"""

# ╔═╡ e77fb294-a7e1-48f4-977a-a58f86d758ef
md"""
Generated functions can achieve high efficiency at run time, but come with a compile time cost: a new function body must be generated for every combination of concrete argument types. Typically, Julia is able to compile \"generic\" versions of functions that will work for any arguments, but with generated functions this is impossible. This means that programs making heavy use of generated functions might be impossible to statically compile.
"""

# ╔═╡ f293b8c6-8876-4889-afb6-5c87c09612ae
md"""
To solve this problem, the language provides syntax for writing normal, non-generated alternative implementations of generated functions. Applied to the `sub2ind` example above, it would look like this:
"""

# ╔═╡ 6544c7fb-4ca5-451f-bcf2-4b99ef3ae587
md"""
```julia
function sub2ind_gen(dims::NTuple{N}, I::Integer...) where N
    if N != length(I)
        throw(ArgumentError(\"Number of dimensions must match number of indices.\"))
    end
    if @generated
        ex = :(I[$N] - 1)
        for i = (N - 1):-1:1
            ex = :(I[$i] - 1 + dims[$i] * $ex)
        end
        return :($ex + 1)
    else
        ind = I[N] - 1
        for i = (N - 1):-1:1
            ind = I[i] - 1 + dims[i]*ind
        end
        return ind + 1
    end
end
```
"""

# ╔═╡ e140027f-3121-4527-949b-cebad95a19e5
md"""
Internally, this code creates two implementations of the function: a generated one where the first block in `if @generated` is used, and a normal one where the `else` block is used. Inside the `then` part of the `if @generated` block, code has the same semantics as other generated functions: argument names refer to types, and the code should return an expression. Multiple `if @generated` blocks may occur, in which case the generated implementation uses all of the `then` blocks and the alternate implementation uses all of the `else` blocks.
"""

# ╔═╡ 045a2a80-9398-4af0-ab31-a4bf574af334
md"""
Notice that we added an error check to the top of the function. This code will be common to both versions, and is run-time code in both versions (it will be quoted and returned as an expression from the generated version). That means that the values and types of local variables are not available at code generation time –- the code-generation code can only see the types of arguments.
"""

# ╔═╡ 9eca1b24-e770-46d5-9ede-2bd74e4f1879
md"""
In this style of definition, the code generation feature is essentially an optional optimization. The compiler will use it if convenient, but otherwise may choose to use the normal implementation instead. This style is preferred, since it allows the compiler to make more decisions and compile programs in more ways, and since normal code is more readable than code-generating code. However, which implementation is used depends on compiler implementation details, so it is essential for the two implementations to behave identically.
"""

# ╔═╡ Cell order:
# ╟─4a329a4e-1fe3-431d-98ec-8161764a3ee1
# ╟─fcf7fb90-a229-4a34-af4d-e1da308a1e78
# ╟─7e910758-9b9d-4eb0-a161-f1b7eac39129
# ╟─0167e817-d8d3-4c51-87fe-9bf0619dcff2
# ╠═36097fc2-d38d-4a6f-9c59-5942f2758803
# ╟─11d110f1-7629-4af9-b3d9-703dcd1b387d
# ╟─96b8f192-6774-4dde-87a2-64a81f8dbf1f
# ╠═8fcfafa3-f229-44c9-a431-2214b02726d0
# ╠═7859f9f6-1443-46db-9657-9f1615e279d6
# ╟─15a2df63-e2ff-46df-9369-baad4e4dc748
# ╟─54613218-df4b-4419-a139-cbfc03600cee
# ╠═36ef56a5-6220-4626-92d5-bee76a2328f7
# ╟─55904141-a6a2-4cb4-b062-73783a1f5cbf
# ╠═4e1a9122-0c7f-4f28-93f5-656daf84ecf7
# ╟─e7318bff-ae20-4ddc-b0d9-2ad950123f1a
# ╠═33ee25b5-147f-40ec-a245-10752bdf73d5
# ╟─6187fc22-7e83-4b7d-876f-e1b18f597a56
# ╠═f3db3506-1417-4d5c-9d3c-550ce11b12a2
# ╟─d5505c6f-8897-467b-aec3-ac106f7d2a81
# ╟─da20398b-0959-4024-be1a-cd336f6fd596
# ╠═208960e1-6204-4df6-93e3-5586c8111e54
# ╟─0f99abc3-4700-4846-8128-572e88c1c426
# ╠═1c3802e8-d7e9-4454-9729-dd108c1fdf8f
# ╟─620275f6-5e71-4a48-8df8-cc8e6e3d91e9
# ╠═fefeb34f-3d1e-4b18-bb37-26f7a08de741
# ╟─5a251167-1ca2-4311-800c-8a65fd8bce27
# ╟─c3875772-7266-475c-82f0-f574df3e00f9
# ╠═53c5a159-79ad-4fbb-be77-28d9f5ce355a
# ╠═0ed50b34-bf20-4cae-abbf-a23bb2a6b3e1
# ╟─77270b5d-db24-4034-9acb-df32bfc0046e
# ╠═b8e25ef0-31e4-45ca-8641-94a722dcd04c
# ╠═37039812-4c1a-4a83-b226-de3e3bb46708
# ╠═55b7d0c1-2313-4aab-a91d-3f8df3aad0f8
# ╟─d69d7939-28af-4d27-8160-5ce95352d0f5
# ╟─80d66efe-4dfd-4b2b-9c8f-086d89c0f57c
# ╟─3ad47a4e-c1a0-40f6-b060-6e81ba4b5fce
# ╠═0d2d15b7-a8db-409c-b583-55ad3b31f7b7
# ╠═89162a72-fc8a-4ae8-b879-92257bfab63f
# ╟─bb530cb9-1ca7-4c97-8d16-18390d77ceb9
# ╟─bd81c653-8361-40b8-9ce7-5996a124fe67
# ╟─7aee02ac-e84f-4e07-9fd6-29864de59dfd
# ╠═1018af97-73a3-4e9e-9e7e-a2249a37abb9
# ╠═e8db5d80-7350-40e3-812d-42fa5293abb0
# ╟─ceeea500-f6c8-4743-9d22-9b72c7da7ed7
# ╟─37827ba6-65ab-4dd9-82f5-310cb30a0712
# ╠═5a6edb10-f59a-4874-8eaa-a52eb8991771
# ╟─52404149-600f-48f8-9e8d-5e8c9b0b0a04
# ╟─3fcb66c2-4e66-4f45-a7e7-65036efca00a
# ╠═d958acef-73fe-4109-9967-24e5f4ca569f
# ╠═ba42645b-fb45-4221-8d40-9840cb02264c
# ╟─2128a38f-7b95-449c-b561-06268ddc755b
# ╟─03d378b5-4419-41e2-91e9-cd0ba96e3f0c
# ╟─44e77b14-6cab-46fb-adb7-67e75dc0857b
# ╠═63ff3614-7d0f-4c5e-9bb5-49170e5aa724
# ╠═4d55b495-251d-4306-a7de-96517a0f27db
# ╟─38ceea8c-8c47-40eb-93bd-f1b4d2fb1dd7
# ╠═d9435823-a23b-4a48-9b20-a8a60cbd5642
# ╟─452953e8-0b5e-4ec1-b186-920c3c3a6a92
# ╠═4252a8c4-fbc1-478e-9853-bd14ae34028b
# ╟─ade9fd13-8cae-4fa4-9177-4d4f95e648fa
# ╟─a3abc7e4-82dc-44f9-a36d-2bb887485366
# ╟─43cc1bf6-bb71-4283-bcac-9f1e5beb6320
# ╠═ee9cdf5f-fbe3-4739-9a0f-0807a71832e1
# ╠═8c80e767-c31e-4b90-a796-3bd172807b99
# ╟─e9060435-8f4d-4d3b-a712-6d4c996ed5a5
# ╟─159f3cb2-3db5-4353-a856-653feacb5e92
# ╠═b9ad3232-5587-4a03-89cf-98538cf6768e
# ╠═42e7f30a-da9e-431a-8f3d-6a86c37a42a8
# ╟─f3eee563-1bca-49e9-892a-02f0f7f383fb
# ╠═c4955aff-fe45-4f25-ba4a-76cf37cbf313
# ╟─8f3c873c-ea0a-476b-b976-c4952d0862c4
# ╠═ccf86fe2-36fb-4cc4-9896-f57908929057
# ╟─f1f4f452-3a8b-460d-90c4-a8051081baa5
# ╠═9eb4d9b8-8d0e-45aa-918f-a4c15f0fc7dd
# ╟─6eb1be2c-1380-40c4-9ad4-97df4bd0c00e
# ╟─e2fc1d1c-8926-4d6d-b98c-272513971354
# ╟─be25c407-2da0-4a73-8d61-f397809c6a0d
# ╠═555a7c0a-19b9-4fa5-bfed-18e87b944a08
# ╟─613595ed-d306-4c9b-a02c-002d8adbfc7c
# ╠═f7e81888-47e6-46fc-8328-1fb859e60541
# ╠═86cf0594-0cb9-4385-9eac-931ef2ec7230
# ╟─ee702c43-2fb0-4772-858d-cf8c914a82bf
# ╠═56964666-aaa8-4e5b-9032-27899e9e9021
# ╟─92b11cbe-9bd5-4ffa-b847-1e49bc399c64
# ╟─bdd51c19-3ac2-42ee-bce2-cc63d25c45f1
# ╟─8c70bcc3-1f62-43c2-875a-10e0349f6ff7
# ╠═1bc594e5-f04a-41de-8ae0-83d5e0a0b1c9
# ╠═e21a813e-1f35-4e61-9d24-dfe075e20bfa
# ╠═6537044b-c279-4e5b-8b8d-aeece11678de
# ╠═0a5e1a3e-9613-4972-b8e5-eebd16fc2538
# ╠═633972c2-e96d-482e-8a36-55b090d6f31e
# ╠═094811c3-f379-482c-8e2b-2e31d2b2dae6
# ╟─1810881a-502d-44d0-9f25-e179b0a3fdc3
# ╠═b4d7164c-5ebc-4e03-8750-d4303d5040fc
# ╠═9174d44b-3cb8-481d-8625-89a34974fc5b
# ╠═4f685b00-8535-462a-b017-342a94f38c37
# ╠═408fbb67-959f-4a68-a8b3-1630f41d24d1
# ╟─ac140b00-a8c3-4e81-8d83-b65155d1f8a0
# ╟─5511e05a-be65-4295-b1ff-b1204bbf6e8a
# ╠═af23182f-10e9-4dfb-ac33-6e161a2f4889
# ╠═48f159ac-073c-4b4e-bdac-f6d65d24ef6d
# ╠═d4f5c5d2-b6af-4d6c-b1c1-729580dbb94f
# ╠═590c8581-b7d5-4cb4-acda-b1ceafbd113b
# ╟─7655bf82-840f-48e0-a0ba-fc2063bc2307
# ╟─0a5469c9-ccef-4b62-9f0f-d3552fb3b986
# ╟─91b8a80e-5f65-4387-acf2-5fb87692789d
# ╟─9ee35586-1af3-43ab-b1ba-5b3bb67ebb34
# ╠═5e0c39cc-b506-45de-897e-afd46895836d
# ╠═8b221b0f-36b2-4ac5-9957-68b2168ba517
# ╠═f8cefa6a-eece-4aca-930f-455eb7fe1914
# ╟─5e3b7f2c-e329-4273-9a03-6d8a73608111
# ╠═3e01b90a-d9eb-4b71-809b-0dc9be003933
# ╠═73f1405c-a7c0-498a-a038-dadec51ecd27
# ╠═4ded730f-d9bf-4c02-8631-c7c51afe9a87
# ╠═c3e1d72f-f4a9-49a8-9463-f339cb0b7b2c
# ╟─64f2099f-1105-44a7-81a6-a994a9a04d42
# ╟─f048bbf0-6d7a-4a59-9399-d54097ccf829
# ╟─3ce27869-3376-43d9-b7f2-8f7fec825e2e
# ╟─ecf455bc-76fe-4cbe-b953-67371e614292
# ╠═75c33720-2ad3-4b7f-a793-a9c2d92a984a
# ╟─e22c2662-6933-4715-98cd-6d7c4db46a0c
# ╟─ed26c3c1-a93f-4f69-b654-2b419503d422
# ╟─3513f124-bec4-48fc-bf89-f9dafe70f9f4
# ╠═71415783-382f-4f44-88b5-61d4d60faa30
# ╟─0963a1f3-aac8-40e6-93d5-6fd6e8ba0730
# ╠═3047d86a-1a72-414d-a07e-da6bd9201be9
# ╟─b46ab3b3-8046-4e89-af4a-50f0b312c9b7
# ╠═f77e4f70-c123-4c6e-b796-9c04bddf1109
# ╟─fee9f20b-9215-4d74-b8d1-dda548e424d6
# ╠═14921103-4720-44b9-bd67-c390278cc0e4
# ╠═0c866a9a-e612-4730-b528-9d506ea19fe7
# ╟─63471543-034d-4f19-811b-32d64d4fd115
# ╟─fb4452b8-c16a-4bbf-a6dc-c142c11998cf
# ╠═bc63e678-3b03-4330-bb5c-b00fd610bd46
# ╟─294ac76a-e11c-43f8-b9b9-1fc5b9a36871
# ╟─cd2366f7-6528-4ae6-83cb-dc82b89287b1
# ╟─f978c9c7-ec5b-4162-92b4-95b16efed6ad
# ╠═c7a9233d-374a-4981-8e43-166d8a3ff042
# ╠═f72565d4-8f25-4cb4-9f7f-19dff4cf78da
# ╟─30004803-2216-4b8d-9267-1d3dbd7ab072
# ╠═2d4bfe38-5121-4128-a0e0-165f16cacd70
# ╠═6e65d136-ad27-4db6-abf3-f8e6bfc7b83c
# ╠═d650ea8f-589b-4cf3-9c55-d4f24a6b9a3d
# ╟─95e0e154-7479-4216-952f-55c33200ab17
# ╟─364f58d3-706b-4a99-83a7-d72d2c2acc1b
# ╟─b90e2c60-561a-4afd-a41f-c0b0b87ca60c
# ╟─589dbb6d-bfa0-449f-8bfe-da83ebaa6f6e
# ╟─cc8f4ed9-7dac-45d2-8d59-4171939c9915
# ╟─4be03b12-208b-4034-9056-3100b69486d1
# ╟─1c556d0a-5525-4e2c-80f2-0207af774553
# ╟─309a286b-78d9-4ff0-859c-a6a6f0abf34b
# ╠═336da33b-aa63-4bae-a82a-f847fa40b9b0
# ╠═560f7df8-821d-43cc-8077-ab98b0779296
# ╠═8953fe37-0e8b-4d00-816e-a1050acc8635
# ╠═a64d78c8-8728-4fbe-9bb6-311bde057a43
# ╟─58a065aa-b40e-46e9-be19-733bdad3837b
# ╟─9aba8e4a-3f76-45ed-add5-e0f5f6fc5485
# ╟─884121d0-9980-40bc-bcb3-c941ca75f206
# ╠═a66a975e-1af7-4403-b9ce-c88ba9695a86
# ╠═df7198a4-b334-44c5-9396-ca0dc79f2395
# ╟─2211b1cc-d9dd-4bd5-bf55-0dcdab169317
# ╟─1a620020-ab6d-4454-bc60-fa727d2be594
# ╟─9057076e-ab4f-46d2-9f50-9b56f86f9445
# ╠═214b0788-a678-482a-b9e1-ba388ee41207
# ╟─91bc0ab4-44ca-4bb6-8543-4dcd0eb042ed
# ╠═3fb1e2a0-393b-4051-8fc1-caf74e997ca2
# ╠═38f53163-88f0-4532-b6c0-cda08ed9f551
# ╟─cb20682c-1d0c-4d88-b5e8-6792ec54bbd9
# ╟─bb43e482-196c-4864-a0ff-40e767914429
# ╟─1c4f7db3-c88a-4bde-a418-5bfdc7809409
# ╟─e8777260-736f-4006-a3ed-23e2b61b52de
# ╠═c0e000b2-f297-47c3-9ad5-5570494a6204
# ╟─ff48656f-4367-49ca-bea6-65d5113fd0cc
# ╠═5f71e871-d6d7-4de5-94f4-226d83741df7
# ╠═b6db6abb-0c47-4c36-b533-fb23b51cad5c
# ╟─5b78bbfc-41f2-4073-8903-e538da17d0e0
# ╠═51429238-d677-471f-b73b-fde1828ed060
# ╠═f0191618-680f-47c0-b6fa-6e4a6edf3f2f
# ╠═2d5f5dbc-10a6-4f37-96bb-af98cfeadc42
# ╟─c46af693-c9fc-405f-8b05-70b395f5b8b2
# ╟─72c5f262-09ed-4865-acc0-7819b3e439bd
# ╟─b02f2238-11bd-4e82-a8d8-e3ba2218dffb
# ╟─f2568ed4-a219-4d42-be7d-cae074280740
# ╟─a4697205-d518-4704-a6f0-26d3152da54a
# ╟─0ebea417-c177-4636-9d09-5315487a908d
# ╟─495471b9-722d-420b-b2f6-2bebb570637e
# ╟─5410304a-635a-4a46-97b3-3f186e548212
# ╟─59e0100b-34cb-4169-b56e-72b405b47254
# ╟─ef62fc92-8fc8-4979-a224-d0681fb4c4cb
# ╟─5242bb32-5da5-4bc7-a2f7-a742bcd8dba1
# ╟─fe083f76-0186-483c-88fb-8cf452c9c572
# ╟─315e2bcf-b794-4f34-b158-9b03d3560907
# ╟─30f8abfb-b8f5-4e3a-95e9-493254f393e1
# ╠═a35e724c-990f-4285-803d-8b0f9416c210
# ╠═bc43c33b-c8c5-4c87-830d-f399e3045829
# ╠═9e5a5f02-740e-489e-87d0-f36ac029e73a
# ╟─227d08c8-0058-4da3-a590-5092da62c776
# ╟─c4c18d92-a287-4824-99ba-df08bf1f726e
# ╟─22d6de99-7df5-4c8f-b7e0-52d469f94c83
# ╟─124b5200-4a27-45b7-bd16-10ed18deab49
# ╟─a016c4cb-3c51-4b13-a303-a399c7b9a72e
# ╟─1c72d267-1d88-4133-896a-9ff51a3b4a04
# ╟─cc237a28-d512-4cca-b529-45771cc5b4de
# ╠═71771d99-ad11-4ea5-93f6-4f0254548d61
# ╠═de94ec4d-04c9-4568-9ce4-ab938cdb1ac1
# ╠═ebf78bef-6d08-4d95-8cd8-35352698d2b4
# ╠═3ebe7ef8-b9e8-48cf-99c9-d4437299d28f
# ╠═ddd41fa7-5f8a-4ed6-bef9-39c2ed9943d0
# ╟─86facd67-9b0a-417a-9afc-d2aeef1b1f8d
# ╠═0d9fb05c-a900-4d87-adfd-1ff2c0138095
# ╠═b66f0390-cf77-4c99-bc01-18369767114e
# ╠═37736dbd-b54a-4f4a-adee-289177b16a40
# ╠═bf82c5af-44c1-4e4e-8f71-112ed0d33ead
# ╟─fad933a9-a92e-4dd9-ba0b-93454a2e6c35
# ╟─4dcd6922-0e9e-47c3-b967-c54ec43e294b
# ╠═fb92155a-98b4-4245-9e0a-d36a1a67b6b5
# ╟─d18777b3-b477-4194-b9dc-c2e769444776
# ╠═a905eca7-1b19-4a2b-a944-07e5820b67c7
# ╟─1fbb990a-40b7-4b9f-bf2f-ef75e03f9dd0
# ╠═7782f382-d8c8-41a3-b73e-ed7cfbc9c884
# ╠═f280d06b-66ac-407b-9911-cc9539e96eb0
# ╠═30e8b5c6-4d36-4134-8b1f-37febfeb39af
# ╟─3375f5bc-6098-41fc-a0c7-29ce2eea289f
# ╟─78c95206-2805-44dc-87fd-511243b22c7b
# ╟─fc581913-770e-4d3b-839c-752396bc21f3
# ╟─d2340c5a-3466-4f38-8c78-96e6ec55dfcf
# ╟─38dbb4e3-5496-40b8-aa01-4fe77b879634
# ╟─5aca3a9f-d70a-4f71-b09a-8e8e474f2e4c
# ╟─ef356125-0832-4834-b45f-59950912367f
# ╟─aff468e4-bb07-4f42-9560-a3faffd4f807
# ╟─e9e7d114-047c-4492-a111-ab7b5ce1f2a2
# ╟─d7298da2-2ca3-4c48-93d4-0b7e175c5d8f
# ╟─deb8ca7d-0f33-4884-a66f-0b4b3072137a
# ╟─8bdcdd62-8c39-4ef1-b9e2-21f176f49cc4
# ╟─d6e7eb38-a2d4-4846-878a-f78cfc2b5004
# ╟─501c6b95-4e46-48d6-bc70-be780c9d2aab
# ╟─5693c15b-81d9-4c36-84cd-3ef7f3a8f0eb
# ╟─15c73617-caa2-4b52-a10c-bd0a0e45453d
# ╟─b15381b7-ac69-43fd-b7ab-c77dc6f866cf
# ╟─3e031818-f012-4748-bcd9-74a717623375
# ╟─fad0230b-41d7-4c1a-855b-6f72690cf1f0
# ╟─b60b7528-0cd6-477b-a9f1-966c1b819a67
# ╟─3acd84f8-5063-442b-8c6d-84d9fa3da551
# ╟─d52dc4c0-320e-4312-b1c8-9957fbcbe0ec
# ╟─4d33de66-b849-42f8-adc3-172e3c082e40
# ╟─e2d74274-6701-45cf-8fca-726dca6d05ab
# ╟─da981e1e-91e7-4d46-a20c-61a652c38b90
# ╟─64b7d7e0-4ebe-4509-be04-d584610ca55e
# ╟─8a03cf63-4fa6-43da-8321-937b33852ad5
# ╟─e03fdba1-f58f-48d3-b05f-78097460a707
# ╟─7d2fa4ec-e581-4787-9e55-265982dba199
# ╟─e9e6eb0b-e7cc-457f-8608-e9b5fd3ceeb7
# ╟─19a984ab-194f-48a0-aff6-a6b69dab98e3
# ╟─e4e8daba-8130-4f21-a707-9ef2e4f1a192
# ╟─f6de1aea-5714-4ca3-b478-cb5eee5054b1
# ╟─16ac01e2-6beb-4e0e-9773-2fa302043dc3
# ╠═b2ec8dfd-041b-4a57-bcfe-0906c019b353
# ╟─242e2d58-eafb-43a3-bf8b-ed3f26691fd3
# ╟─8922b5b5-70d0-42c4-8034-5dbb5ef2dd20
# ╠═41fb6483-a8a7-419c-abea-980d87f8ed5d
# ╠═b2654112-85e1-405b-8420-60180adf4b35
# ╠═34c1984f-aa9c-4258-9e99-7e8b41498c31
# ╠═84b13f6d-2b85-4589-ab82-29a7ecb08a00
# ╟─7914eb3d-060c-495a-ba47-e7204b3a7373
# ╟─a1f74101-99e5-48ce-be90-f1b545f5868d
# ╠═3a415fce-84c3-4efa-bdaa-aa0c2782d1a7
# ╟─3d9585f3-3996-4e7d-a4ca-7ba635743347
# ╟─9012e6b7-d2c1-44e7-bc78-23d535b6a18a
# ╟─838e8e45-8fb4-485b-8d11-73310a1314d2
# ╟─933605ca-5578-475a-9169-3bebb045e51c
# ╠═bd0504fa-bcb2-46c0-85ca-3621fe1d9830
# ╟─806fb8ea-3fd8-4027-a186-57c7e0743c82
# ╠═210cc6be-378c-4dfb-88a7-1765a7a14851
# ╠═ad530ede-8977-4f58-890c-8030f960bc32
# ╠═439ab82d-58e1-403e-8970-5839552cd8b2
# ╟─a83906a7-14ca-43e2-b834-a8ec2b98a5dd
# ╠═4c4316da-6f1a-4b25-96ee-f6e9dc3abac0
# ╠═5b7b3927-4835-440a-9e3d-584e743f4f54
# ╟─c738db8f-c24f-4d13-b000-3117feae379b
# ╠═77f7e7b3-796a-4beb-a914-e6633e56a7dd
# ╠═be9c7a89-1e8c-4727-9589-ab0b6af16afd
# ╠═4f314c1b-b440-4f32-babc-4682c89923ce
# ╠═9274d996-a232-4260-b99a-59ce173b63dd
# ╟─c23e0eb2-4161-4644-bc61-3c6a219d02ed
# ╠═60ba4628-3485-44a7-aa8d-67d1e8a17f8a
# ╠═b237b619-f911-4320-baeb-652e1406dbca
# ╟─742b5b59-2c44-41d8-95d7-79e530c65721
# ╠═7671f642-4a26-4a46-9c8b-6b2817477dee
# ╠═a99a377c-ad48-47e7-bdff-3b8c0207170c
# ╠═23bebd84-e366-4f2e-a99a-968d30b1f490
# ╟─37276c83-dfb9-4002-9ca3-a417c219ca11
# ╟─98c1e77c-c7e8-49a5-b4dc-3e19eea29093
# ╠═db663f82-e093-438f-bbcd-5cebc2a0548d
# ╟─6e5143ee-076e-49c4-845e-14b458287a8e
# ╟─63990f70-c15f-4bc2-9e5a-097fd5b5716f
# ╟─ba3c037c-450b-4077-855c-1a640f78adb2
# ╟─16e28d47-1ef9-4dc6-a065-e3c0a743b977
# ╟─354ffe45-cff7-4f73-9b55-78eca85bb41e
# ╟─a66c9cd1-664c-46d1-a0c2-c1a10f519a37
# ╟─4b42461c-b12c-41e0-8081-b7daf9c3c3b2
# ╟─f57ef7f0-9445-4faf-863c-d94b13376af1
# ╟─80c28ca8-b2d8-4ff8-b986-86f0e2e787dc
# ╟─e9f91650-e273-43c1-b2d5-286c4b2525d9
# ╠═02f6bb46-bf93-49db-969d-50a5af73c457
# ╠═6f085ece-1eb4-47a5-90a0-4d80324d2ff9
# ╟─e045ff5a-a8cf-4cde-bbb5-0c9464a37e4b
# ╠═ce38fa53-bad6-47d0-9886-a34313efaef2
# ╠═28aed164-1400-4dd6-b099-5ac4e8572933
# ╠═408352ef-8851-4b93-8b2d-404c9946ad49
# ╠═353360c4-941a-42f1-8b3a-8521033be9b3
# ╠═226d50ce-e797-45f4-8b67-17c3b717ded2
# ╟─5abc77ec-21f2-408b-963b-8d99c61566c8
# ╟─1b7bc694-dbb6-4d81-91a0-b8f858f399cb
# ╠═10574023-f668-424a-8e62-450a2a333e0a
# ╠═0bc77d7b-8e7f-4270-876b-09e6ee331829
# ╟─03f3e1ef-c878-47cf-8167-7d192076bc98
# ╟─809c0aae-d8e3-4b9c-a0a7-2ebc97723808
# ╠═752f1e07-b45f-4be9-802d-c8c26a42ea4b
# ╠═9cfe79cd-4754-4f86-a616-53a38e084d26
# ╟─0820e03a-6840-46e8-a082-d592fb1b0037
# ╠═d93b1e4c-414a-460d-8f8b-9b12b54a5de8
# ╟─62aa2363-a8df-4615-9787-e2ecba4097be
# ╟─18ab1044-01a6-4c5a-baec-2cf83cae7563
# ╟─e77fb294-a7e1-48f4-977a-a58f86d758ef
# ╟─f293b8c6-8876-4889-afb6-5c87c09612ae
# ╟─6544c7fb-4ca5-451f-bcf2-4b99ef3ae587
# ╟─e140027f-3121-4527-949b-cebad95a19e5
# ╟─045a2a80-9398-4af0-ab31-a4bf574af334
# ╟─9eca1b24-e770-46d5-9ede-2bd74e4f1879
