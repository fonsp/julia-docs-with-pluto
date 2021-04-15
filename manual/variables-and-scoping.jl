### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03dadd5e-9e19-11eb-159d-61175c932e20
md"""
# [Scope of Variables](@id scope-of-variables)
"""

# ╔═╡ 03dadd9a-9e19-11eb-3e2f-8159c76fe541
md"""
The *scope* of a variable is the region of code within which a variable is visible. Variable scoping helps avoid variable naming conflicts. The concept is intuitive: two functions can both have arguments called `x` without the two `x`'s referring to the same thing. Similarly, there are many other cases where different blocks of code can use the same name without referring to the same thing. The rules for when the same variable name does or doesn't refer to the same thing are called scope rules; this section spells them out in detail.
"""

# ╔═╡ 03daddc2-9e19-11eb-013a-c98b49725fef
md"""
Certain constructs in the language introduce *scope blocks*, which are regions of code that are eligible to be the scope of some set of variables. The scope of a variable cannot be an arbitrary set of source lines; instead, it will always line up with one of these blocks. There are two main types of scopes in Julia, *global scope* and *local scope*. The latter can be nested. There is also a distinction in Julia between constructs which introduce a "hard scope" and those which only introduce a "soft scope", which affects whether [shadowing](https://en.wikipedia.org/wiki/Variable_shadowing) a global variable by the same name is allowed or not.
"""

# ╔═╡ 03daddea-9e19-11eb-33d3-970827c4cb57
md"""
### [Scope constructs](@id man-scope-table)
"""

# ╔═╡ 03daddfe-9e19-11eb-214c-2f9c0f7b7f54
md"""
The constructs introducing scope blocks are:
"""

# ╔═╡ 03dae024-9e19-11eb-03f7-afdabdbbe09a
md"""
| Construct                                                                        | Scope type   | Allowed within |
|:-------------------------------------------------------------------------------- |:------------ |:-------------- |
| [`module`](@ref), [`baremodule`](@ref)                                           | global       | global         |
| [`struct`](@ref)                                                                 | local (soft) | global         |
| [`for`](@ref), [`while`](@ref), [`try`](@ref try)                                | local (soft) | global, local  |
| [`macro`](@ref)                                                                  | local (hard) | global         |
| functions, [`do`](@ref) blocks, [`let`](@ref) blocks, comprehensions, generators | local (hard) | global, local  |
"""

# ╔═╡ 03dae04c-9e19-11eb-2cde-efc4857179d6
md"""
Notably missing from this table are [begin blocks](@ref man-compound-expressions) and [if blocks](@ref man-conditional-evaluation) which do *not* introduce new scopes. The three types of scopes follow somewhat different rules which will be explained below.
"""

# ╔═╡ 03dae06a-9e19-11eb-1c3f-d3ade8bd944a
md"""
Julia uses [lexical scoping](https://en.wikipedia.org/wiki/Scope_%28computer_science%29#Lexical_scoping_vs._dynamic_scoping), meaning that a function's scope does not inherit from its caller's scope, but from the scope in which the function was defined. For example, in the following code the `x` inside `foo` refers to the `x` in the global scope of its module `Bar`:
"""

# ╔═╡ 03dae3f8-9e19-11eb-262b-f5f79ee52645
module Bar
           x = 1
           foo() = x
       end;

# ╔═╡ 03dae420-9e19-11eb-1cca-a36b1df9b82a
md"""
and not a `x` in the scope where `foo` is used:
"""

# ╔═╡ 03dae6c8-9e19-11eb-1644-b3420febb289
import .Bar

# ╔═╡ 03dae6dc-9e19-11eb-0804-fdbbc07d8b33
x = -1;

# ╔═╡ 03dae6e6-9e19-11eb-3add-2bae727db562
Bar.foo()

# ╔═╡ 03dae722-9e19-11eb-347c-5f11354e8be8
md"""
Thus *lexical scope* means that what a variable in a particular piece of code refers to can be deduced from the code in which it appears alone and does not depend on how the program executes. A scope nested inside another scope can "see" variables in all the outer scopes in which it is contained. Outer scopes, on the other hand, cannot see variables in inner scopes.
"""

# ╔═╡ 03dae740-9e19-11eb-05ca-0568987802a5
md"""
## Global Scope
"""

# ╔═╡ 03dae768-9e19-11eb-3467-dfcf2d8e081e
md"""
Each module introduces a new global scope, separate from the global scope of all other modules—there is no all-encompassing global scope. Modules can introduce variables of other modules into their scope through the [using or import](@ref modules) statements or through qualified access using the dot-notation, i.e. each module is a so-called *namespace* as well as a first-class data structure associating names with values. Note that while variable bindings can be read externally, they can only be changed within the module to which they belong. As an escape hatch, you can always evaluate code inside that module to modify a variable; this guarantees, in particular, that module bindings cannot be modified externally by code that never calls `eval`.
"""

# ╔═╡ 03daf21c-9e19-11eb-3691-2fc0ca402be9
module A
           a = 1 # a global in A's scope
       end;

# ╔═╡ 03daf228-9e19-11eb-027b-ab53ad5d9e78
module B
           module C
               c = 2
           end
           b = C.c    # can access the namespace of a nested global scope
                      # through a qualified access
           import ..A # makes module A available
           d = A.a
       end;

# ╔═╡ 03daf228-9e19-11eb-0f83-bb70f9f83914
module D
           b = a # errors as D's global scope is separate from A's
       end;

# ╔═╡ 03daf230-9e19-11eb-08cf-b3bbe9b947bc
module E
           import ..A # make module A available
           A.a = 2    # throws below error
       end;

# ╔═╡ 03daf25a-9e19-11eb-1f6f-733db5061b6d
md"""
Note that the interactive prompt (aka REPL) is in the global scope of the module `Main`.
"""

