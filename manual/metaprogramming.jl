### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03cc7e80-9e19-11eb-179f-4bf4a585b92d
md"""
# Metaprogramming
"""

# ╔═╡ 03cc7f20-9e19-11eb-30cd-37f12222466e
md"""
The strongest legacy of Lisp in the Julia language is its metaprogramming support. Like Lisp, Julia represents its own code as a data structure of the language itself. Since code is represented by objects that can be created and manipulated from within the language, it is possible for a program to transform and generate its own code. This allows sophisticated code generation without extra build steps, and also allows true Lisp-style macros operating at the level of [abstract syntax trees](https://en.wikipedia.org/wiki/Abstract_syntax_tree). In contrast, preprocessor "macro" systems, like that of C and C++, perform textual manipulation and substitution before any actual parsing or interpretation occurs. Because all data types and code in Julia are represented by Julia data structures, powerful [reflection](https://en.wikipedia.org/wiki/Reflection_%28computer_programming%29) capabilities are available to explore the internals of a program and its types just like any other data.
"""

# ╔═╡ 03cc7f52-9e19-11eb-1dd7-513c3b81eaa4
md"""
## Program representation
"""

# ╔═╡ 03cc7f66-9e19-11eb-1740-ad59d009c55e
md"""
Every Julia program starts life as a string:
"""

# ╔═╡ 03cc8290-9e19-11eb-362a-9b0d830d3d49
prog = "1 + 1"

# ╔═╡ 03cc8308-9e19-11eb-0262-fb641b7b9eb1
md"""
**What happens next?**
"""

# ╔═╡ 03cc833a-9e19-11eb-2b63-e586aa13ce0a
md"""
The next step is to [parse](https://en.wikipedia.org/wiki/Parsing#Computer_languages) each string into an object called an expression, represented by the Julia type [`Expr`](@ref):
"""

# ╔═╡ 03cc85d8-9e19-11eb-013e-a9313c0e9c28
ex1 = Meta.parse(prog)

# ╔═╡ 03cc85e4-9e19-11eb-1b3d-af4a02cad3e8
typeof(ex1)

# ╔═╡ 03cc85f6-9e19-11eb-3b26-1b26dc0d2ca1
md"""
`Expr` objects contain two parts:
"""

# ╔═╡ 03cc86c8-9e19-11eb-2505-4b7a1b7c87a5
md"""
  * a [`Symbol`](@ref) identifying the kind of expression. A symbol is an [interned string](https://en.wikipedia.org/wiki/String_interning) identifier (more discussion below).
"""

# ╔═╡ 03cc8786-9e19-11eb-1b3d-f56f5722f522
ex1.head

# ╔═╡ 03cc87b8-9e19-11eb-1efe-210c0c70032c
md"""
  * the expression arguments, which may be symbols, other expressions, or literal values:
"""

# ╔═╡ 03cc8862-9e19-11eb-30fb-b5a96714d4c4
ex1.args

# ╔═╡ 03cc8882-9e19-11eb-1029-2d678baac0ec
md"""
Expressions may also be constructed directly in [prefix notation](https://en.wikipedia.org/wiki/Polish_notation):
"""

# ╔═╡ 03cc8b5a-9e19-11eb-29bc-55a2209ccbbe
ex2 = Expr(:call, :+, 1, 1)

# ╔═╡ 03cc8b6e-9e19-11eb-18bf-176fb3b2b960
md"""
The two expressions constructed above – by parsing and by direct construction – are equivalent:
"""

# ╔═╡ 03cc8c68-9e19-11eb-2142-5b1451dc2cb6
ex1 == ex2

# ╔═╡ 03cc8c7c-9e19-11eb-1b83-2d04c94fbead
md"""
**The key point here is that Julia code is internally represented as a data structure that is accessible from the language itself.**
"""

# ╔═╡ 03cc8ca4-9e19-11eb-11d0-116ce78bca37
md"""
The [`dump`](@ref) function provides indented and annotated display of `Expr` objects:
"""

# ╔═╡ 03cc8d7e-9e19-11eb-334b-cb583b903a7f
dump(ex2)

# ╔═╡ 03cc8d94-9e19-11eb-3359-4f4ff083227d
md"""
`Expr` objects may also be nested:
"""

# ╔═╡ 03cc8f58-9e19-11eb-037e-e77ee52b29d3
ex3 = Meta.parse("(4 + 4) / 2")

# ╔═╡ 03cc8f8a-9e19-11eb-3e40-97cde36a12f8
md"""
Another way to view expressions is with `Meta.show_sexpr`, which displays the [S-expression](https://en.wikipedia.org/wiki/S-expression) form of a given `Expr`, which may look very familiar to users of Lisp. Here's an example illustrating the display on a nested `Expr`:
"""

# ╔═╡ 03cc9078-9e19-11eb-1dd6-653d66742c97
Meta.show_sexpr(ex3)

# ╔═╡ 03cc90aa-9e19-11eb-0b50-11402012df26
md"""
### Symbols
"""

# ╔═╡ 03cc90dc-9e19-11eb-222d-6d6786a046c4
md"""
The `:` character has two syntactic purposes in Julia. The first form creates a [`Symbol`](@ref), an [interned string](https://en.wikipedia.org/wiki/String_interning) used as one building-block of expressions:
"""

# ╔═╡ 03cc9280-9e19-11eb-0a8c-a5ec8724ae99
s = :foo

# ╔═╡ 03cc9294-9e19-11eb-0855-d1046682db04
typeof(s)

# ╔═╡ 03cc92b2-9e19-11eb-23d4-7367606e446c
md"""
The [`Symbol`](@ref) constructor takes any number of arguments and creates a new symbol by concatenating their string representations together:
"""

# ╔═╡ 03cc974e-9e19-11eb-2dfb-b309e6fb7d62
:foo == Symbol("foo")

# ╔═╡ 03cc974e-9e19-11eb-2ee0-e398f358f471
Symbol("func",10)

# ╔═╡ 03cc9758-9e19-11eb-2e6c-01bd71a4fb65
Symbol(:var,'_',"sym")

# ╔═╡ 03cc9776-9e19-11eb-3dab-f3e90c71561b
md"""
Note that to use `:` syntax, the symbol's name must be a valid identifier. Otherwise the `Symbol(str)` constructor must be used.
"""

# ╔═╡ 03cc9796-9e19-11eb-11e2-6d091d253787
md"""
In the context of an expression, symbols are used to indicate access to variables; when an expression is evaluated, a symbol is replaced with the value bound to that symbol in the appropriate [scope](@ref scope-of-variables).
"""

# ╔═╡ 03cc97a8-9e19-11eb-0ecd-133988a3fbaa
md"""
Sometimes extra parentheses around the argument to `:` are needed to avoid ambiguity in parsing:
"""

# ╔═╡ 03cc994c-9e19-11eb-39cc-2d548ab9e6d3
:(:)

# ╔═╡ 03cc9956-9e19-11eb-109f-19bf82e3f0fd
:(::)

# ╔═╡ 03cc996a-9e19-11eb-10f4-db43ee899d80
md"""
## Expressions and evaluation
"""

# ╔═╡ 03cc997e-9e19-11eb-286b-ed82be0c4860
md"""
### Quoting
"""

# ╔═╡ 03cc99ba-9e19-11eb-33a3-8313aaf4a112
md"""
The second syntactic purpose of the `:` character is to create expression objects without using the explicit [`Expr`](@ref) constructor. This is referred to as *quoting*. The `:` character, followed by paired parentheses around a single statement of Julia code, produces an `Expr` object based on the enclosed code. Here is example of the short form used to quote an arithmetic expression:
"""

# ╔═╡ 03cc9d3e-9e19-11eb-33a3-010163562a0e
ex = :(a+b*c+1)

# ╔═╡ 03cc9d48-9e19-11eb-0f58-b97411cb21fc
typeof(ex)

# ╔═╡ 03cc9d70-9e19-11eb-055f-21c10b36f8b1
md"""
(to view the structure of this expression, try `ex.head` and `ex.args`, or use [`dump`](@ref) as above or [`Meta.@dump`](@ref))
"""

# ╔═╡ 03cc9d8e-9e19-11eb-3685-717dc6950e96
md"""
Note that equivalent expressions may be constructed using [`Meta.parse`](@ref) or the direct `Expr` form:
"""

# ╔═╡ 03cca432-9e19-11eb-1c03-65675fd183e5
:(a + b*c + 1)       ==
       Meta.parse("a + b*c + 1") ==
       Expr(:call, :+, :a, Expr(:call, :*, :b, :c), 1)

# ╔═╡ 03cca450-9e19-11eb-30e2-3768a34ba9a6
md"""
Expressions provided by the parser generally only have symbols, other expressions, and literal values as their args, whereas expressions constructed by Julia code can have arbitrary run-time values without literal forms as args. In this specific example, `+` and `a` are symbols, `*(b,c)` is a subexpression, and `1` is a literal 64-bit signed integer.
"""

# ╔═╡ 03cca464-9e19-11eb-2455-f73cf5be85af
md"""
There is a second syntactic form of quoting for multiple expressions: blocks of code enclosed in `quote ... end`.
"""

# ╔═╡ 03cca876-9e19-11eb-057d-8b9aca075210
ex = quote
           x = 1
           y = 2
           x + y
       end

# ╔═╡ 03cca888-9e19-11eb-046b-65202c3d4387
typeof(ex)

# ╔═╡ 03cca8b0-9e19-11eb-016d-55fff28477db
md"""
### [Interpolation](@id man-expression-interpolation)
"""

# ╔═╡ 03cca8d6-9e19-11eb-0192-5d94215d92bb
md"""
Direct construction of [`Expr`](@ref) objects with value arguments is powerful, but `Expr` constructors can be tedious compared to "normal" Julia syntax. As an alternative, Julia allows *interpolation* of literals or expressions into quoted expressions. Interpolation is indicated by a prefix `$`.
"""

# ╔═╡ 03cca8ec-9e19-11eb-37f9-819135641e61
md"""
In this example, the value of variable `a` is interpolated:
"""

# ╔═╡ 03ccab80-9e19-11eb-2908-3fa9398228f4
a = 1;

# ╔═╡ 03ccab8a-9e19-11eb-0385-3bf11c0e6864
ex = :($a + b)

# ╔═╡ 03ccab9e-9e19-11eb-11b9-7d3652c91b5e
md"""
Interpolating into an unquoted expression is not supported and will cause a compile-time error:
"""

# ╔═╡ 03ccac5c-9e19-11eb-0e1a-cbb84bb5ca2d
$a + b

# ╔═╡ 03ccac70-9e19-11eb-2c65-f5b41f747aad
md"""
In this example, the tuple `(1,2,3)` is interpolated as an expression into a conditional test:
"""

# ╔═╡ 03ccaf22-9e19-11eb-2d7a-21f270336afe
ex = :(a in $:((1,2,3)) )

# ╔═╡ 03ccaf4c-9e19-11eb-03c8-d3b7bab13e04
md"""
The use of `$` for expression interpolation is intentionally reminiscent of [string interpolation](@ref string-interpolation) and [command interpolation](@ref command-interpolation). Expression interpolation allows convenient, readable programmatic construction of complex Julia expressions.
"""

# ╔═╡ 03ccaf5e-9e19-11eb-3bb6-afc472ce01bd
md"""
### Splatting interpolation
"""

# ╔═╡ 03ccaf7a-9e19-11eb-2f58-e753935b3d23
md"""
Notice that the `$` interpolation syntax allows inserting only a single expression into an enclosing expression. Occasionally, you have an array of expressions and need them all to become arguments of the surrounding expression. This can be done with the syntax `$(xs...)`. For example, the following code generates a function call where the number of arguments is determined programmatically:
"""

# ╔═╡ 03ccb3be-9e19-11eb-02da-0b34d9945e9f
args = [:x, :y, :z];

# ╔═╡ 03ccb3c8-9e19-11eb-30bb-bb3e51d6e4ad
:(f(1, $(args...)))

# ╔═╡ 03ccb3d2-9e19-11eb-2c96-ed6de4dd9726
md"""
### Nested quote
"""