# ╔═╡ 03daf262-9e19-11eb-30de-67e270cc0442
md"""
## Local Scope
"""

# ╔═╡ 03daf29e-9e19-11eb-34ab-dff607328f75
md"""
A new local scope is introduced by most code blocks (see above [table](@ref man-scope-table) for a complete list). Some programming languages require explicitly declaring new variables before using them. Explicit declaration works in Julia too: in any local scope, writing `local x` declares a new local variable in that scope, regardless of whether there is already a variable named `x` in an outer scope or not. Declaring each new local like this is somewhat verbose and tedious, however, so Julia, like many other languages, considers assignment to a new variable in a local scope to implicitly declare that variable as a new local. Mostly this is pretty intuitive, but as with many things that behave intuitively, the details are more subtle than one might naïvely imagine.
"""

# ╔═╡ 03daf2b2-9e19-11eb-21a3-b9194e16c5aa
md"""
When `x = <value>` occurs in a local scope, Julia applies the following rules to decide what the expression means based on where the assignment expression occurs and what `x` already refers to at that location:
"""

# ╔═╡ 03daf4a6-9e19-11eb-2698-7fe5a49f4713
md"""
1. **Existing local:** If `x` is *already a local variable*, then the existing local `x` is assigned;
2. **Hard scope:** If `x` is *not already a local variable* and assignment occurs inside of any hard scope construct (i.e. within a let block, function or macro body, comprehension, or generator), a new local named `x` is created in the scope of the assignment;
3. **Soft scope:** If `x` is *not already a local variable* and all of the scope constructs containing the assignment are soft scopes (loops, `try`/`catch` blocks, or `struct` blocks), the behavior depends on whether the global variable `x` is defined:

      * if global `x` is *undefined*, a new local named `x` is created in the scope of the assignment;
      * if global `x` is *defined*, the assignment is considered ambiguous:

          * in *non-interactive* contexts (files, eval), an ambiguity warning is printed and a new local is created;
          * in *interactive* contexts (REPL, notebooks), the global variable `x` is assigned.
"""

# ╔═╡ 03daf4ba-9e19-11eb-14be-6725d2bd2791
md"""
You may note that in non-interactive contexts the hard and soft scope behaviors are identical except that a warning is printed when an implicitly local variable (i.e. not declared with `local x`) shadows a global. In interactive contexts, the rules follow a more complex heuristic for the sake of convenience. This is covered in depth in examples that follow.
"""

# ╔═╡ 03daf4e2-9e19-11eb-3604-a35e9362194d
md"""
Now that you know the rules, let's look at some examples. Each example is assumed to be evaluated in a fresh REPL session so that the only globals in each snippet are the ones that are assigned in that block of code.
"""

# ╔═╡ 03daf4ec-9e19-11eb-2fb7-1d5d3affc1e2
md"""
We'll begin with a nice and clear-cut situation—assignment inside of a hard scope, in this case a function body, when no local variable by that name already exists:
"""

# ╔═╡ 03daf8b6-9e19-11eb-03dd-5f79fa58d84b
function greet()
           x = "hello" # new local
           println(x)
       end

# ╔═╡ 03daf8b6-9e19-11eb-1fd1-db5663e23226
greet()

# ╔═╡ 03daf8cc-9e19-11eb-1747-7f017186e476
x # global

# ╔═╡ 03daf906-9e19-11eb-1ad9-5b99a503cf45
md"""
Inside of the `greet` function, the assignment `x = "hello"` causes `x` to be a new local variable in the function's scope. There are two relevant facts: the assignment occurs in local scope and there is no existing local `x` variable. Since `x` is local, it doesn't matter if there is a global named `x` or not. Here for example we define `x = 123` before defining and calling `greet`:
"""

# ╔═╡ 03dafdac-9e19-11eb-30a9-95a4dc9013e6
x = 123 # global

# ╔═╡ 03dafdc0-9e19-11eb-0855-9bcb94fe25b5
function greet()
           x = "hello" # new local
           println(x)
       end

# ╔═╡ 03dafdc0-9e19-11eb-326a-d34c28a1eb78
greet()

# ╔═╡ 03dafdc8-9e19-11eb-0b06-5b1d8649a612
x # global

# ╔═╡ 03dafdf2-9e19-11eb-3fba-c78840bcbfb3
md"""
Since the `x` in `greet` is local, the value (or lack thereof) of the global `x` is unaffected by calling `greet`. The hard scope rule doesn't care whether a global named `x` exists or not: assignment to `x` in a hard scope is local (unless `x` is declared global).
"""

# ╔═╡ 03dafe10-9e19-11eb-346d-3f413b1a5ee0
md"""
The next clear cut situation we'll consider is when there is already a local variable named `x`, in which case `x = <value>` always assigns to this existing local `x`.  The function `sum_to` computes the sum of the numbers from one up to `n`:
"""

# ╔═╡ 03dafe38-9e19-11eb-10cb-9dc24523e3f5
md"""
```julia
function sum_to(n)
    s = 0 # new local
    for i = 1:n
        s = s + i # assign existing local
    end
    return s # same local
end
```
"""

# ╔═╡ 03dafe60-9e19-11eb-3979-a9175962fd67
md"""
As in the previous example, the first assignment to `s` at the top of `sum_to` causes `s` to be a new local variable in the body of the function. The `for` loop has its own inner local scope within the function scope. At the point where `s = s + i` occurs, `s` is already a local variable, so the assignment updates the existing `s` instead of creating a new local. We can test this out by calling `sum_to` in the REPL:
"""

# ╔═╡ 03db0568-9e19-11eb-2803-b1a9034ebb48
function sum_to(n)
           s = 0 # new local
           for i = 1:n
               s = s + i # assign existing local
           end
           return s # same local
       end