# ╔═╡ 03ccb3e4-9e19-11eb-3c25-75ed05e6a369
md"""
Naturally, it is possible for quote expressions to contain other quote expressions. Understanding how interpolation works in these cases can be a bit tricky. Consider this example:
"""

# ╔═╡ 03ccb76a-9e19-11eb-3541-cf00a007bb5b
x = :(1 + 2);

# ╔═╡ 03ccb774-9e19-11eb-17e1-b191b67a42f7
e = quote quote $x end end

# ╔═╡ 03ccb792-9e19-11eb-07d5-f3000d83796a
md"""
Notice that the result contains `$x`, which means that `x` has not been evaluated yet. In other words, the `$` expression "belongs to" the inner quote expression, and so its argument is only evaluated when the inner quote expression is:
"""

# ╔═╡ 03ccb850-9e19-11eb-2fea-858b5c245cd2
eval(e)

# ╔═╡ 03ccb86e-9e19-11eb-29d7-dba331ff8ec6
md"""
However, the outer `quote` expression is able to interpolate values inside the `$` in the inner quote. This is done with multiple `$`s:
"""

# ╔═╡ 03ccba12-9e19-11eb-30a1-bb1784975ebf
e = quote quote $$x end end

# ╔═╡ 03ccba30-9e19-11eb-2007-2dfbe805f936
md"""
Notice that `(1 + 2)` now appears in the result instead of the symbol `x`. Evaluating this expression yields an interpolated `3`:
"""

# ╔═╡ 03ccbaee-9e19-11eb-10b5-01396515c779
eval(e)

# ╔═╡ 03ccbb16-9e19-11eb-35f2-5f87813b7187
md"""
The intuition behind this behavior is that `x` is evaluated once for each `$`: one `$` works similarly to `eval(:x)`, giving `x`'s value, while two `$`s do the equivalent of `eval(eval(:x))`.
"""

# ╔═╡ 03ccbb34-9e19-11eb-01da-af38e0d1a01b
md"""
### [QuoteNode](@id man-quote-node)
"""

# ╔═╡ 03ccbb5e-9e19-11eb-3331-a95901ab947d
md"""
The usual representation of a `quote` form in an AST is an [`Expr`](@ref) with head `:quote`:
"""

# ╔═╡ 03ccbd0a-9e19-11eb-3f90-25127c484cc2
dump(Meta.parse(":(1+2)"))

# ╔═╡ 03ccbd26-9e19-11eb-1c23-517b810e884d
md"""
As we have seen, such expressions support interpolation with `$`. However, in some situations it is necessary to quote code *without* performing interpolation. This kind of quoting does not yet have syntax, but is represented internally as an object of type `QuoteNode`:
"""

# ╔═╡ 03ccc372-9e19-11eb-2d5d-d9aea687e402
eval(Meta.quot(Expr(:$, :(1+2))))

# ╔═╡ 03ccc372-9e19-11eb-2dfb-9d6632bcf40e
eval(QuoteNode(Expr(:$, :(1+2))))

# ╔═╡ 03ccc390-9e19-11eb-1c75-550e98e9e81b
md"""
The parser yields `QuoteNode`s for simple quoted items like symbols:
"""

# ╔═╡ 03ccc516-9e19-11eb-0cf5-cf71cdc5f92c
dump(Meta.parse(":x"))

# ╔═╡ 03ccc536-9e19-11eb-2c1c-859efe77d900
md"""
`QuoteNode` can also be used for certain advanced metaprogramming tasks.
"""

# ╔═╡ 03ccc53e-9e19-11eb-29e0-13dfcc440b77
md"""
### Evaluating expressions
"""

# ╔═╡ 03ccc55c-9e19-11eb-1864-4939bec3d292
md"""
Given an expression object, one can cause Julia to evaluate (execute) it at global scope using [`eval`](@ref):
"""

# ╔═╡ 03cccc28-9e19-11eb-2986-514455cb26ac
ex1 = :(1 + 2)

# ╔═╡ 03cccc28-9e19-11eb-3adf-afb11a2f1125
eval(ex1)

# ╔═╡ 03cccc32-9e19-11eb-1cc5-5d318e79d216
ex = :(a + b)

# ╔═╡ 03cccc32-9e19-11eb-12f1-094dd8915f0a
eval(ex)

# ╔═╡ 03cccc32-9e19-11eb-24dd-bfee09c6901f
a = 1; b = 2;

# ╔═╡ 03cccc3a-9e19-11eb-3330-cbe48f1d19dd
eval(ex)

# ╔═╡ 03cccc6c-9e19-11eb-12a5-e96b8266f720
md"""
Every [module](@ref modules) has its own [`eval`](@ref) function that evaluates expressions in its global scope. Expressions passed to [`eval`](@ref) are not limited to returning values – they can also have side-effects that alter the state of the enclosing module's environment:
"""

# ╔═╡ 03cccf66-9e19-11eb-3ea9-fda557016d9e
ex = :(x = 1)

# ╔═╡ 03cccf70-9e19-11eb-00ae-8365a033ff85
x

# ╔═╡ 03cccf70-9e19-11eb-0a82-434aeed9c11e
eval(ex)

# ╔═╡ 03cccf7a-9e19-11eb-154b-819289c3b1a0
x

# ╔═╡ 03cccf8e-9e19-11eb-368f-afa085b49d7e
md"""
Here, the evaluation of an expression object causes a value to be assigned to the global variable `x`.
"""

# ╔═╡ 03cccfac-9e19-11eb-19f5-c11b0a07e232
md"""
Since expressions are just `Expr` objects which can be constructed programmatically and then evaluated, it is possible to dynamically generate arbitrary code which can then be run using [`eval`](@ref). Here is a simple example:
"""

# ╔═╡ 03ccd5a6-9e19-11eb-35df-5b33bd1d5480
a = 1;

# ╔═╡ 03ccd5b2-9e19-11eb-38cd-6b23f6980e99
ex = Expr(:call, :+, a, :b)

# ╔═╡ 03ccd5b2-9e19-11eb-39bb-6d72a67f2aac
a = 0; b = 2;

# ╔═╡ 03ccd5e0-9e19-11eb-26df-2d5bb58e462b
eval(ex)

# ╔═╡ 03ccd60a-9e19-11eb-05fe-7d9b2d4f9675
md"""
The value of `a` is used to construct the expression `ex` which applies the `+` function to the value 1 and the variable `b`. Note the important distinction between the way `a` and `b` are used:
"""

# ╔═╡ 03ccd6d2-9e19-11eb-2edf-8774cbf35a67
md"""
  * The value of the *variable* `a` at expression construction time is used as an immediate value in the expression. Thus, the value of `a` when the expression is evaluated no longer matters: the value in the expression is already `1`, independent of whatever the value of `a` might be.
  * On the other hand, the *symbol* `:b` is used in the expression construction, so the value of the variable `b` at that time is irrelevant – `:b` is just a symbol and the variable `b` need not even be defined. At expression evaluation time, however, the value of the symbol `:b` is resolved by looking up the value of the variable `b`.
"""

# ╔═╡ 03ccd6e8-9e19-11eb-0791-1587d247ded6
md"""
### Functions on `Expr`essions
"""

# ╔═╡ 03ccd71a-9e19-11eb-30b5-7f1c69e82504
md"""
As hinted above, one extremely useful feature of Julia is the capability to generate and manipulate Julia code within Julia itself. We have already seen one example of a function returning [`Expr`](@ref) objects: the [`parse`](@ref) function, which takes a string of Julia code and returns the corresponding `Expr`. A function can also take one or more `Expr` objects as arguments, and return another `Expr`. Here is a simple, motivating example:
"""

# ╔═╡ 03ccde70-9e19-11eb-333c-1380492abf02
function math_expr(op, op1, op2)
           expr = Expr(:call, op, op1, op2)
           return expr
       end

# ╔═╡ 03ccde7a-9e19-11eb-16fc-5141099c84c3
ex = math_expr(:+, 1, Expr(:call, :*, 4, 5))

# ╔═╡ 03ccde7a-9e19-11eb-3f1d-af4c79b9d3e0
eval(ex)

# ╔═╡ 03ccde8e-9e19-11eb-3432-0112b47ba011
md"""
As another example, here is a function that doubles any numeric argument, but leaves expressions alone:
"""

# ╔═╡ 03cceb54-9e19-11eb-1394-414aa1085038
function make_expr2(op, opr1, opr2)
           opr1f, opr2f = map(x -> isa(x, Number) ? 2*x : x, (opr1, opr2))
           retexpr = Expr(:call, op, opr1f, opr2f)
           return retexpr
       end

# ╔═╡ 03cceb54-9e19-11eb-31af-534946ccbede
make_expr2(:+, 1, 2)

# ╔═╡ 03cceb5e-9e19-11eb-17be-7b015f9a0aad
ex = make_expr2(:+, 1, Expr(:call, :*, 5, 8))

# ╔═╡ 03cceb5e-9e19-11eb-0e4a-41d8e095a5f7
eval(ex)

# ╔═╡ 03cceb7c-9e19-11eb-0ae8-35a2a64cffdd
md"""
## [Macros](@id man-macros)
"""

# ╔═╡ 03cceba4-9e19-11eb-19eb-273c2affc523
md"""
Macros provide a method to include generated code in the final body of a program. A macro maps a tuple of arguments to a returned *expression*, and the resulting expression is compiled directly rather than requiring a runtime [`eval`](@ref) call. Macro arguments may include expressions, literal values, and symbols.
"""

# ╔═╡ 03ccebb8-9e19-11eb-1f80-4f94141a1c85
md"""
### Basics
"""

# ╔═╡ 03ccebc2-9e19-11eb-0c94-a397af331728
md"""
Here is an extraordinarily simple macro:
"""

# ╔═╡ 03ccee74-9e19-11eb-1945-95f6f63a1a0d
macro sayhello()
           return :( println("Hello, world!") )
       end

# ╔═╡ 03ccee92-9e19-11eb-2d8e-7dd375b5844b
md"""
Macros have a dedicated character in Julia's syntax: the `@` (at-sign), followed by the unique name declared in a `macro NAME ... end` block. In this example, the compiler will replace all instances of `@sayhello` with:
"""

# ╔═╡ 03cceed8-9e19-11eb-23ee-a739d187f47c
md"""
```julia
:( println("Hello, world!") )
```
"""

# ╔═╡ 03cceeec-9e19-11eb-38bf-bf538b40cf80
md"""
When `@sayhello` is entered in the REPL, the expression executes immediately, thus we only see the evaluation result:
"""

# ╔═╡ 03cceff0-9e19-11eb-2f3d-75794ca16d99
@sayhello()

# ╔═╡ 03ccf002-9e19-11eb-225f-654c7768d3da
md"""
Now, consider a slightly more complex macro:
"""

# ╔═╡ 03ccf310-9e19-11eb-12cc-6f0af8330b87
macro sayhello(name)
           return :( println("Hello, ", $name) )
       end

# ╔═╡ 03ccf338-9e19-11eb-2e71-ed66ee8fe74c
md"""
This macro takes one argument: `name`. When `@sayhello` is encountered, the quoted expression is *expanded* to interpolate the value of the argument into the final expression:
"""

# ╔═╡ 03ccf464-9e19-11eb-2290-79db30f6786e
@sayhello("human")

# ╔═╡ 03ccf48c-9e19-11eb-2c27-43ddb72044e9
md"""
We can view the quoted return expression using the function [`macroexpand`](@ref) (**important note:** this is an extremely useful tool for debugging macros):
"""

# ╔═╡ 03ccf798-9e19-11eb-2b04-97090ef5ca7f
ex = macroexpand(Main, :(@sayhello("human")) )

# ╔═╡ 03ccf7a2-9e19-11eb-3630-8bffd2de56eb
typeof(ex)

# ╔═╡ 03ccf7b6-9e19-11eb-2f8d-65356683f234
md"""
We can see that the `"human"` literal has been interpolated into the expression.
"""

# ╔═╡ 03ccf7d4-9e19-11eb-10e6-37a1106d0f53
md"""
There also exists a macro [`@macroexpand`](@ref) that is perhaps a bit more convenient than the `macroexpand` function:
"""

# ╔═╡ 03ccf976-9e19-11eb-32eb-0b2dbfcef976
@macroexpand @sayhello "human"

# ╔═╡ 03ccf98c-9e19-11eb-0936-3350ac6cd80c
md"""
### Hold up: why macros?
"""

# ╔═╡ 03ccf9b4-9e19-11eb-1ba1-9589e0cf53fa
md"""
We have already seen a function `f(::Expr...) -> Expr` in a previous section. In fact, [`macroexpand`](@ref) is also such a function. So, why do macros exist?
"""

# ╔═╡ 03ccf9d2-9e19-11eb-13cc-9919fe37defa
md"""
Macros are necessary because they execute when code is parsed, therefore, macros allow the programmer to generate and include fragments of customized code *before* the full program is run. To illustrate the difference, consider the following example:
"""

# ╔═╡ 03cd04cc-9e19-11eb-1804-35111aacacdf
macro twostep(arg)
           println("I execute at parse time. The argument is: ", arg)
           return :(println("I execute at runtime. The argument is: ", $arg))
       end

# ╔═╡ 03cd04d6-9e19-11eb-164c-5d54409cb170
ex = macroexpand(Main, :(@twostep :(1, 2, 3)) );

# ╔═╡ 03cd0544-9e19-11eb-0003-61d9e75b047c
md"""
The first call to [`println`](@ref) is executed when [`macroexpand`](@ref) is called. The resulting expression contains *only* the second `println`:
"""

# ╔═╡ 03cd082a-9e19-11eb-0996-d100725d1875
typeof(ex)

# ╔═╡ 03cd0832-9e19-11eb-3f44-1799723e0feb
ex

# ╔═╡ 03cd083c-9e19-11eb-22df-7b6e742b6db5
eval(ex)

# ╔═╡ 03cd086e-9e19-11eb-2766-0deeedd1fadd
md"""
### Macro invocation
"""

# ╔═╡ 03cd088a-9e19-11eb-300e-374026c4fefe
md"""
Macros are invoked with the following general syntax:
"""

# ╔═╡ 03cd08c8-9e19-11eb-238b-ff462de26d67
md"""
```julia
@name expr1 expr2 ...
@name(expr1, expr2, ...)
```
"""

# ╔═╡ 03cd08fa-9e19-11eb-12ab-bf42ee18dd8e
md"""
Note the distinguishing `@` before the macro name and the lack of commas between the argument expressions in the first form, and the lack of whitespace after `@name` in the second form. The two styles should not be mixed. For example, the following syntax is different from the examples above; it passes the tuple `(expr1, expr2, ...)` as one argument to the macro:
"""

# ╔═╡ 03cd092c-9e19-11eb-3ea9-eb2012a248b5
md"""
```julia
@name (expr1, expr2, ...)
```
"""

# ╔═╡ 03cd094a-9e19-11eb-2071-5dbc5e4137d6
md"""
An alternative way to invoke a macro over an array literal (or comprehension) is to juxtapose both without using parentheses. In this case, the array will be the only expression fed to the macro. The following syntax is equivalent (and different from `@name [a b] * v`):
"""

# ╔═╡ 03cd0960-9e19-11eb-3f00-8956e48e52fa
md"""
```julia
@name[a b] * v
@name([a b]) * v
```
"""

# ╔═╡ 03cd097c-9e19-11eb-2c7f-6b5de3b9e63d
md"""
It is important to emphasize that macros receive their arguments as expressions, literals, or symbols. One way to explore macro arguments is to call the [`show`](@ref) function within the macro body:
"""

# ╔═╡ 03cd111a-9e19-11eb-19c7-250bdec48f75
macro showarg(x)
           show(x)
           # ... remainder of macro, returning an expression
       end

# ╔═╡ 03cd1124-9e19-11eb-1954-19d86d9b6b27
@showarg(a)

# ╔═╡ 03cd1124-9e19-11eb-2bbe-89fd8b3a8137
@showarg(1+1)

# ╔═╡ 03cd112c-9e19-11eb-2c61-af7b463556f5
@showarg(println("Yo!"))

# ╔═╡ 03cd114c-9e19-11eb-102e-736fc08dd38a
md"""
In addition to the given argument list, every macro is passed extra arguments named `__source__` and `__module__`.
"""

# ╔═╡ 03cd117e-9e19-11eb-1117-33e9dd9b9425
md"""
The argument `__source__` provides information (in the form of a `LineNumberNode` object) about the parser location of the `@` sign from the macro invocation. This allows macros to include better error diagnostic information, and is commonly used by logging, string-parser macros, and docs, for example, as well as to implement the [`@__LINE__`](@ref), [`@__FILE__`](@ref), and [`@__DIR__`](@ref) macros.
"""

# ╔═╡ 03cd1192-9e19-11eb-3edb-a910fc1d7452
md"""
The location information can be accessed by referencing `__source__.line` and `__source__.file`:
"""

# ╔═╡ 03cd14bc-9e19-11eb-0372-612840e525b3
macro __LOCATION__(); return QuoteNode(__source__); end

# ╔═╡ 03cd14bc-9e19-11eb-3b07-83e99c23ef2c
dump(
            @__LOCATION__(
       ))

# ╔═╡ 03cd14e4-9e19-11eb-1657-9dc520b2eb24
md"""
The argument `__module__` provides information (in the form of a `Module` object) about the expansion context of the macro invocation. This allows macros to look up contextual information, such as existing bindings, or to insert the value as an extra argument to a runtime function call doing self-reflection in the current module.
"""

# ╔═╡ 03cd14ee-9e19-11eb-3d3c-e70ee9a8eb0f
md"""
### Building an advanced macro
"""

# ╔═╡ 03cd150c-9e19-11eb-015f-c58895a933b4
md"""
Here is a simplified definition of Julia's [`@assert`](@ref) macro:
"""

# ╔═╡ 03cd1962-9e19-11eb-09c2-4b2e2c520fd9
macro assert(ex)
           return :( $ex ? nothing : throw(AssertionError($(string(ex)))) )
       end

# ╔═╡ 03cd1976-9e19-11eb-1d27-5319f043cbb9
md"""
This macro can be used like this:
"""

# ╔═╡ 03cd1d2c-9e19-11eb-0ee5-0bd7971e49f4
@assert 1 == 1.0

# ╔═╡ 03cd1d36-9e19-11eb-241e-c99277f46dff
@assert 1 == 0

# ╔═╡ 03cd1d3e-9e19-11eb-0e38-f5208ede4834
md"""
In place of the written syntax, the macro call is expanded at parse time to its returned result. This is equivalent to writing:
"""

# ╔═╡ 03cd1d5e-9e19-11eb-2ff5-492d1297c666
md"""
```julia
1 == 1.0 ? nothing : throw(AssertionError("1 == 1.0"))
1 == 0 ? nothing : throw(AssertionError("1 == 0"))
```
"""

# ╔═╡ 03cd1dae-9e19-11eb-1998-5f59254b419b
md"""
That is, in the first call, the expression `:(1 == 1.0)` is spliced into the test condition slot, while the value of `string(:(1 == 1.0))` is spliced into the assertion message slot. The entire expression, thus constructed, is placed into the syntax tree where the `@assert` macro call occurs. Then at execution time, if the test expression evaluates to true, then [`nothing`](@ref) is returned, whereas if the test is false, an error is raised indicating the asserted expression that was false. Notice that it would not be possible to write this as a function, since only the *value* of the condition is available and it would be impossible to display the expression that computed it in the error message.
"""

# ╔═╡ 03cd1dcc-9e19-11eb-0897-69267a4e91aa
md"""
The actual definition of `@assert` in Julia Base is more complicated. It allows the user to optionally specify their own error message, instead of just printing the failed expression. Just like in functions with a variable number of arguments ([Varargs Functions](@ref)), this is specified with an ellipses following the last argument:
"""

# ╔═╡ 03cd252e-9e19-11eb-379f-3d1c591b71c9
macro assert(ex, msgs...)
           msg_body = isempty(msgs) ? ex : msgs[1]
           msg = string(msg_body)
           return :($ex ? nothing : throw(AssertionError($msg)))
       end

# ╔═╡ 03cd2556-9e19-11eb-223f-b94d9bbabbb2
md"""
Now `@assert` has two modes of operation, depending upon the number of arguments it receives! If there's only one argument, the tuple of expressions captured by `msgs` will be empty and it will behave the same as the simpler definition above. But now if the user specifies a second argument, it is printed in the message body instead of the failing expression. You can inspect the result of a macro expansion with the aptly named [`@macroexpand`](@ref) macro:
"""

# ╔═╡ 03cd2966-9e19-11eb-1e86-776ce6f153e6
@macroexpand @assert a == b

# ╔═╡ 03cd298e-9e19-11eb-03fd-df5810e073ca
@macroexpand @assert a==b "a should equal b!"

# ╔═╡ 03cd29ca-9e19-11eb-3ca2-9bf6d26443f2
md"""
There is yet another case that the actual `@assert` macro handles: what if, in addition to printing "a should equal b," we wanted to print their values? One might naively try to use string interpolation in the custom message, e.g., `@assert a==b "a ($a) should equal b ($b)!"`, but this won't work as expected with the above macro. Can you see why? Recall from [string interpolation](@ref string-interpolation) that an interpolated string is rewritten to a call to [`string`](@ref). Compare:
"""

# ╔═╡ 03cd2efc-9e19-11eb-28c5-adc1a1c28857
typeof(:("a should equal b"))

# ╔═╡ 03cd2f06-9e19-11eb-2284-01970bd6f89c
typeof(:("a ($a) should equal b ($b)!"))

# ╔═╡ 03cd2f06-9e19-11eb-3d50-cb870973357e
dump(:("a ($a) should equal b ($b)!"))

# ╔═╡ 03cd2f38-9e19-11eb-0a47-87949f8fac64
md"""
So now instead of getting a plain string in `msg_body`, the macro is receiving a full expression that will need to be evaluated in order to display as expected. This can be spliced directly into the returned expression as an argument to the [`string`](@ref) call; see [`error.jl`](https://github.com/JuliaLang/julia/blob/master/base/error.jl) for the complete implementation.
"""

# ╔═╡ 03cd2f4c-9e19-11eb-2cac-a320b068500a
md"""
The `@assert` macro makes great use of splicing into quoted expressions to simplify the manipulation of expressions inside the macro body.
"""

# ╔═╡ 03cd2f54-9e19-11eb-1057-fd3f9ff01526
md"""
### Hygiene
"""

# ╔═╡ 03cd2f92-9e19-11eb-2611-d78f6dfd0ef0
md"""
An issue that arises in more complex macros is that of [hygiene](https://en.wikipedia.org/wiki/Hygienic_macro). In short, macros must ensure that the variables they introduce in their returned expressions do not accidentally clash with existing variables in the surrounding code they expand into. Conversely, the expressions that are passed into a macro as arguments are often *expected* to evaluate in the context of the surrounding code, interacting with and modifying the existing variables. Another concern arises from the fact that a macro may be called in a different module from where it was defined. In this case we need to ensure that all global variables are resolved to the correct module. Julia already has a major advantage over languages with textual macro expansion (like C) in that it only needs to consider the returned expression. All the other variables (such as `msg` in `@assert` above) follow the [normal scoping block behavior](@ref scope-of-variables).
"""

# ╔═╡ 03cd2fb0-9e19-11eb-21a2-ad8cd5f1c24c
md"""
To demonstrate these issues, let us consider writing a `@time` macro that takes an expression as its argument, records the time, evaluates the expression, records the time again, prints the difference between the before and after times, and then has the value of the expression as its final value. The macro might look like this:
"""

# ╔═╡ 03cd2fc6-9e19-11eb-0cc0-8507a919de57
md"""
```julia
macro time(ex)
    return quote
        local t0 = time_ns()
        local val = $ex
        local t1 = time_ns()
        println("elapsed time: ", (t1-t0)/1e9, " seconds")
        val
    end
end
```
"""