# ╔═╡ 03db0574-9e19-11eb-29b0-3733caf5513e
sum_to(10)

# ╔═╡ 03db0586-9e19-11eb-3e9f-97eee5e51c15
s # global

# ╔═╡ 03db05b8-9e19-11eb-10a7-8f6c32eccc02
md"""
Since `s` is local to the function `sum_to`, calling the function has no effect on the global variable `s`. We can also see that the update `s = s + i` in the `for` loop must have updated the same `s` created by the initialization `s = 0` since we get the correct sum of 55 for the integers 1 through 10.
"""

# ╔═╡ 03db05d4-9e19-11eb-1ac6-791557a13d95
md"""
Let's dig into the fact that the `for` loop body has its own scope for a second by writing a slightly more verbose variation which we'll call `sum_to_def`, in which we save the sum `s + i` in a variable `t` before updating `s`:
"""

# ╔═╡ 03db0d1a-9e19-11eb-3590-5f56e87b9525
function sum_to_def(n)
           s = 0 # new local
           for i = 1:n
               t = s + i # new local `t`
               s = t # assign existing local `s`
           end
           return s, @isdefined(t)
       end

# ╔═╡ 03db0d38-9e19-11eb-1c43-091f00a5ff2e
sum_to_def(10)

# ╔═╡ 03db0d60-9e19-11eb-13bb-3387aa819cbe
md"""
This version returns `s` as before but it also uses the `@isdefined` macro to return a boolean indicating whether there is a local variable named `t` defined in the function's outermost local scope. As you can see, there is no `t` defined outside of the `for` loop body. This is because of the hard scope rule again: since the assignment to `t` occurs inside of a function, which introduces a hard scope, the assignment causes `t` to become a new local variable in the local scope where it appears, i.e. inside of the loop body. Even if there were a global named `t`, it would make no difference—the hard scope rule isn't affected by anything in global scope.
"""

# ╔═╡ 03db0d80-9e19-11eb-0fb2-29faefaa4d20
md"""
Let's move onto some more ambiguous cases covered by the soft scope rule. We'll explore this by extracting the bodies of the `greet` and `sum_to_def` functions into soft scope contexts. First, let's put the body of `greet` in a `for` loop—which is soft, rather than hard—and evaluate it in the REPL:
"""

# ╔═╡ 03db112a-9e19-11eb-3e5c-51d04ae78271
for i = 1:3
           x = "hello" # new local
           println(x)
       end

# ╔═╡ 03db115c-9e19-11eb-102a-e3c243857cd1
x

# ╔═╡ 03db1186-9e19-11eb-05b4-8387dbb27ce4
md"""
Since the global `x` is not defined when the `for` loop is evaluated, the first clause of the soft scope rule applies and `x` is created as local to the `for` loop and therefore global `x` remains undefined after the loop executes. Next, let's consider the body of `sum_to_def` extracted into global scope, fixing its argument to `n = 10`
"""

# ╔═╡ 03db11a2-9e19-11eb-0302-adcf54091728
md"""
```julia
s = 0
for i = 1:10
    t = s + i
    s = t
end
s
@isdefined(t)
```
"""

# ╔═╡ 03db11d4-9e19-11eb-31e3-1515ed78f0d0
md"""
What does this code do? Hint: it's a trick question. The answer is "it depends." If this code is entered interactively, it behaves the same way it does in a function body. But if the code appears in a file, it  prints an ambiguity warning and throws an undefined variable error. Let's see it working in the REPL first:
"""

# ╔═╡ 03db176a-9e19-11eb-3ed3-cd8c9efdc254
s = 0 # global

# ╔═╡ 03db1774-9e19-11eb-1cfe-03cc16028d32
for i = 1:10
           t = s + i # new local `t`
           s = t # assign global `s`
       end

# ╔═╡ 03db1774-9e19-11eb-1eb3-e1e570897e64
s # global

# ╔═╡ 03db177e-9e19-11eb-1f9e-47803371e965
@isdefined(t) # global

# ╔═╡ 03db17a6-9e19-11eb-3e42-636d9ce11c14
md"""
The REPL approximates being in the body of a function by deciding whether assignment inside the loop assigns to a global or creates new local based on whether a global variable by that name is defined or not. If a global by the name exists, then the assignment updates it. If no global exists, then the assignment creates a new local variable. In this example we see both cases in action:
"""

# ╔═╡ 03db1814-9e19-11eb-32fa-bba967b34a75
md"""
  * There is no global named `t`, so `t = s + i` creates a new `t` that is local to the `for` loop;
  * There is a global named `s`, so `s = t` assigns to it.
"""

# ╔═╡ 03db1828-9e19-11eb-0781-6ba19301107c
md"""
The second fact is why execution of the loop changes the global value of `s` and the first fact is why `t` is still undefined after the loop executes. Now, let's try evaluating this same code as though it were in a file instead:
"""

# ╔═╡ 03db1e04-9e19-11eb-2f7b-3ff7f751b847
code = """
       s = 0 # global
       for i = 1:10
           t = s + i # new local `t`
           s = t # new local `s` with warning
       end
       s, # global
       @isdefined(t) # global
       """;

# ╔═╡ 03db1e0e-9e19-11eb-1ad1-13bcd0011d53
include_string(Main, code)

# ╔═╡ 03db1e36-9e19-11eb-1d7d-5b336c4b9d9d
md"""
Here we use [`include_string`](@ref), to evaluate `code` as though it were the contents of a file. We could also save `code` to a file and then call `include` on that file—the result would be the same. As you can see, this behaves quite different from evaluating the same code in the REPL. Let's break down what's happening here:
"""

# ╔═╡ 03db1f3a-9e19-11eb-315e-076c71cae007
md"""
  * global `s` is defined with the value `0` before the loop is evaluated
  * the assignment `s = t` occurs in a soft scope—a `for` loop outside of any function body or other hard scope construct
  * therefore the second clause of the soft scope rule applies, and the assignment is ambiguous so a warning is emitted
  * execution continues, making `s` local to the `for` loop body
  * since `s` is local to the `for` loop, it is undefined when `t = s + i` is evaluated, causing an error
  * evaluation stops there, but if it got to `s` and `@isdefined(t)`, it would return `0` and `false`.
"""

# ╔═╡ 03db1f64-9e19-11eb-2a18-395914623613
md"""
This demonstrates some important aspects of scope: in a scope, each variable can only have one meaning, and that meaning is determined regardless of the order of expressions. The presence of the expression `s = t` in the loop causes `s` to be local to the loop, which means that it is also local when it appears on the right hand side of `t = s + i`, even though that expression appears first and is evaluated first. One might imagine that the `s` on the first line of the loop could be global while the `s` on the second line of the loop is local, but that's not possible since the two lines are in the same scope block and each variable can only mean one thing in a given scope.
"""

# ╔═╡ 03db1f96-9e19-11eb-1c4c-e5296849e6a7
md"""
#### On Soft Scope
"""

# ╔═╡ 03db1fa8-9e19-11eb-3a09-9d47c139b075
md"""
We have now covered all the local scope rules, but before wrapping up this section, perhaps a few words should be said about why the ambiguous soft scope case is handled differently in interactive and non-interactive contexts. There are two obvious questions one could ask:
"""

# ╔═╡ 03db1ff6-9e19-11eb-38ea-0bb0ca3778dd
md"""
1. Why doesn't it just work like the REPL everywhere?
2. Why doesn't it just work like in files everywhere? And maybe skip the warning?
"""

# ╔═╡ 03db2028-9e19-11eb-2dd7-a5da9f580ecc
md"""
In Julia ≤ 0.6, all global scopes did work like the current REPL: when `x = <value>` occurred in a loop (or `try`/`catch`, or `struct` body) but outside of a function body (or `let` block or comprehension), it was decided based on whether a global named `x` was defined or not whether `x` should be local to the loop. This behavior has the advantage of being intuitive and convenient since it approximates the behavior inside of a function body as closely as possible. In particular, it makes it easy to move code back and forth between a function body and the REPL when trying to debug the behavior of a function. However, it has some downsides. First, it's quite a complex behavior: many people over the years were confused about this behavior and complained that it was complicated and hard both to explain and understand. Fair point. Second, and arguably worse, is that it's bad for programming "at scale." When you see a small piece of code in one place like this, it's quite clear what's going on:
"""

# ╔═╡ 03db203e-9e19-11eb-09f6-b3ffd6776179
md"""
```julia
s = 0
for i = 1:10
    s += i
end
```
"""

# ╔═╡ 03db2052-9e19-11eb-3ea3-a9064aebf9fe
md"""
Obviously the intention is to modify the existing global variable `s`. What else could it mean? However, not all real world code is so short or so clear. We found that code like the following often occurs in the wild:
"""

# ╔═╡ 03db207a-9e19-11eb-33a2-7b11ed221d5c
md"""
```julia
x = 123

# much later
# maybe in a different file

for i = 1:10
    x = "hello"
    println(x)
end

# much later
# maybe in yet another file
# or maybe back in the first one where `x = 123`

y = x + 234
```
"""

# ╔═╡ 03db20ac-9e19-11eb-0880-19dde255e879
md"""
It's far less clear what should happen here. Since `x + "hello"` is a method error, it seems probable that the intention is for `x` to be local to the `for` loop. But runtime values and what methods happen to exist cannot be used to determine the scopes of variables. With the Julia ≤ 0.6 behavior, it's especially concerning that someone might have written the `for` loop first, had it working just fine, but later when someone else adds a new global far away—possibly in a different file—the code suddenly changes meaning and either breaks noisily or, worse still, silently does the wrong thing. This kind of ["spooky action at a distance"](https://en.wikipedia.org/wiki/Action_at_a_distance_(computer_programming)) is something that good programming language designs should prevent.
"""

# ╔═╡ 03db20c0-9e19-11eb-37f5-bdf417c705e5
md"""
So in Julia 1.0, we simplified the rules for scope: in any local scope, assignment to a name that wasn't already a local variable created a new local variable. This eliminated the notion of soft scope entirely as well as removing the potential for spooky action. We uncovered and fixed a significant number of bugs due to the removal of soft scope, vindicating the choice to get rid of it. And there was much rejoicing! Well, no, not really. Because some people were angry that they now had to write:
"""

# ╔═╡ 03db20de-9e19-11eb-283f-3fffb2f42a5d
md"""
```julia
s = 0
for i = 1:10
    global s += i
end
```
"""

# ╔═╡ 03db20f2-9e19-11eb-0e70-5bfa88e81ec3
md"""
Do you see that `global` annotation in there? Hideous. Obviously this situation could not be tolerated. But seriously, there are two main issues with requiring `global` for this kind of top-level code:
"""

# ╔═╡ 03db216a-9e19-11eb-21b7-714ff4d9acff
md"""
1. It's no longer convenient to copy and paste the code from inside a function body into the REPL to debug it—you have to add `global` annotations and then remove them again to go back;
2. Beginners will write this kind of code without the `global` and have no idea why their code doesn't work—the error that they get is that `s` is undefined, which does not seem to enlighten anyone who happens to make this mistake.
"""