# ╔═╡ 03cd2ff8-9e19-11eb-3045-9b82c9f545e0
md"""
Here, we want `t0`, `t1`, and `val` to be private temporary variables, and we want `time_ns` to refer to the [`time_ns`](@ref) function in Julia Base, not to any `time_ns` variable the user might have (the same applies to `println`). Imagine the problems that could occur if the user expression `ex` also contained assignments to a variable called `t0`, or defined its own `time_ns` variable. We might get errors, or mysteriously incorrect behavior.
"""

# ╔═╡ 03cd3014-9e19-11eb-10d4-ab0ebf868004
md"""
Julia's macro expander solves these problems in the following way. First, variables within a macro result are classified as either local or global. A variable is considered local if it is assigned to (and not declared global), declared local, or used as a function argument name. Otherwise, it is considered global. Local variables are then renamed to be unique (using the [`gensym`](@ref) function, which generates new symbols), and global variables are resolved within the macro definition environment. Therefore both of the above concerns are handled; the macro's locals will not conflict with any user variables, and `time_ns` and `println` will refer to the Julia Base definitions.
"""

# ╔═╡ 03cd302a-9e19-11eb-1178-5d4cee34fb76
md"""
One problem remains however. Consider the following use of this macro:
"""

# ╔═╡ 03cd303c-9e19-11eb-2aef-e5083493744e
md"""
```julia
module MyModule
import Base.@time

time_ns() = ... # compute something

@time time_ns()
end
```
"""

# ╔═╡ 03cd3064-9e19-11eb-04f5-bfeceb2c090d
md"""
Here the user expression `ex` is a call to `time_ns`, but not the same `time_ns` function that the macro uses. It clearly refers to `MyModule.time_ns`. Therefore we must arrange for the code in `ex` to be resolved in the macro call environment. This is done by "escaping" the expression with [`esc`](@ref):
"""

# ╔═╡ 03cd3078-9e19-11eb-0a37-2d3e9b26778e
md"""
```julia
macro time(ex)
    ...
    local val = $(esc(ex))
    ...
end
```
"""

# ╔═╡ 03cd3082-9e19-11eb-2177-bd230958128d
md"""
An expression wrapped in this manner is left alone by the macro expander and simply pasted into the output verbatim. Therefore it will be resolved in the macro call environment.
"""

# ╔═╡ 03cd3096-9e19-11eb-1ad8-df02c4524dd6
md"""
This escaping mechanism can be used to "violate" hygiene when necessary, in order to introduce or manipulate user variables. For example, the following macro sets `x` to zero in the call environment:
"""

# ╔═╡ 03cd3758-9e19-11eb-1978-8f5da64fb0fd
macro zerox()
           return esc(:(x = 0))
       end

# ╔═╡ 03cd3758-9e19-11eb-0cb7-85fb9544704d
function foo()
           x = 1
           @zerox
           return x # is zero
       end

# ╔═╡ 03cd3758-9e19-11eb-3795-add5873ba185
foo()

# ╔═╡ 03cd376c-9e19-11eb-087e-252737934fe2
md"""
This kind of manipulation of variables should be used judiciously, but is occasionally quite handy.
"""

# ╔═╡ 03cd37bc-9e19-11eb-2e23-f5c48c1923de
md"""
Getting the hygiene rules correct can be a formidable challenge. Before using a macro, you might want to consider whether a function closure would be sufficient. Another useful strategy is to defer as much work as possible to runtime. For example, many macros simply wrap their arguments in a `QuoteNode` or other similar [`Expr`](@ref). Some examples of this include `@task body` which simply returns `schedule(Task(() -> $body))`, and `@eval expr`, which simply returns `eval(QuoteNode(expr))`.
"""

# ╔═╡ 03cd37d0-9e19-11eb-26d5-3b31299ce41a
md"""
To demonstrate, we might rewrite the `@time` example above as:
"""

# ╔═╡ 03cd37e4-9e19-11eb-2f5d-2986c1cc897c
md"""
```julia
macro time(expr)
    return :(timeit(() -> $(esc(expr))))
end
function timeit(f)
    t0 = time_ns()
    val = f()
    t1 = time_ns()
    println("elapsed time: ", (t1-t0)/1e9, " seconds")
    return val
end
```
"""

# ╔═╡ 03cd3804-9e19-11eb-35e1-d972a3033c7c
md"""
However, we don't do this for a good reason: wrapping the `expr` in a new scope block (the anonymous function) also slightly changes the meaning of the expression (the scope of any variables in it), while we want `@time` to be usable with minimum impact on the wrapped code.
"""

# ╔═╡ 03cd3816-9e19-11eb-29c3-5d60527c3080
md"""
### Macros and dispatch
"""

# ╔═╡ 03cd3836-9e19-11eb-3d76-17a83f805bf9
md"""
Macros, just like Julia functions, are generic. This means they can also have multiple method definitions, thanks to multiple dispatch:
"""

# ╔═╡ 03cd5efc-9e19-11eb-0361-2bb923f7d651
macro m end

# ╔═╡ 03cd5efc-9e19-11eb-260d-ad649cc3d0f6
macro m(args...)
           println("$(length(args)) arguments")
       end

# ╔═╡ 03cd5f08-9e19-11eb-3a05-2bae1d41bdbf
macro m(x,y)
           println("Two arguments")
       end

# ╔═╡ 03cd5f26-9e19-11eb-33f0-ab86b0452a39
@m "asd"

# ╔═╡ 03cd5f26-9e19-11eb-3371-533de75e86f4
@m 1 2

# ╔═╡ 03cd5f44-9e19-11eb-0291-e36ef6f0c1ac
md"""
However one should keep in mind, that macro dispatch is based on the types of AST that are handed to the macro, not the types that the AST evaluates to at runtime:
"""

# ╔═╡ 03cd6494-9e19-11eb-34c5-b76597de6b50
macro m(::Int)
           println("An Integer")
       end

# ╔═╡ 03cd649c-9e19-11eb-17b3-c506e0bfc5c8
@m 2

# ╔═╡ 03cd64a8-9e19-11eb-3ffb-8fd614361680
x = 2

# ╔═╡ 03cd64b2-9e19-11eb-180c-83fb2840585d
@m x

# ╔═╡ 03cd64e4-9e19-11eb-0d2f-b79fddeacc32
md"""
## Code Generation
"""

# ╔═╡ 03cd650c-9e19-11eb-240f-9d095ea97341
md"""
When a significant amount of repetitive boilerplate code is required, it is common to generate it programmatically to avoid redundancy. In most languages, this requires an extra build step, and a separate program to generate the repetitive code. In Julia, expression interpolation and [`eval`](@ref) allow such code generation to take place in the normal course of program execution. For example, consider the following custom type
"""

# ╔═╡ 03cd6692-9e19-11eb-339e-8936dbb46f64
struct MyNumber
    x::Float64
end

# ╔═╡ 03cd66a8-9e19-11eb-29c1-41074cb152f1
md"""
for which we want to add a number of methods to. We can do this programmatically in the following loop:
"""

# ╔═╡ 03cd6d36-9e19-11eb-189a-cd4267f22c06
for op = (:sin, :cos, :tan, :log, :exp)
    eval(quote
        Base.$op(a::MyNumber) = MyNumber($op(a.x))
    end)
end

# ╔═╡ 03cd6d4a-9e19-11eb-1361-edd3dfee5ac6
md"""
and we can now use those functions with our custom type:
"""

# ╔═╡ 03cd6fb6-9e19-11eb-1611-d1526c1a0442
x = MyNumber(π)

# ╔═╡ 03cd6fb6-9e19-11eb-1f0d-97fcfc2fabca
sin(x)

# ╔═╡ 03cd6fc0-9e19-11eb-2f23-57862f4fe2a2
cos(x)

# ╔═╡ 03cd6fdc-9e19-11eb-0274-e158f47fd303
md"""
In this manner, Julia acts as its own [preprocessor](https://en.wikipedia.org/wiki/Preprocessor), and allows code generation from inside the language. The above code could be written slightly more tersely using the `:` prefix quoting form:
"""

# ╔═╡ 03cd7010-9e19-11eb-3ba0-ab6a43ae57d7
md"""
```julia
for op = (:sin, :cos, :tan, :log, :exp)
    eval(:(Base.$op(a::MyNumber) = MyNumber($op(a.x))))
end
```
"""

# ╔═╡ 03cd7024-9e19-11eb-0d1b-e7ac325614dd
md"""
This sort of in-language code generation, however, using the `eval(quote(...))` pattern, is common enough that Julia comes with a macro to abbreviate this pattern:
"""

# ╔═╡ 03cd7038-9e19-11eb-2cd0-6bf82a4bb248
md"""
```julia
for op = (:sin, :cos, :tan, :log, :exp)
    @eval Base.$op(a::MyNumber) = MyNumber($op(a.x))
end
```
"""

# ╔═╡ 03cd706a-9e19-11eb-1d04-b58b999d87d2
md"""
The [`@eval`](@ref) macro rewrites this call to be precisely equivalent to the above longer versions. For longer blocks of generated code, the expression argument given to [`@eval`](@ref) can be a block:
"""

# ╔═╡ 03cd7080-9e19-11eb-3ee3-9b0ddd7a7833
md"""
```julia
@eval begin
    # multiple lines
end
```
"""

# ╔═╡ 03cd7092-9e19-11eb-3f0e-2f44b01fc874
md"""
## Non-Standard String Literals
"""

# ╔═╡ 03cd70b2-9e19-11eb-253a-45674db2f5d2
md"""
Recall from [Strings](@ref non-standard-string-literals) that string literals prefixed by an identifier are called non-standard string literals, and can have different semantics than un-prefixed string literals. For example:
"""

# ╔═╡ 03cd7150-9e19-11eb-2893-af8f7072e143
md"""
  * `r"^\s*(?:#|$)"` produces a regular expression object rather than a string
  * `b"DATA\xff\u2200"` is a byte array literal for `[68,65,84,65,255,226,136,128]`.
"""

# ╔═╡ 03cd7164-9e19-11eb-0598-8b30c99f6d7b
md"""
Perhaps surprisingly, these behaviors are not hard-coded into the Julia parser or compiler. Instead, they are custom behaviors provided by a general mechanism that anyone can use: prefixed string literals are parsed as calls to specially-named macros. For example, the regular expression macro is just the following:
"""

# ╔═╡ 03cd7178-9e19-11eb-0c7b-1f4637155c18
md"""
```julia
macro r_str(p)
    Regex(p)
end
```
"""

# ╔═╡ 03cd71aa-9e19-11eb-394f-2f008904bfce
md"""
That's all. This macro says that the literal contents of the string literal `r"^\s*(?:#|$)"` should be passed to the `@r_str` macro and the result of that expansion should be placed in the syntax tree where the string literal occurs. In other words, the expression `r"^\s*(?:#|$)"` is equivalent to placing the following object directly into the syntax tree:
"""

# ╔═╡ 03cd71b6-9e19-11eb-2060-d9ab741af14e
md"""
```julia
Regex("^\\s*(?:#|\$)")
```
"""

# ╔═╡ 03cd71d2-9e19-11eb-315e-35ec80e8c140
md"""
Not only is the string literal form shorter and far more convenient, but it is also more efficient: since the regular expression is compiled and the `Regex` object is actually created *when the code is compiled*, the compilation occurs only once, rather than every time the code is executed. Consider if the regular expression occurs in a loop:
"""

# ╔═╡ 03cd71f0-9e19-11eb-0091-d581a3f38933
md"""
```julia
for line = lines
    m = match(r"^\s*(?:#|$)", line)
    if m === nothing
        # non-comment
    else
        # comment
    end
end
```
"""

# ╔═╡ 03cd7204-9e19-11eb-3f42-6febfe74ee83
md"""
Since the regular expression `r"^\s*(?:#|$)"` is compiled and inserted into the syntax tree when this code is parsed, the expression is only compiled once instead of each time the loop is executed. In order to accomplish this without macros, one would have to write this loop like this:
"""

# ╔═╡ 03cd721a-9e19-11eb-1356-43be64345a28
md"""
```julia
re = Regex("^\\s*(?:#|\$)")
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

# ╔═╡ 03cd7236-9e19-11eb-1c5a-75fc976a2a01
md"""
Moreover, if the compiler could not determine that the regex object was constant over all loops, certain optimizations might not be possible, making this version still less efficient than the more convenient literal form above. Of course, there are still situations where the non-literal form is more convenient: if one needs to interpolate a variable into the regular expression, one must take this more verbose approach; in cases where the regular expression pattern itself is dynamic, potentially changing upon each loop iteration, a new regular expression object must be constructed on each iteration. In the vast majority of use cases, however, regular expressions are not constructed based on run-time data. In this majority of cases, the ability to write regular expressions as compile-time values is invaluable.
"""

# ╔═╡ 03cd729a-9e19-11eb-0534-e5e73f6f80d9
md"""
Like non-standard string literals, non-standard command literals exist using a prefixed variant of the command literal syntax. The command literal ```custom`literal` ``` is parsed as `@custom_cmd "literal"`. Julia itself does not contain any non-standard command literals, but packages can make use of this syntax. Aside from the different syntax and the `_cmd` suffix instead of the `_str` suffix, non-standard command literals behave exactly like non-standard string literals.
"""

# ╔═╡ 03cd72b8-9e19-11eb-2843-0757fb2ef607
md"""
In the event that two modules provide non-standard string or command literals with the same name, it is possible to qualify the string or command literal with a module name. For instance, if both `Foo` and `Bar` provide non-standard string literal `@x_str`, then one can write `Foo.x"literal"` or `Bar.x"literal"` to disambiguate between the two.
"""

# ╔═╡ 03cd72e0-9e19-11eb-3c56-490dff5bde04
md"""
The mechanism for user-defined string literals is deeply, profoundly powerful. Not only are Julia's non-standard literals implemented using it, but also the command literal syntax (``` `echo "Hello, $person"` ```) is implemented with the following innocuous-looking macro:
"""

# ╔═╡ 03cd72f4-9e19-11eb-2b9e-7f54e71e9825
md"""
```julia
macro cmd(str)
    :(cmd_gen($(shell_parse(str)[1])))
end
```
"""

# ╔═╡ 03cd7308-9e19-11eb-1d30-699d03105cae
md"""
Of course, a large amount of complexity is hidden in the functions used in this macro definition, but they are just functions, written entirely in Julia. You can read their source and see precisely what they do – and all they do is construct expression objects to be inserted into your program's syntax tree.
"""

# ╔═╡ 03cd7326-9e19-11eb-1891-71b406f75d19
md"""
Another way to define a macro would be like this:
"""

# ╔═╡ 03cd733a-9e19-11eb-21da-31e76b3652f2
md"""
```julia
macro foo_str(str, flag)
    # do stuff
end
```
"""

# ╔═╡ 03cd7350-9e19-11eb-2af5-1d12b98c2350
md"""
This macro can then be called with the following syntax:
"""

# ╔═╡ 03cd7358-9e19-11eb-3239-f346edb51e43
md"""
```julia
foo"str"flag
```
"""

# ╔═╡ 03cd7376-9e19-11eb-3556-0b7ea7f1fd2c
md"""
The type of flag in the above mentioned syntax would be a `String` with contents of whatever trails after the string literal.
"""

# ╔═╡ 03cd737e-9e19-11eb-177e-efe2c0b96563
md"""
## Generated functions
"""

# ╔═╡ 03cd73b0-9e19-11eb-2586-b926d0958e22
md"""
A very special macro is [`@generated`](@ref), which allows you to define so-called *generated functions*. These have the capability to generate specialized code depending on the types of their arguments with more flexibility and/or less code than what can be achieved with multiple dispatch. While macros work with expressions at parse time and cannot access the types of their inputs, a generated function gets expanded at a time when the types of the arguments are known, but the function is not yet compiled.
"""

# ╔═╡ 03cd73d0-9e19-11eb-1788-676d2701e496
md"""
Instead of performing some calculation or action, a generated function declaration returns a quoted expression which then forms the body for the method corresponding to the types of the arguments. When a generated function is called, the expression it returns is compiled and then run. To make this efficient, the result is usually cached. And to make this inferable, only a limited subset of the language is usable. Thus, generated functions provide a flexible way to move work from run time to compile time, at the expense of greater restrictions on allowed constructs.
"""

# ╔═╡ 03cd73e2-9e19-11eb-1a21-d3b456a9a478
md"""
When defining generated functions, there are five main differences to ordinary functions:
"""

# ╔═╡ 03cd7542-9e19-11eb-36bc-89add66424f3
md"""
1. You annotate the function declaration with the `@generated` macro. This adds some information to the AST that lets the compiler know that this is a generated function.
2. In the body of the generated function you only have access to the *types* of the arguments – not their values.
3. Instead of calculating something or performing some action, you return a *quoted expression* which, when evaluated, does what you want.
4. Generated functions are only permitted to call functions that were defined *before* the definition of the generated function. (Failure to follow this may result in getting `MethodErrors` referring to functions from a future world-age.)
5. Generated functions must not *mutate* or *observe* any non-constant global state (including, for example, IO, locks, non-local dictionaries, or using [`hasmethod`](@ref)). This means they can only read global constants, and cannot have any side effects. In other words, they must be completely pure. Due to an implementation limitation, this also means that they currently cannot define a closure or generator.
"""

# ╔═╡ 03cd7560-9e19-11eb-205e-f9812cd742fb
md"""
It's easiest to illustrate this with an example. We can declare a generated function `foo` as
"""

# ╔═╡ 03cd7902-9e19-11eb-332f-0d20ccde8141
@generated function foo(x)
           Core.println(x)
           return :(x * x)
       end

# ╔═╡ 03cd791e-9e19-11eb-0a8f-25daf9c263ca
md"""
Note that the body returns a quoted expression, namely `:(x * x)`, rather than just the value of `x * x`.
"""

# ╔═╡ 03cd7950-9e19-11eb-1774-99ebc58eb7dc
md"""
From the caller's perspective, this is identical to a regular function; in fact, you don't have to know whether you're calling a regular or generated function. Let's see how `foo` behaves:
"""

# ╔═╡ 03cd7d62-9e19-11eb-2faf-ed964fbd22cc
x = foo(2); # note: output is from println() statement in the body

# ╔═╡ 03cd7d6c-9e19-11eb-3bdf-cb50304b4d42
x           # now we print x

# ╔═╡ 03cd7d6c-9e19-11eb-36d9-c1ecb3c9e744
y = foo("bar");

# ╔═╡ 03cd7d76-9e19-11eb-1ea0-81ce1e83b834
y

# ╔═╡ 03cd7da8-9e19-11eb-0faa-9b1a947644d6
md"""
So, we see that in the body of the generated function, `x` is the *type* of the passed argument, and the value returned by the generated function, is the result of evaluating the quoted expression we returned from the definition, now with the *value* of `x`.
"""

# ╔═╡ 03cd7dbc-9e19-11eb-147e-7bd238ae25a8
md"""
What happens if we evaluate `foo` again with a type that we have already used?
"""

# ╔═╡ 03cd7ea2-9e19-11eb-16b2-f7fb8b1a3030
foo(4)

# ╔═╡ 03cd7ebe-9e19-11eb-3f7c-97b90ea7db66
md"""
Note that there is no printout of [`Int64`](@ref). We can see that the body of the generated function was only executed once here, for the specific set of argument types, and the result was cached. After that, for this example, the expression returned from the generated function on the first invocation was re-used as the method body. However, the actual caching behavior is an implementation-defined performance optimization, so it is invalid to depend too closely on this behavior.
"""

# ╔═╡ 03cd7efc-9e19-11eb-03e0-9d3ad1fe1a8c
md"""
The number of times a generated function is generated *might* be only once, but it *might* also be more often, or appear to not happen at all. As a consequence, you should *never* write a generated function with side effects - when, and how often, the side effects occur is undefined. (This is true for macros too - and just like for macros, the use of [`eval`](@ref) in a generated function is a sign that you're doing something the wrong way.) However, unlike macros, the runtime system cannot correctly handle a call to [`eval`](@ref), so it is disallowed.
"""

# ╔═╡ 03cd7f1a-9e19-11eb-361c-553b080a252f
md"""
It is also important to see how `@generated` functions interact with method redefinition. Following the principle that a correct `@generated` function must not observe any mutable state or cause any mutation of global state, we see the following behavior. Observe that the generated function *cannot* call any method that was not defined prior to the *definition* of the generated function itself.
"""

# ╔═╡ 03cd7f2e-9e19-11eb-123e-713a436d24e0
md"""
Initially `f(x)` has one definition
"""

# ╔═╡ 03cd80a0-9e19-11eb-03e6-3b1c4865ad17
f(x) = "original definition";

# ╔═╡ 03cd80be-9e19-11eb-1ef9-5315c181dae0
md"""
Define other operations that use `f(x)`:
"""

# ╔═╡ 03cd85be-9e19-11eb-023a-b1d205fd855a
g(x) = f(x);

# ╔═╡ 03cd85be-9e19-11eb-2fc9-b3b345257105
@generated gen1(x) = f(x);

# ╔═╡ 03cd85d2-9e19-11eb-2307-13adacf8340f
@generated gen2(x) = :(f(x));

# ╔═╡ 03cd85f0-9e19-11eb-0b44-2728ae796d70
md"""
We now add some new definitions for `f(x)`:
"""

# ╔═╡ 03cd8992-9e19-11eb-029e-130184bd93e8
f(x::Int) = "definition for Int";

# ╔═╡ 03cd89a6-9e19-11eb-0164-075c1ab96b38
f(x::Type{Int}) = "definition for Type{Int}";

# ╔═╡ 03cd89ba-9e19-11eb-090a-6b03001c732a
md"""
and compare how these results differ:
"""

# ╔═╡ 03cd8cd0-9e19-11eb-08f7-7ddd7842e5f2
f(1)

# ╔═╡ 03cd8cda-9e19-11eb-1e1b-658f1a3f7de4
g(1)

# ╔═╡ 03cd8cda-9e19-11eb-136b-535a0eb92050
gen1(1)

# ╔═╡ 03cd8ce4-9e19-11eb-26ad-17270398a659
gen2(1)

# ╔═╡ 03cd8cf8-9e19-11eb-3db8-43b3db69cdfd
md"""
Each method of a generated function has its own view of defined functions:
"""

# ╔═╡ 03cd9022-9e19-11eb-1471-694b2d5ba5ef
@generated gen1(x::Real) = f(x);

# ╔═╡ 03cd9022-9e19-11eb-3942-a161757ec5ab
gen1(1)

# ╔═╡ 03cd904a-9e19-11eb-3576-e552feea282b
md"""
The example generated function `foo` above did not do anything a normal function `foo(x) = x * x` could not do (except printing the type on the first invocation, and incurring higher overhead). However, the power of a generated function lies in its ability to compute different quoted expressions depending on the types passed to it:
"""

# ╔═╡ 03cd96da-9e19-11eb-2b93-c3268ad77882
@generated function bar(x)
           if x <: Integer
               return :(x ^ 2)
           else
               return :(x)
           end
       end

# ╔═╡ 03cd96e6-9e19-11eb-1a60-734ee5665157
bar(4)

# ╔═╡ 03cd96e6-9e19-11eb-32d0-fbe0ce8931f1
bar("baz")

# ╔═╡ 03cd96f8-9e19-11eb-3692-510832d7ed7d
md"""
(although of course this contrived example would be more easily implemented using multiple dispatch...)
"""

# ╔═╡ 03cd9720-9e19-11eb-2e26-c36bd829f007
md"""
Abusing this will corrupt the runtime system and cause undefined behavior:
"""

# ╔═╡ 03cd9c70-9e19-11eb-342c-778b54deae57
@generated function baz(x)
           if rand() < .9
               return :(x^2)
           else
               return :("boo!")
           end
       end

# ╔═╡ 03cd9c8e-9e19-11eb-3eb0-979aae68ddad
md"""
Since the body of the generated function is non-deterministic, its behavior, *and the behavior of all subsequent code* is undefined.
"""

# ╔═╡ 03cd9cb4-9e19-11eb-39d8-a94c4b55eae7
md"""
*Don't copy these examples!*
"""

# ╔═╡ 03cd9cca-9e19-11eb-378d-79f4d7d98cfd
md"""
These examples are hopefully helpful to illustrate how generated functions work, both in the definition end and at the call site; however, *don't copy them*, for the following reasons:
"""

# ╔═╡ 03cd9d6a-9e19-11eb-3b35-055a0345219e
md"""
  * the `foo` function has side-effects (the call to `Core.println`), and it is undefined exactly when, how often or how many times these side-effects will occur
  * the `bar` function solves a problem that is better solved with multiple dispatch - defining `bar(x) = x` and `bar(x::Integer) = x ^ 2` will do the same thing, but it is both simpler and faster.
  * the `baz` function is pathological
"""

# ╔═╡ 03cd9d74-9e19-11eb-17c1-73c7971c459a
md"""
Note that the set of operations that should not be attempted in a generated function is unbounded, and the runtime system can currently only detect a subset of the invalid operations. There are many other operations that will simply corrupt the runtime system without notification, usually in subtle ways not obviously connected to the bad definition. Because the function generator is run during inference, it must respect all of the limitations of that code.
"""

# ╔═╡ 03cd9d92-9e19-11eb-0d56-75795090094a
md"""
Some operations that should not be attempted include:
"""

# ╔═╡ 03cd9ea0-9e19-11eb-2d37-b52adc690419
md"""
1. Caching of native pointers.
2. Interacting with the contents or methods of `Core.Compiler` in any way.
3. Observing any mutable state.

      * Inference on the generated function may be run at *any* time, including while your code is attempting to observe or mutate this state.
4. Taking any locks: C code you call out to may use locks internally, (for example, it is not problematic to call `malloc`, even though most implementations require locks internally) but don't attempt to hold or acquire any while executing Julia code.
5. Calling any function that is defined after the body of the generated function. This condition is relaxed for incrementally-loaded precompiled modules to allow calling any function in the module.
"""

# ╔═╡ 03cd9eb4-9e19-11eb-1146-1beb5bd7da4f
md"""
Alright, now that we have a better understanding of how generated functions work, let's use them to build some more advanced (and valid) functionality...
"""

# ╔═╡ 03cd9ee6-9e19-11eb-2f27-038cfb454e36
md"""
### An advanced example
"""

# ╔═╡ 03cd9f18-9e19-11eb-2cf2-a14db1bebe09
md"""
Julia's base library has an internal `sub2ind` function to calculate a linear index into an n-dimensional array, based on a set of n multilinear indices - in other words, to calculate the index `i` that can be used to index into an array `A` using `A[i]`, instead of `A[x,y,z,...]`. One possible implementation is the following:
"""

# ╔═╡ 03cdaa4e-9e19-11eb-3020-35b27062d54b
function sub2ind_loop(dims::NTuple{N}, I::Integer...) where N
           ind = I[N] - 1
           for i = N-1:-1:1
               ind = I[i]-1 + dims[i]*ind
           end
           return ind + 1
       end

# ╔═╡ 03cdaa58-9e19-11eb-0333-2588358a6e86
sub2ind_loop((3, 5), 1, 2)

# ╔═╡ 03cdaa80-9e19-11eb-1d85-035e6c4a5d59
md"""
The same thing can be done using recursion:
"""

# ╔═╡ 03cdbbd8-9e19-11eb-0666-fb5e87b8d609
sub2ind_rec(dims::Tuple{}) = 1;

# ╔═╡ 03cdbbe4-9e19-11eb-1574-5514673c271e
sub2ind_rec(dims::Tuple{}, i1::Integer, I::Integer...) =
           i1 == 1 ? sub2ind_rec(dims, I...) : throw(BoundsError());

# ╔═╡ 03cdbbe4-9e19-11eb-38d0-cfa03f1106af
sub2ind_rec(dims::Tuple{Integer, Vararg{Integer}}, i1::Integer) = i1;

# ╔═╡ 03cdbbf6-9e19-11eb-2194-91a0d5fb4161
sub2ind_rec(dims::Tuple{Integer, Vararg{Integer}}, i1::Integer, I::Integer...) =
           i1 + dims[1] * (sub2ind_rec(Base.tail(dims), I...) - 1);

# ╔═╡ 03cdbbf6-9e19-11eb-0242-5b7537e9f33e
sub2ind_rec((3, 5), 1, 2)

# ╔═╡ 03cdbc0a-9e19-11eb-0cf1-791b85bbe556
md"""
Both these implementations, although different, do essentially the same thing: a runtime loop over the dimensions of the array, collecting the offset in each dimension into the final index.
"""

# ╔═╡ 03cdbc32-9e19-11eb-32bd-bd1b327fd8ff
md"""
However, all the information we need for the loop is embedded in the type information of the arguments. Thus, we can utilize generated functions to move the iteration to compile-time; in compiler parlance, we use generated functions to manually unroll the loop. The body becomes almost identical, but instead of calculating the linear index, we build up an *expression* that calculates the index:
"""

# ╔═╡ 03cdc9ca-9e19-11eb-3785-018d13c592e3
@generated function sub2ind_gen(dims::NTuple{N}, I::Integer...) where N
           ex = :(I[$N] - 1)
           for i = (N - 1):-1:1
               ex = :(I[$i] - 1 + dims[$i] * $ex)
           end
           return :($ex + 1)
       end

# ╔═╡ 03cdc9d4-9e19-11eb-0844-4d9ea3c86d28
sub2ind_gen((3, 5), 1, 2)

# ╔═╡ 03cdc9f0-9e19-11eb-25f1-792296e70efd
md"""
**What code will this generate?**
"""

# ╔═╡ 03cdca06-9e19-11eb-1634-652296e6ffc6
md"""
An easy way to find out is to extract the body into another (regular) function:
"""

# ╔═╡ 03cddcc6-9e19-11eb-0af2-03d258b37911
@generated function sub2ind_gen(dims::NTuple{N}, I::Integer...) where N
           return sub2ind_gen_impl(dims, I...)
       end

# ╔═╡ 03cddcc6-9e19-11eb-0dfc-5981f9b4e4ab
function sub2ind_gen_impl(dims::Type{T}, I...) where T <: NTuple{N,Any} where N
           length(I) == N || return :(error("partial indexing is unsupported"))
           ex = :(I[$N] - 1)
           for i = (N - 1):-1:1
               ex = :(I[$i] - 1 + dims[$i] * $ex)
           end
           return :($ex + 1)
       end

# ╔═╡ 03cddce4-9e19-11eb-31af-692efced2caa
md"""
We can now execute `sub2ind_gen_impl` and examine the expression it returns:
"""

# ╔═╡ 03cdde6a-9e19-11eb-016c-4b712612f349
sub2ind_gen_impl(Tuple{Int,Int}, Int, Int)

# ╔═╡ 03cddeba-9e19-11eb-2743-61f0946f53e2
md"""
So, the method body that will be used here doesn't include a loop at all - just indexing into the two tuples, multiplication and addition/subtraction. All the looping is performed compile-time, and we avoid looping during execution entirely. Thus, we only loop *once per type*, in this case once per `N` (except in edge cases where the function is generated more than once - see disclaimer above).
"""

# ╔═╡ 03cddece-9e19-11eb-2cc1-594f553e2e86
md"""
### Optionally-generated functions
"""

# ╔═╡ 03cddee2-9e19-11eb-2571-599fb08a2b78
md"""
Generated functions can achieve high efficiency at run time, but come with a compile time cost: a new function body must be generated for every combination of concrete argument types. Typically, Julia is able to compile "generic" versions of functions that will work for any arguments, but with generated functions this is impossible. This means that programs making heavy use of generated functions might be impossible to statically compile.
"""

# ╔═╡ 03cddf00-9e19-11eb-2f9a-c71a2e8e6c3c
md"""
To solve this problem, the language provides syntax for writing normal, non-generated alternative implementations of generated functions. Applied to the `sub2ind` example above, it would look like this:
"""

# ╔═╡ 03cddf1e-9e19-11eb-0020-5f2c71987728
md"""
```julia
function sub2ind_gen(dims::NTuple{N}, I::Integer...) where N
    if N != length(I)
        throw(ArgumentError("Number of dimensions must match number of indices."))
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

# ╔═╡ 03cddf48-9e19-11eb-3f64-91f9e18374ed
md"""
Internally, this code creates two implementations of the function: a generated one where the first block in `if @generated` is used, and a normal one where the `else` block is used. Inside the `then` part of the `if @generated` block, code has the same semantics as other generated functions: argument names refer to types, and the code should return an expression. Multiple `if @generated` blocks may occur, in which case the generated implementation uses all of the `then` blocks and the alternate implementation uses all of the `else` blocks.
"""

# ╔═╡ 03cddf64-9e19-11eb-2f6e-913953039646
md"""
Notice that we added an error check to the top of the function. This code will be common to both versions, and is run-time code in both versions (it will be quoted and returned as an expression from the generated version). That means that the values and types of local variables are not available at code generation time –- the code-generation code can only see the types of arguments.
"""

# ╔═╡ 03cddf82-9e19-11eb-0585-81be59ad06cc
md"""
In this style of definition, the code generation feature is essentially an optional optimization. The compiler will use it if convenient, but otherwise may choose to use the normal implementation instead. This style is preferred, since it allows the compiler to make more decisions and compile programs in more ways, and since normal code is more readable than code-generating code. However, which implementation is used depends on compiler implementation details, so it is essential for the two implementations to behave identically.
"""

# ╔═╡ Cell order:
# ╟─03cc7e80-9e19-11eb-179f-4bf4a585b92d
# ╟─03cc7f20-9e19-11eb-30cd-37f12222466e
# ╟─03cc7f52-9e19-11eb-1dd7-513c3b81eaa4
# ╟─03cc7f66-9e19-11eb-1740-ad59d009c55e
# ╠═03cc8290-9e19-11eb-362a-9b0d830d3d49
# ╟─03cc8308-9e19-11eb-0262-fb641b7b9eb1
# ╟─03cc833a-9e19-11eb-2b63-e586aa13ce0a
# ╠═03cc85d8-9e19-11eb-013e-a9313c0e9c28
# ╠═03cc85e4-9e19-11eb-1b3d-af4a02cad3e8
# ╟─03cc85f6-9e19-11eb-3b26-1b26dc0d2ca1
# ╟─03cc86c8-9e19-11eb-2505-4b7a1b7c87a5
# ╠═03cc8786-9e19-11eb-1b3d-f56f5722f522
# ╟─03cc87b8-9e19-11eb-1efe-210c0c70032c
# ╠═03cc8862-9e19-11eb-30fb-b5a96714d4c4
# ╟─03cc8882-9e19-11eb-1029-2d678baac0ec
# ╠═03cc8b5a-9e19-11eb-29bc-55a2209ccbbe
# ╟─03cc8b6e-9e19-11eb-18bf-176fb3b2b960
# ╠═03cc8c68-9e19-11eb-2142-5b1451dc2cb6
# ╟─03cc8c7c-9e19-11eb-1b83-2d04c94fbead
# ╟─03cc8ca4-9e19-11eb-11d0-116ce78bca37
# ╠═03cc8d7e-9e19-11eb-334b-cb583b903a7f
# ╟─03cc8d94-9e19-11eb-3359-4f4ff083227d
# ╠═03cc8f58-9e19-11eb-037e-e77ee52b29d3
# ╟─03cc8f8a-9e19-11eb-3e40-97cde36a12f8
# ╠═03cc9078-9e19-11eb-1dd6-653d66742c97
# ╟─03cc90aa-9e19-11eb-0b50-11402012df26
# ╟─03cc90dc-9e19-11eb-222d-6d6786a046c4
# ╠═03cc9280-9e19-11eb-0a8c-a5ec8724ae99
# ╠═03cc9294-9e19-11eb-0855-d1046682db04
# ╟─03cc92b2-9e19-11eb-23d4-7367606e446c
# ╠═03cc974e-9e19-11eb-2dfb-b309e6fb7d62
# ╠═03cc974e-9e19-11eb-2ee0-e398f358f471
# ╠═03cc9758-9e19-11eb-2e6c-01bd71a4fb65
# ╟─03cc9776-9e19-11eb-3dab-f3e90c71561b
# ╟─03cc9796-9e19-11eb-11e2-6d091d253787
# ╟─03cc97a8-9e19-11eb-0ecd-133988a3fbaa
# ╠═03cc994c-9e19-11eb-39cc-2d548ab9e6d3
# ╠═03cc9956-9e19-11eb-109f-19bf82e3f0fd
# ╟─03cc996a-9e19-11eb-10f4-db43ee899d80
# ╟─03cc997e-9e19-11eb-286b-ed82be0c4860
# ╟─03cc99ba-9e19-11eb-33a3-8313aaf4a112
# ╠═03cc9d3e-9e19-11eb-33a3-010163562a0e
# ╠═03cc9d48-9e19-11eb-0f58-b97411cb21fc
# ╟─03cc9d70-9e19-11eb-055f-21c10b36f8b1
# ╟─03cc9d8e-9e19-11eb-3685-717dc6950e96
# ╠═03cca432-9e19-11eb-1c03-65675fd183e5
# ╟─03cca450-9e19-11eb-30e2-3768a34ba9a6
# ╟─03cca464-9e19-11eb-2455-f73cf5be85af
# ╠═03cca876-9e19-11eb-057d-8b9aca075210
# ╠═03cca888-9e19-11eb-046b-65202c3d4387
# ╟─03cca8b0-9e19-11eb-016d-55fff28477db
# ╟─03cca8d6-9e19-11eb-0192-5d94215d92bb
# ╟─03cca8ec-9e19-11eb-37f9-819135641e61
# ╠═03ccab80-9e19-11eb-2908-3fa9398228f4
# ╠═03ccab8a-9e19-11eb-0385-3bf11c0e6864
# ╟─03ccab9e-9e19-11eb-11b9-7d3652c91b5e
# ╠═03ccac5c-9e19-11eb-0e1a-cbb84bb5ca2d
# ╟─03ccac70-9e19-11eb-2c65-f5b41f747aad
# ╠═03ccaf22-9e19-11eb-2d7a-21f270336afe
# ╟─03ccaf4c-9e19-11eb-03c8-d3b7bab13e04
# ╟─03ccaf5e-9e19-11eb-3bb6-afc472ce01bd
# ╟─03ccaf7a-9e19-11eb-2f58-e753935b3d23
# ╠═03ccb3be-9e19-11eb-02da-0b34d9945e9f
# ╠═03ccb3c8-9e19-11eb-30bb-bb3e51d6e4ad
# ╟─03ccb3d2-9e19-11eb-2c96-ed6de4dd9726
# ╟─03ccb3e4-9e19-11eb-3c25-75ed05e6a369
# ╠═03ccb76a-9e19-11eb-3541-cf00a007bb5b
# ╠═03ccb774-9e19-11eb-17e1-b191b67a42f7
# ╟─03ccb792-9e19-11eb-07d5-f3000d83796a
# ╠═03ccb850-9e19-11eb-2fea-858b5c245cd2
# ╟─03ccb86e-9e19-11eb-29d7-dba331ff8ec6
# ╠═03ccba12-9e19-11eb-30a1-bb1784975ebf
# ╟─03ccba30-9e19-11eb-2007-2dfbe805f936
# ╠═03ccbaee-9e19-11eb-10b5-01396515c779
# ╟─03ccbb16-9e19-11eb-35f2-5f87813b7187
# ╟─03ccbb34-9e19-11eb-01da-af38e0d1a01b
# ╟─03ccbb5e-9e19-11eb-3331-a95901ab947d
# ╠═03ccbd0a-9e19-11eb-3f90-25127c484cc2
# ╟─03ccbd26-9e19-11eb-1c23-517b810e884d
# ╠═03ccc372-9e19-11eb-2d5d-d9aea687e402
# ╠═03ccc372-9e19-11eb-2dfb-9d6632bcf40e
# ╟─03ccc390-9e19-11eb-1c75-550e98e9e81b
# ╠═03ccc516-9e19-11eb-0cf5-cf71cdc5f92c
# ╟─03ccc536-9e19-11eb-2c1c-859efe77d900
# ╟─03ccc53e-9e19-11eb-29e0-13dfcc440b77
# ╟─03ccc55c-9e19-11eb-1864-4939bec3d292
# ╠═03cccc28-9e19-11eb-2986-514455cb26ac
# ╠═03cccc28-9e19-11eb-3adf-afb11a2f1125
# ╠═03cccc32-9e19-11eb-1cc5-5d318e79d216
# ╠═03cccc32-9e19-11eb-12f1-094dd8915f0a
# ╠═03cccc32-9e19-11eb-24dd-bfee09c6901f
# ╠═03cccc3a-9e19-11eb-3330-cbe48f1d19dd
# ╟─03cccc6c-9e19-11eb-12a5-e96b8266f720
# ╠═03cccf66-9e19-11eb-3ea9-fda557016d9e
# ╠═03cccf70-9e19-11eb-00ae-8365a033ff85
# ╠═03cccf70-9e19-11eb-0a82-434aeed9c11e
# ╠═03cccf7a-9e19-11eb-154b-819289c3b1a0
# ╟─03cccf8e-9e19-11eb-368f-afa085b49d7e
# ╟─03cccfac-9e19-11eb-19f5-c11b0a07e232
# ╠═03ccd5a6-9e19-11eb-35df-5b33bd1d5480
# ╠═03ccd5b2-9e19-11eb-38cd-6b23f6980e99
# ╠═03ccd5b2-9e19-11eb-39bb-6d72a67f2aac
# ╠═03ccd5e0-9e19-11eb-26df-2d5bb58e462b
# ╟─03ccd60a-9e19-11eb-05fe-7d9b2d4f9675
# ╟─03ccd6d2-9e19-11eb-2edf-8774cbf35a67
# ╟─03ccd6e8-9e19-11eb-0791-1587d247ded6
# ╟─03ccd71a-9e19-11eb-30b5-7f1c69e82504
# ╠═03ccde70-9e19-11eb-333c-1380492abf02
# ╠═03ccde7a-9e19-11eb-16fc-5141099c84c3
# ╠═03ccde7a-9e19-11eb-3f1d-af4c79b9d3e0
# ╟─03ccde8e-9e19-11eb-3432-0112b47ba011
# ╠═03cceb54-9e19-11eb-1394-414aa1085038
# ╠═03cceb54-9e19-11eb-31af-534946ccbede
# ╠═03cceb5e-9e19-11eb-17be-7b015f9a0aad
# ╠═03cceb5e-9e19-11eb-0e4a-41d8e095a5f7
# ╟─03cceb7c-9e19-11eb-0ae8-35a2a64cffdd
# ╟─03cceba4-9e19-11eb-19eb-273c2affc523
# ╟─03ccebb8-9e19-11eb-1f80-4f94141a1c85
# ╟─03ccebc2-9e19-11eb-0c94-a397af331728
# ╠═03ccee74-9e19-11eb-1945-95f6f63a1a0d
# ╟─03ccee92-9e19-11eb-2d8e-7dd375b5844b
# ╟─03cceed8-9e19-11eb-23ee-a739d187f47c
# ╟─03cceeec-9e19-11eb-38bf-bf538b40cf80
# ╠═03cceff0-9e19-11eb-2f3d-75794ca16d99
# ╟─03ccf002-9e19-11eb-225f-654c7768d3da
# ╠═03ccf310-9e19-11eb-12cc-6f0af8330b87
# ╟─03ccf338-9e19-11eb-2e71-ed66ee8fe74c
# ╠═03ccf464-9e19-11eb-2290-79db30f6786e
# ╟─03ccf48c-9e19-11eb-2c27-43ddb72044e9
# ╠═03ccf798-9e19-11eb-2b04-97090ef5ca7f
# ╠═03ccf7a2-9e19-11eb-3630-8bffd2de56eb
# ╟─03ccf7b6-9e19-11eb-2f8d-65356683f234
# ╟─03ccf7d4-9e19-11eb-10e6-37a1106d0f53
# ╠═03ccf976-9e19-11eb-32eb-0b2dbfcef976
# ╟─03ccf98c-9e19-11eb-0936-3350ac6cd80c
# ╟─03ccf9b4-9e19-11eb-1ba1-9589e0cf53fa
# ╟─03ccf9d2-9e19-11eb-13cc-9919fe37defa
# ╠═03cd04cc-9e19-11eb-1804-35111aacacdf
# ╠═03cd04d6-9e19-11eb-164c-5d54409cb170
# ╟─03cd0544-9e19-11eb-0003-61d9e75b047c
# ╠═03cd082a-9e19-11eb-0996-d100725d1875
# ╠═03cd0832-9e19-11eb-3f44-1799723e0feb
# ╠═03cd083c-9e19-11eb-22df-7b6e742b6db5
# ╟─03cd086e-9e19-11eb-2766-0deeedd1fadd
# ╟─03cd088a-9e19-11eb-300e-374026c4fefe
# ╟─03cd08c8-9e19-11eb-238b-ff462de26d67
# ╟─03cd08fa-9e19-11eb-12ab-bf42ee18dd8e
# ╟─03cd092c-9e19-11eb-3ea9-eb2012a248b5
# ╟─03cd094a-9e19-11eb-2071-5dbc5e4137d6
# ╟─03cd0960-9e19-11eb-3f00-8956e48e52fa
# ╟─03cd097c-9e19-11eb-2c7f-6b5de3b9e63d
# ╠═03cd111a-9e19-11eb-19c7-250bdec48f75
# ╠═03cd1124-9e19-11eb-1954-19d86d9b6b27
# ╠═03cd1124-9e19-11eb-2bbe-89fd8b3a8137
# ╠═03cd112c-9e19-11eb-2c61-af7b463556f5
# ╟─03cd114c-9e19-11eb-102e-736fc08dd38a
# ╟─03cd117e-9e19-11eb-1117-33e9dd9b9425
# ╟─03cd1192-9e19-11eb-3edb-a910fc1d7452
# ╠═03cd14bc-9e19-11eb-0372-612840e525b3
# ╠═03cd14bc-9e19-11eb-3b07-83e99c23ef2c
# ╟─03cd14e4-9e19-11eb-1657-9dc520b2eb24
# ╟─03cd14ee-9e19-11eb-3d3c-e70ee9a8eb0f
# ╟─03cd150c-9e19-11eb-015f-c58895a933b4
# ╠═03cd1962-9e19-11eb-09c2-4b2e2c520fd9
# ╟─03cd1976-9e19-11eb-1d27-5319f043cbb9
# ╠═03cd1d2c-9e19-11eb-0ee5-0bd7971e49f4
# ╠═03cd1d36-9e19-11eb-241e-c99277f46dff
# ╟─03cd1d3e-9e19-11eb-0e38-f5208ede4834
# ╟─03cd1d5e-9e19-11eb-2ff5-492d1297c666
# ╟─03cd1dae-9e19-11eb-1998-5f59254b419b
# ╟─03cd1dcc-9e19-11eb-0897-69267a4e91aa
# ╠═03cd252e-9e19-11eb-379f-3d1c591b71c9
# ╟─03cd2556-9e19-11eb-223f-b94d9bbabbb2
# ╠═03cd2966-9e19-11eb-1e86-776ce6f153e6
# ╠═03cd298e-9e19-11eb-03fd-df5810e073ca
# ╟─03cd29ca-9e19-11eb-3ca2-9bf6d26443f2
# ╠═03cd2efc-9e19-11eb-28c5-adc1a1c28857
# ╠═03cd2f06-9e19-11eb-2284-01970bd6f89c
# ╠═03cd2f06-9e19-11eb-3d50-cb870973357e
# ╟─03cd2f38-9e19-11eb-0a47-87949f8fac64
# ╟─03cd2f4c-9e19-11eb-2cac-a320b068500a
# ╟─03cd2f54-9e19-11eb-1057-fd3f9ff01526
# ╟─03cd2f92-9e19-11eb-2611-d78f6dfd0ef0
# ╟─03cd2fb0-9e19-11eb-21a2-ad8cd5f1c24c
# ╟─03cd2fc6-9e19-11eb-0cc0-8507a919de57
# ╟─03cd2ff8-9e19-11eb-3045-9b82c9f545e0
# ╟─03cd3014-9e19-11eb-10d4-ab0ebf868004
# ╟─03cd302a-9e19-11eb-1178-5d4cee34fb76
# ╟─03cd303c-9e19-11eb-2aef-e5083493744e
# ╟─03cd3064-9e19-11eb-04f5-bfeceb2c090d
# ╟─03cd3078-9e19-11eb-0a37-2d3e9b26778e
# ╟─03cd3082-9e19-11eb-2177-bd230958128d
# ╟─03cd3096-9e19-11eb-1ad8-df02c4524dd6
# ╠═03cd3758-9e19-11eb-1978-8f5da64fb0fd
# ╠═03cd3758-9e19-11eb-0cb7-85fb9544704d
# ╠═03cd3758-9e19-11eb-3795-add5873ba185
# ╟─03cd376c-9e19-11eb-087e-252737934fe2
# ╟─03cd37bc-9e19-11eb-2e23-f5c48c1923de
# ╟─03cd37d0-9e19-11eb-26d5-3b31299ce41a
# ╟─03cd37e4-9e19-11eb-2f5d-2986c1cc897c
# ╟─03cd3804-9e19-11eb-35e1-d972a3033c7c
# ╟─03cd3816-9e19-11eb-29c3-5d60527c3080
# ╟─03cd3836-9e19-11eb-3d76-17a83f805bf9
# ╠═03cd5efc-9e19-11eb-0361-2bb923f7d651
# ╠═03cd5efc-9e19-11eb-260d-ad649cc3d0f6
# ╠═03cd5f08-9e19-11eb-3a05-2bae1d41bdbf
# ╠═03cd5f26-9e19-11eb-33f0-ab86b0452a39
# ╠═03cd5f26-9e19-11eb-3371-533de75e86f4
# ╟─03cd5f44-9e19-11eb-0291-e36ef6f0c1ac
# ╠═03cd6494-9e19-11eb-34c5-b76597de6b50
# ╠═03cd649c-9e19-11eb-17b3-c506e0bfc5c8
# ╠═03cd64a8-9e19-11eb-3ffb-8fd614361680
# ╠═03cd64b2-9e19-11eb-180c-83fb2840585d
# ╟─03cd64e4-9e19-11eb-0d2f-b79fddeacc32
# ╟─03cd650c-9e19-11eb-240f-9d095ea97341
# ╠═03cd6692-9e19-11eb-339e-8936dbb46f64
# ╟─03cd66a8-9e19-11eb-29c1-41074cb152f1
# ╠═03cd6d36-9e19-11eb-189a-cd4267f22c06
# ╟─03cd6d4a-9e19-11eb-1361-edd3dfee5ac6
# ╠═03cd6fb6-9e19-11eb-1611-d1526c1a0442
# ╠═03cd6fb6-9e19-11eb-1f0d-97fcfc2fabca
# ╠═03cd6fc0-9e19-11eb-2f23-57862f4fe2a2
# ╟─03cd6fdc-9e19-11eb-0274-e158f47fd303
# ╟─03cd7010-9e19-11eb-3ba0-ab6a43ae57d7
# ╟─03cd7024-9e19-11eb-0d1b-e7ac325614dd
# ╟─03cd7038-9e19-11eb-2cd0-6bf82a4bb248
# ╟─03cd706a-9e19-11eb-1d04-b58b999d87d2
# ╟─03cd7080-9e19-11eb-3ee3-9b0ddd7a7833
# ╟─03cd7092-9e19-11eb-3f0e-2f44b01fc874
# ╟─03cd70b2-9e19-11eb-253a-45674db2f5d2
# ╟─03cd7150-9e19-11eb-2893-af8f7072e143
# ╟─03cd7164-9e19-11eb-0598-8b30c99f6d7b
# ╟─03cd7178-9e19-11eb-0c7b-1f4637155c18
# ╟─03cd71aa-9e19-11eb-394f-2f008904bfce
# ╟─03cd71b6-9e19-11eb-2060-d9ab741af14e
# ╟─03cd71d2-9e19-11eb-315e-35ec80e8c140
# ╟─03cd71f0-9e19-11eb-0091-d581a3f38933
# ╟─03cd7204-9e19-11eb-3f42-6febfe74ee83
# ╟─03cd721a-9e19-11eb-1356-43be64345a28
# ╟─03cd7236-9e19-11eb-1c5a-75fc976a2a01
# ╟─03cd729a-9e19-11eb-0534-e5e73f6f80d9
# ╟─03cd72b8-9e19-11eb-2843-0757fb2ef607
# ╟─03cd72e0-9e19-11eb-3c56-490dff5bde04
# ╟─03cd72f4-9e19-11eb-2b9e-7f54e71e9825
# ╟─03cd7308-9e19-11eb-1d30-699d03105cae
# ╟─03cd7326-9e19-11eb-1891-71b406f75d19
# ╟─03cd733a-9e19-11eb-21da-31e76b3652f2
# ╟─03cd7350-9e19-11eb-2af5-1d12b98c2350
# ╟─03cd7358-9e19-11eb-3239-f346edb51e43
# ╟─03cd7376-9e19-11eb-3556-0b7ea7f1fd2c
# ╟─03cd737e-9e19-11eb-177e-efe2c0b96563
# ╟─03cd73b0-9e19-11eb-2586-b926d0958e22
# ╟─03cd73d0-9e19-11eb-1788-676d2701e496
# ╟─03cd73e2-9e19-11eb-1a21-d3b456a9a478
# ╟─03cd7542-9e19-11eb-36bc-89add66424f3
# ╟─03cd7560-9e19-11eb-205e-f9812cd742fb
# ╠═03cd7902-9e19-11eb-332f-0d20ccde8141
# ╟─03cd791e-9e19-11eb-0a8f-25daf9c263ca
# ╟─03cd7950-9e19-11eb-1774-99ebc58eb7dc
# ╠═03cd7d62-9e19-11eb-2faf-ed964fbd22cc
# ╠═03cd7d6c-9e19-11eb-3bdf-cb50304b4d42
# ╠═03cd7d6c-9e19-11eb-36d9-c1ecb3c9e744
# ╠═03cd7d76-9e19-11eb-1ea0-81ce1e83b834
# ╟─03cd7da8-9e19-11eb-0faa-9b1a947644d6
# ╟─03cd7dbc-9e19-11eb-147e-7bd238ae25a8
# ╠═03cd7ea2-9e19-11eb-16b2-f7fb8b1a3030
# ╟─03cd7ebe-9e19-11eb-3f7c-97b90ea7db66
# ╟─03cd7efc-9e19-11eb-03e0-9d3ad1fe1a8c
# ╟─03cd7f1a-9e19-11eb-361c-553b080a252f
# ╟─03cd7f2e-9e19-11eb-123e-713a436d24e0
# ╠═03cd80a0-9e19-11eb-03e6-3b1c4865ad17
# ╟─03cd80be-9e19-11eb-1ef9-5315c181dae0
# ╠═03cd85be-9e19-11eb-023a-b1d205fd855a
# ╠═03cd85be-9e19-11eb-2fc9-b3b345257105
# ╠═03cd85d2-9e19-11eb-2307-13adacf8340f
# ╟─03cd85f0-9e19-11eb-0b44-2728ae796d70
# ╠═03cd8992-9e19-11eb-029e-130184bd93e8
# ╠═03cd89a6-9e19-11eb-0164-075c1ab96b38
# ╟─03cd89ba-9e19-11eb-090a-6b03001c732a
# ╠═03cd8cd0-9e19-11eb-08f7-7ddd7842e5f2
# ╠═03cd8cda-9e19-11eb-1e1b-658f1a3f7de4
# ╠═03cd8cda-9e19-11eb-136b-535a0eb92050
# ╠═03cd8ce4-9e19-11eb-26ad-17270398a659
# ╟─03cd8cf8-9e19-11eb-3db8-43b3db69cdfd
# ╠═03cd9022-9e19-11eb-1471-694b2d5ba5ef
# ╠═03cd9022-9e19-11eb-3942-a161757ec5ab
# ╟─03cd904a-9e19-11eb-3576-e552feea282b
# ╠═03cd96da-9e19-11eb-2b93-c3268ad77882
# ╠═03cd96e6-9e19-11eb-1a60-734ee5665157
# ╠═03cd96e6-9e19-11eb-32d0-fbe0ce8931f1
# ╟─03cd96f8-9e19-11eb-3692-510832d7ed7d
# ╟─03cd9720-9e19-11eb-2e26-c36bd829f007
# ╠═03cd9c70-9e19-11eb-342c-778b54deae57
# ╟─03cd9c8e-9e19-11eb-3eb0-979aae68ddad
# ╟─03cd9cb4-9e19-11eb-39d8-a94c4b55eae7
# ╟─03cd9cca-9e19-11eb-378d-79f4d7d98cfd
# ╟─03cd9d6a-9e19-11eb-3b35-055a0345219e
# ╟─03cd9d74-9e19-11eb-17c1-73c7971c459a
# ╟─03cd9d92-9e19-11eb-0d56-75795090094a
# ╟─03cd9ea0-9e19-11eb-2d37-b52adc690419
# ╟─03cd9eb4-9e19-11eb-1146-1beb5bd7da4f
# ╟─03cd9ee6-9e19-11eb-2f27-038cfb454e36
# ╟─03cd9f18-9e19-11eb-2cf2-a14db1bebe09
# ╠═03cdaa4e-9e19-11eb-3020-35b27062d54b
# ╠═03cdaa58-9e19-11eb-0333-2588358a6e86
# ╟─03cdaa80-9e19-11eb-1d85-035e6c4a5d59
# ╠═03cdbbd8-9e19-11eb-0666-fb5e87b8d609
# ╠═03cdbbe4-9e19-11eb-1574-5514673c271e
# ╠═03cdbbe4-9e19-11eb-38d0-cfa03f1106af
# ╠═03cdbbf6-9e19-11eb-2194-91a0d5fb4161
# ╠═03cdbbf6-9e19-11eb-0242-5b7537e9f33e
# ╟─03cdbc0a-9e19-11eb-0cf1-791b85bbe556
# ╟─03cdbc32-9e19-11eb-32bd-bd1b327fd8ff
# ╠═03cdc9ca-9e19-11eb-3785-018d13c592e3
# ╠═03cdc9d4-9e19-11eb-0844-4d9ea3c86d28
# ╟─03cdc9f0-9e19-11eb-25f1-792296e70efd
# ╟─03cdca06-9e19-11eb-1634-652296e6ffc6
# ╠═03cddcc6-9e19-11eb-0af2-03d258b37911
# ╠═03cddcc6-9e19-11eb-0dfc-5981f9b4e4ab
# ╟─03cddce4-9e19-11eb-31af-692efced2caa
# ╠═03cdde6a-9e19-11eb-016c-4b712612f349
# ╟─03cddeba-9e19-11eb-2743-61f0946f53e2
# ╟─03cddece-9e19-11eb-2cc1-594f553e2e86
# ╟─03cddee2-9e19-11eb-2571-599fb08a2b78
# ╟─03cddf00-9e19-11eb-2f9a-c71a2e8e6c3c
# ╟─03cddf1e-9e19-11eb-0020-5f2c71987728
# ╟─03cddf48-9e19-11eb-3f64-91f9e18374ed
# ╟─03cddf64-9e19-11eb-2f6e-913953039646
# ╟─03cddf82-9e19-11eb-0585-81be59ad06cc