# ╔═╡ 03db2188-9e19-11eb-0b43-217aa19ef598
md"""
As of Julia 1.5, this code works without the `global` annotation in interactive contexts like the REPL or Jupyter notebooks (just like Julia 0.6) and in files and other non-interactive contexts, it prints this very direct warning:
"""

# ╔═╡ 03db220a-9e19-11eb-14e1-d5f54d8193b3
md"""
> Assignment to `s` in soft scope is ambiguous because a global variable by the same name exists: `s` will be treated as a new local. Disambiguate by using `local s` to suppress this warning or `global s` to assign to the existing global variable.
"""

# ╔═╡ 03db221e-9e19-11eb-04d5-6d328fe4bdd3
md"""
This addresses both issues while preserving the "programming at scale" benefits of the 1.0 behavior: global variables have no spooky effect on the meaning of code that may be far away; in the REPL copy-and-paste debugging works and beginners don't have any issues; any time someone either forgets a `global` annotation or accidentally shadows an existing global with a local in a soft scope, which would be confusing anyway, they get a nice clear warning.
"""

# ╔═╡ 03db223c-9e19-11eb-0fca-a30c5bfed209
md"""
An important property of this design is that any code that executes in a file without a warning will behave the same way in a fresh REPL. And on the flip side, if you take a REPL session and save it to file, if it behaves differently than it did in the REPL, then you will get a warning.
"""

# ╔═╡ 03db2250-9e19-11eb-0875-6bd72c28c510
md"""
### Let Blocks
"""

# ╔═╡ 03db226e-9e19-11eb-273c-e53070a60e71
md"""
Unlike assignments to local variables, `let` statements allocate new variable bindings each time they run. An assignment modifies an existing value location, and `let` creates new locations. This difference is usually not important, and is only detectable in the case of variables that outlive their scope via closures. The `let` syntax accepts a comma-separated series of assignments and variable names:
"""

# ╔═╡ 03db29ee-9e19-11eb-113c-b94e6578796f
x, y, z = -1, -1, -1;

# ╔═╡ 03db2a0c-9e19-11eb-2a8c-cb5360a1f160
let x = 1, z
           println("x: $x, y: $y") # x is local variable, y the global
           println("z: $z") # errors as z has not been assigned yet but is local
       end

# ╔═╡ 03db2a2a-9e19-11eb-28bd-316434bcd04d
md"""
The assignments are evaluated in order, with each right-hand side evaluated in the scope before the new variable on the left-hand side has been introduced. Therefore it makes sense to write something like `let x = x` since the two `x` variables are distinct and have separate storage. Here is an example where the behavior of `let` is needed:
"""

# ╔═╡ 03db32ea-9e19-11eb-2d32-6b56d6295c1a
Fs = Vector{Any}(undef, 2); i = 1;

# ╔═╡ 03db32f4-9e19-11eb-0986-a9656e3b51bf
while i <= 2
           Fs[i] = ()->i
           global i += 1
       end

# ╔═╡ 03db3308-9e19-11eb-2f2e-e372c4d98342
Fs[1]()

# ╔═╡ 03db3308-9e19-11eb-186d-2de8209ae877
Fs[2]()

# ╔═╡ 03db3330-9e19-11eb-1367-03f86fba0858
md"""
Here we create and store two closures that return variable `i`. However, it is always the same variable `i`, so the two closures behave identically. We can use `let` to create a new binding for `i`:
"""

# ╔═╡ 03db3c36-9e19-11eb-3e06-a3b0d49e1953
Fs = Vector{Any}(undef, 2); i = 1;

# ╔═╡ 03db3c4a-9e19-11eb-2a95-1fc1b10e1a29
while i <= 2
           let i = i
               Fs[i] = ()->i
           end
           global i += 1
       end

# ╔═╡ 03db3c56-9e19-11eb-1715-57dab6f1b886
Fs[1]()

# ╔═╡ 03db3c5e-9e19-11eb-01a3-41fffdb2c084
Fs[2]()

# ╔═╡ 03db3c7c-9e19-11eb-12ad-7550effed2bd
md"""
Since the `begin` construct does not introduce a new scope, it can be useful to use a zero-argument `let` to just introduce a new scope block without creating any new bindings:
"""

# ╔═╡ 03db401e-9e19-11eb-0fa1-5b69fc824634
let
           local x = 1
           let
               local x = 2
           end
           x
       end

# ╔═╡ 03db4050-9e19-11eb-1901-7f0b56491392
md"""
Since `let` introduces a new scope block, the inner local `x` is a different variable than the outer local `x`.
"""

# ╔═╡ 03db4064-9e19-11eb-274f-abe43a7737e7
md"""
### Loops and Comprehensions
"""

# ╔═╡ 03db408e-9e19-11eb-2969-dd30614d4312
md"""
In loops and [comprehensions](@ref man-comprehensions), new variables introduced in their body scopes are freshly allocated for each loop iteration, as if the loop body were surrounded by a `let` block, as demonstrated by this example:
"""

# ╔═╡ 03db474e-9e19-11eb-3cce-21c0755e2de4
Fs = Vector{Any}(undef, 2);

# ╔═╡ 03db476c-9e19-11eb-2287-89e3241275cf
for j = 1:2
           Fs[j] = ()->j
       end

# ╔═╡ 03db4776-9e19-11eb-04b3-456cd512352e
Fs[1]()

# ╔═╡ 03db4776-9e19-11eb-1dee-d7eb65af9bc3
Fs[2]()

# ╔═╡ 03db479e-9e19-11eb-194c-7911ffd85e12
md"""
A `for` loop or comprehension iteration variable is always a new variable:
"""

# ╔═╡ 03db4ca0-9e19-11eb-3a17-e355a4be625a
function f()
           i = 0
           for i = 1:3
               # empty
           end
           return i
       end;

# ╔═╡ 03db4ca8-9e19-11eb-0958-b171b286111f
f()

# ╔═╡ 03db4cc6-9e19-11eb-3f4d-8f5e355ce628
md"""
However, it is occasionally useful to reuse an existing local variable as the iteration variable. This can be done conveniently by adding the keyword `outer`:
"""

# ╔═╡ 03db51da-9e19-11eb-0dda-f1db4b9615c4
function f()
           i = 0
           for outer i = 1:3
               # empty
           end
           return i
       end;

# ╔═╡ 03db51e4-9e19-11eb-1f10-07689b0b2b39
f()

# ╔═╡ 03db522a-9e19-11eb-0421-4b2b9ebca051
md"""
## Constants
"""

# ╔═╡ 03db5266-9e19-11eb-07a4-9dae51b1b69c
md"""
A common use of variables is giving names to specific, unchanging values. Such variables are only assigned once. This intent can be conveyed to the compiler using the [`const`](@ref) keyword:
"""

# ╔═╡ 03db561c-9e19-11eb-1d95-c50d24987d92
const e  = 2.71828182845904523536;

# ╔═╡ 03db5630-9e19-11eb-12c7-e59dc9a5e0f2
const pi = 3.14159265358979323846;

# ╔═╡ 03db564e-9e19-11eb-3092-ebdae680e8aa
md"""
Multiple variables can be declared in a single `const` statement:
"""

# ╔═╡ 03db5872-9e19-11eb-0366-0188e36829d9
const a, b = 1, 2

# ╔═╡ 03db58d8-9e19-11eb-21f1-e3fd33852c4f
md"""
The `const` declaration should only be used in global scope on globals. It is difficult for the compiler to optimize code involving global variables, since their values (or even their types) might change at almost any time. If a global variable will not change, adding a `const` declaration solves this performance problem.
"""

# ╔═╡ 03db58ec-9e19-11eb-3a29-c5ce983bd687
md"""
Local constants are quite different. The compiler is able to determine automatically when a local variable is constant, so local constant declarations are not necessary, and in fact are currently not supported.
"""

# ╔═╡ 03db5900-9e19-11eb-22c2-33a546f3117c
md"""
Special top-level assignments, such as those performed by the `function` and `struct` keywords, are constant by default.
"""

# ╔═╡ 03db591e-9e19-11eb-3666-5f291689f294
md"""
Note that `const` only affects the variable binding; the variable may be bound to a mutable object (such as an array), and that object may still be modified. Additionally when one tries to assign a value to a variable that is declared constant the following scenarios are possible:
"""

# ╔═╡ 03db59a8-9e19-11eb-2f00-77166ce5ed27
md"""
  * if a new value has a different type than the type of the constant then an error is thrown:
"""

# ╔═╡ 03db5c02-9e19-11eb-0c98-554d8dc0c8b1
const x = 1.0

# ╔═╡ 03db5c0c-9e19-11eb-1c39-c1c6be7f5128
x = 1

# ╔═╡ 03db5c5c-9e19-11eb-0167-e34496b11910
md"""
  * if a new value has the same type as the constant then a warning is printed:
"""

# ╔═╡ 03db5eaa-9e19-11eb-3856-bf60c29ddd1a
const y = 1.0

# ╔═╡ 03db5eaa-9e19-11eb-27f2-7b3fa9e1bbfa
y = 2.0

# ╔═╡ 03db5efa-9e19-11eb-2a36-4550a41cb73c
md"""
  * if an assignment would not result in the change of variable value no message is given:
"""

# ╔═╡ 03db6166-9e19-11eb-1c09-23d6e3c037ce
const z = 100

# ╔═╡ 03db6170-9e19-11eb-2ca8-1f447cb32ead
z = 100

# ╔═╡ 03db6198-9e19-11eb-156d-032e318d83cf
md"""
The last rule applies to immutable objects even if the variable binding would change, e.g.:
"""

# ╔═╡ 03db6b8c-9e19-11eb-3f3e-c938b161332c
const s1 = "1"

# ╔═╡ 03db6bca-9e19-11eb-3541-db09d91d6c09
s2 = "1"

# ╔═╡ 03db6bca-9e19-11eb-22e6-af85145273f3
pointer.([s1, s2], 1)

# ╔═╡ 03db6bd4-9e19-11eb-11ea-6dea58e1b849
s1 = s2

# ╔═╡ 03db6bd4-9e19-11eb-2d34-79a11dc1798a
pointer.([s1, s2], 1)

# ╔═╡ 03db6c30-9e19-11eb-003c-85f17dc26792
md"""
However, for mutable objects the warning is printed as expected:
"""

# ╔═╡ 03db6ece-9e19-11eb-0d9f-09c6e07c3066
const a = [1]

# ╔═╡ 03db6ece-9e19-11eb-30ef-ade48c3bb0ae
a = [1]

# ╔═╡ 03db7070-9e19-11eb-052e-51764582a489
md"""
Note that although sometimes possible, changing the value of a `const` variable is strongly discouraged, and is intended only for convenience during interactive use. Changing constants can cause various problems or unexpected behaviors. For instance, if a method references a constant and is already compiled before the constant is changed, then it might keep using the old value:
"""

# ╔═╡ 03db75b6-9e19-11eb-0c3a-1da1e3a1ae81
const x = 1

# ╔═╡ 03db75c0-9e19-11eb-1ec7-ebb9490ac9e9
f() = x

# ╔═╡ 03db75ca-9e19-11eb-06c9-012df8797000
f()

# ╔═╡ 03db75d6-9e19-11eb-2bd9-a5da783cae46
x = 2

# ╔═╡ 03db75d6-9e19-11eb-2feb-4375671e47f7
f()

# ╔═╡ Cell order:
# ╟─03dadd5e-9e19-11eb-159d-61175c932e20
# ╟─03dadd9a-9e19-11eb-3e2f-8159c76fe541
# ╟─03daddc2-9e19-11eb-013a-c98b49725fef
# ╟─03daddea-9e19-11eb-33d3-970827c4cb57
# ╟─03daddfe-9e19-11eb-214c-2f9c0f7b7f54
# ╟─03dae024-9e19-11eb-03f7-afdabdbbe09a
# ╟─03dae04c-9e19-11eb-2cde-efc4857179d6
# ╟─03dae06a-9e19-11eb-1c3f-d3ade8bd944a
# ╠═03dae3f8-9e19-11eb-262b-f5f79ee52645
# ╟─03dae420-9e19-11eb-1cca-a36b1df9b82a
# ╠═03dae6c8-9e19-11eb-1644-b3420febb289
# ╠═03dae6dc-9e19-11eb-0804-fdbbc07d8b33
# ╠═03dae6e6-9e19-11eb-3add-2bae727db562
# ╟─03dae722-9e19-11eb-347c-5f11354e8be8
# ╟─03dae740-9e19-11eb-05ca-0568987802a5
# ╟─03dae768-9e19-11eb-3467-dfcf2d8e081e
# ╠═03daf21c-9e19-11eb-3691-2fc0ca402be9
# ╠═03daf228-9e19-11eb-027b-ab53ad5d9e78
# ╠═03daf228-9e19-11eb-0f83-bb70f9f83914
# ╠═03daf230-9e19-11eb-08cf-b3bbe9b947bc
# ╟─03daf25a-9e19-11eb-1f6f-733db5061b6d
# ╟─03daf262-9e19-11eb-30de-67e270cc0442
# ╟─03daf29e-9e19-11eb-34ab-dff607328f75
# ╟─03daf2b2-9e19-11eb-21a3-b9194e16c5aa
# ╟─03daf4a6-9e19-11eb-2698-7fe5a49f4713
# ╟─03daf4ba-9e19-11eb-14be-6725d2bd2791
# ╟─03daf4e2-9e19-11eb-3604-a35e9362194d
# ╟─03daf4ec-9e19-11eb-2fb7-1d5d3affc1e2
# ╠═03daf8b6-9e19-11eb-03dd-5f79fa58d84b
# ╠═03daf8b6-9e19-11eb-1fd1-db5663e23226
# ╠═03daf8cc-9e19-11eb-1747-7f017186e476
# ╟─03daf906-9e19-11eb-1ad9-5b99a503cf45
# ╠═03dafdac-9e19-11eb-30a9-95a4dc9013e6
# ╠═03dafdc0-9e19-11eb-0855-9bcb94fe25b5
# ╠═03dafdc0-9e19-11eb-326a-d34c28a1eb78
# ╠═03dafdc8-9e19-11eb-0b06-5b1d8649a612
# ╟─03dafdf2-9e19-11eb-3fba-c78840bcbfb3
# ╟─03dafe10-9e19-11eb-346d-3f413b1a5ee0
# ╟─03dafe38-9e19-11eb-10cb-9dc24523e3f5
# ╟─03dafe60-9e19-11eb-3979-a9175962fd67
# ╠═03db0568-9e19-11eb-2803-b1a9034ebb48
# ╠═03db0574-9e19-11eb-29b0-3733caf5513e
# ╠═03db0586-9e19-11eb-3e9f-97eee5e51c15
# ╟─03db05b8-9e19-11eb-10a7-8f6c32eccc02
# ╟─03db05d4-9e19-11eb-1ac6-791557a13d95
# ╠═03db0d1a-9e19-11eb-3590-5f56e87b9525
# ╠═03db0d38-9e19-11eb-1c43-091f00a5ff2e
# ╟─03db0d60-9e19-11eb-13bb-3387aa819cbe
# ╟─03db0d80-9e19-11eb-0fb2-29faefaa4d20
# ╠═03db112a-9e19-11eb-3e5c-51d04ae78271
# ╠═03db115c-9e19-11eb-102a-e3c243857cd1
# ╟─03db1186-9e19-11eb-05b4-8387dbb27ce4
# ╟─03db11a2-9e19-11eb-0302-adcf54091728
# ╟─03db11d4-9e19-11eb-31e3-1515ed78f0d0
# ╠═03db176a-9e19-11eb-3ed3-cd8c9efdc254
# ╠═03db1774-9e19-11eb-1cfe-03cc16028d32
# ╠═03db1774-9e19-11eb-1eb3-e1e570897e64
# ╠═03db177e-9e19-11eb-1f9e-47803371e965
# ╟─03db17a6-9e19-11eb-3e42-636d9ce11c14
# ╟─03db1814-9e19-11eb-32fa-bba967b34a75
# ╟─03db1828-9e19-11eb-0781-6ba19301107c
# ╠═03db1e04-9e19-11eb-2f7b-3ff7f751b847
# ╠═03db1e0e-9e19-11eb-1ad1-13bcd0011d53
# ╟─03db1e36-9e19-11eb-1d7d-5b336c4b9d9d
# ╟─03db1f3a-9e19-11eb-315e-076c71cae007
# ╟─03db1f64-9e19-11eb-2a18-395914623613
# ╟─03db1f96-9e19-11eb-1c4c-e5296849e6a7
# ╟─03db1fa8-9e19-11eb-3a09-9d47c139b075
# ╟─03db1ff6-9e19-11eb-38ea-0bb0ca3778dd
# ╟─03db2028-9e19-11eb-2dd7-a5da9f580ecc
# ╟─03db203e-9e19-11eb-09f6-b3ffd6776179
# ╟─03db2052-9e19-11eb-3ea3-a9064aebf9fe
# ╟─03db207a-9e19-11eb-33a2-7b11ed221d5c
# ╟─03db20ac-9e19-11eb-0880-19dde255e879
# ╟─03db20c0-9e19-11eb-37f5-bdf417c705e5
# ╟─03db20de-9e19-11eb-283f-3fffb2f42a5d
# ╟─03db20f2-9e19-11eb-0e70-5bfa88e81ec3
# ╟─03db216a-9e19-11eb-21b7-714ff4d9acff
# ╟─03db2188-9e19-11eb-0b43-217aa19ef598
# ╟─03db220a-9e19-11eb-14e1-d5f54d8193b3
# ╟─03db221e-9e19-11eb-04d5-6d328fe4bdd3
# ╟─03db223c-9e19-11eb-0fca-a30c5bfed209
# ╟─03db2250-9e19-11eb-0875-6bd72c28c510
# ╟─03db226e-9e19-11eb-273c-e53070a60e71
# ╠═03db29ee-9e19-11eb-113c-b94e6578796f
# ╠═03db2a0c-9e19-11eb-2a8c-cb5360a1f160
# ╟─03db2a2a-9e19-11eb-28bd-316434bcd04d
# ╠═03db32ea-9e19-11eb-2d32-6b56d6295c1a
# ╠═03db32f4-9e19-11eb-0986-a9656e3b51bf
# ╠═03db3308-9e19-11eb-2f2e-e372c4d98342
# ╠═03db3308-9e19-11eb-186d-2de8209ae877
# ╟─03db3330-9e19-11eb-1367-03f86fba0858
# ╠═03db3c36-9e19-11eb-3e06-a3b0d49e1953
# ╠═03db3c4a-9e19-11eb-2a95-1fc1b10e1a29
# ╠═03db3c56-9e19-11eb-1715-57dab6f1b886
# ╠═03db3c5e-9e19-11eb-01a3-41fffdb2c084
# ╟─03db3c7c-9e19-11eb-12ad-7550effed2bd
# ╠═03db401e-9e19-11eb-0fa1-5b69fc824634
# ╟─03db4050-9e19-11eb-1901-7f0b56491392
# ╟─03db4064-9e19-11eb-274f-abe43a7737e7
# ╟─03db408e-9e19-11eb-2969-dd30614d4312
# ╠═03db474e-9e19-11eb-3cce-21c0755e2de4
# ╠═03db476c-9e19-11eb-2287-89e3241275cf
# ╠═03db4776-9e19-11eb-04b3-456cd512352e
# ╠═03db4776-9e19-11eb-1dee-d7eb65af9bc3
# ╟─03db479e-9e19-11eb-194c-7911ffd85e12
# ╠═03db4ca0-9e19-11eb-3a17-e355a4be625a
# ╠═03db4ca8-9e19-11eb-0958-b171b286111f
# ╟─03db4cc6-9e19-11eb-3f4d-8f5e355ce628
# ╠═03db51da-9e19-11eb-0dda-f1db4b9615c4
# ╠═03db51e4-9e19-11eb-1f10-07689b0b2b39
# ╟─03db522a-9e19-11eb-0421-4b2b9ebca051
# ╟─03db5266-9e19-11eb-07a4-9dae51b1b69c
# ╠═03db561c-9e19-11eb-1d95-c50d24987d92
# ╠═03db5630-9e19-11eb-12c7-e59dc9a5e0f2
# ╟─03db564e-9e19-11eb-3092-ebdae680e8aa
# ╠═03db5872-9e19-11eb-0366-0188e36829d9
# ╟─03db58d8-9e19-11eb-21f1-e3fd33852c4f
# ╟─03db58ec-9e19-11eb-3a29-c5ce983bd687
# ╟─03db5900-9e19-11eb-22c2-33a546f3117c
# ╟─03db591e-9e19-11eb-3666-5f291689f294
# ╟─03db59a8-9e19-11eb-2f00-77166ce5ed27
# ╠═03db5c02-9e19-11eb-0c98-554d8dc0c8b1
# ╠═03db5c0c-9e19-11eb-1c39-c1c6be7f5128
# ╟─03db5c5c-9e19-11eb-0167-e34496b11910
# ╠═03db5eaa-9e19-11eb-3856-bf60c29ddd1a
# ╠═03db5eaa-9e19-11eb-27f2-7b3fa9e1bbfa
# ╟─03db5efa-9e19-11eb-2a36-4550a41cb73c
# ╠═03db6166-9e19-11eb-1c09-23d6e3c037ce
# ╠═03db6170-9e19-11eb-2ca8-1f447cb32ead
# ╟─03db6198-9e19-11eb-156d-032e318d83cf
# ╠═03db6b8c-9e19-11eb-3f3e-c938b161332c
# ╠═03db6bca-9e19-11eb-3541-db09d91d6c09
# ╠═03db6bca-9e19-11eb-22e6-af85145273f3
# ╠═03db6bd4-9e19-11eb-11ea-6dea58e1b849
# ╠═03db6bd4-9e19-11eb-2d34-79a11dc1798a
# ╟─03db6c30-9e19-11eb-003c-85f17dc26792
# ╠═03db6ece-9e19-11eb-0d9f-09c6e07c3066
# ╠═03db6ece-9e19-11eb-30ef-ade48c3bb0ae
# ╟─03db7070-9e19-11eb-052e-51764582a489
# ╠═03db75b6-9e19-11eb-0c3a-1da1e3a1ae81
# ╠═03db75c0-9e19-11eb-1ec7-ebb9490ac9e9
# ╠═03db75ca-9e19-11eb-06c9-012df8797000
# ╠═03db75d6-9e19-11eb-2bd9-a5da783cae46
# ╠═03db75d6-9e19-11eb-2feb-4375671e47f7
