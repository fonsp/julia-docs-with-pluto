### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ f44c8733-85c1-4877-a9c6-39600c971e31
md"""
# [Scope of Variables](@id scope-of-variables)
"""

# ╔═╡ b220b0aa-9915-459c-9746-750911594eeb
md"""
The *scope* of a variable is the region of code within which a variable is visible. Variable scoping helps avoid variable naming conflicts. The concept is intuitive: two functions can both have arguments called `x` without the two `x`'s referring to the same thing. Similarly, there are many other cases where different blocks of code can use the same name without referring to the same thing. The rules for when the same variable name does or doesn't refer to the same thing are called scope rules; this section spells them out in detail.
"""

# ╔═╡ 684efc27-0763-4de6-aa76-41d1aadf2311
md"""
Certain constructs in the language introduce *scope blocks*, which are regions of code that are eligible to be the scope of some set of variables. The scope of a variable cannot be an arbitrary set of source lines; instead, it will always line up with one of these blocks. There are two main types of scopes in Julia, *global scope* and *local scope*. The latter can be nested. There is also a distinction in Julia between constructs which introduce a \"hard scope\" and those which only introduce a \"soft scope\", which affects whether [shadowing](https://en.wikipedia.org/wiki/Variable_shadowing) a global variable by the same name is allowed or not.
"""

# ╔═╡ 9b03afa7-f028-43f4-b214-0b76a51b3d96
md"""
### [Scope constructs](@id man-scope-table)
"""

# ╔═╡ 09cabcf1-56b6-4451-bd1b-335f6bc79711
md"""
The constructs introducing scope blocks are:
"""

# ╔═╡ 9e7ced20-5fec-4390-866b-c8ed90664f72
md"""
| Construct                                                                        | Scope type   | Allowed within |
|:-------------------------------------------------------------------------------- |:------------ |:-------------- |
| [`module`](@ref), [`baremodule`](@ref)                                           | global       | global         |
| [`struct`](@ref)                                                                 | local (soft) | global         |
| [`for`](@ref), [`while`](@ref), [`try`](@ref try)                                | local (soft) | global, local  |
| [`macro`](@ref)                                                                  | local (hard) | global         |
| functions, [`do`](@ref) blocks, [`let`](@ref) blocks, comprehensions, generators | local (hard) | global, local  |
"""

# ╔═╡ 761868f3-39e4-4c69-bdd5-44053a40a6ef
md"""
Notably missing from this table are [begin blocks](@ref man-compound-expressions) and [if blocks](@ref man-conditional-evaluation) which do *not* introduce new scopes. The three types of scopes follow somewhat different rules which will be explained below.
"""

# ╔═╡ d8de0234-c33d-4e8d-8ce8-318e0399e0de
md"""
Julia uses [lexical scoping](https://en.wikipedia.org/wiki/Scope_%28computer_science%29#Lexical_scoping_vs._dynamic_scoping), meaning that a function's scope does not inherit from its caller's scope, but from the scope in which the function was defined. For example, in the following code the `x` inside `foo` refers to the `x` in the global scope of its module `Bar`:
"""

# ╔═╡ 236b2b56-7875-4983-862c-a8a6df019b21
module Bar
     x = 1
     foo() = x
 end;

# ╔═╡ 346c4c46-210f-4e77-9658-3314f482ef02
md"""
and not a `x` in the scope where `foo` is used:
"""

# ╔═╡ 61c58f3e-20fa-4975-91af-c983b602ec29
import .Bar

# ╔═╡ 6ce69d54-3d9e-49a6-b425-78d9b2941919
x = -1;

# ╔═╡ eecd2373-1c38-4f6d-a94e-f67ec5a008ba
Bar.foo()

# ╔═╡ e4cbdb26-c779-43bc-81cd-84e5ad10844a
md"""
Thus *lexical scope* means that what a variable in a particular piece of code refers to can be deduced from the code in which it appears alone and does not depend on how the program executes. A scope nested inside another scope can \"see\" variables in all the outer scopes in which it is contained. Outer scopes, on the other hand, cannot see variables in inner scopes.
"""

# ╔═╡ 694f40c6-b695-46d3-92f6-46bc60874f66
md"""
## Global Scope
"""

# ╔═╡ 4109d5bd-7ff6-4a10-9099-b9cbbf4d8252
md"""
Each module introduces a new global scope, separate from the global scope of all other modules—there is no all-encompassing global scope. Modules can introduce variables of other modules into their scope through the [using or import](@ref modules) statements or through qualified access using the dot-notation, i.e. each module is a so-called *namespace* as well as a first-class data structure associating names with values. Note that while variable bindings can be read externally, they can only be changed within the module to which they belong. As an escape hatch, you can always evaluate code inside that module to modify a variable; this guarantees, in particular, that module bindings cannot be modified externally by code that never calls `eval`.
"""

# ╔═╡ d23cde56-de47-4cae-981c-9775ab2018f6
module A
     a = 1 # a global in A's scope
 end;

# ╔═╡ dccad65d-a171-4b7e-a1a7-9d0ac01e50ff
module B
     module C
         c = 2
     end
     b = C.c    # can access the namespace of a nested global scope
                # through a qualified access
     import ..A # makes module A available
     d = A.a
 end;

# ╔═╡ bcb519c7-a45b-4ecf-a577-462a6e2726b9
module D
     b = a # errors as D's global scope is separate from A's
 end;

# ╔═╡ 2b5c0bd2-fca1-41bc-88dd-cf8242d54340
module E
     import ..A # make module A available
     A.a = 2    # throws below error
 end;

# ╔═╡ e1105d22-9b38-48fb-aed8-82f113aa8b52
md"""
Note that the interactive prompt (aka REPL) is in the global scope of the module `Main`.
"""

# ╔═╡ f87a689f-1a4f-4a32-9536-73082a768513
md"""
## Local Scope
"""

# ╔═╡ 2900fc89-7d29-41b7-af88-80b2a4a3cd90
md"""
A new local scope is introduced by most code blocks (see above [table](@ref man-scope-table) for a complete list). Some programming languages require explicitly declaring new variables before using them. Explicit declaration works in Julia too: in any local scope, writing `local x` declares a new local variable in that scope, regardless of whether there is already a variable named `x` in an outer scope or not. Declaring each new local like this is somewhat verbose and tedious, however, so Julia, like many other languages, considers assignment to a new variable in a local scope to implicitly declare that variable as a new local. Mostly this is pretty intuitive, but as with many things that behave intuitively, the details are more subtle than one might naïvely imagine.
"""

# ╔═╡ 64dae113-6ed5-47bf-a2bb-b792c32be42b
md"""
When `x = <value>` occurs in a local scope, Julia applies the following rules to decide what the expression means based on where the assignment expression occurs and what `x` already refers to at that location:
"""

# ╔═╡ 35ef4ca0-cc3e-4a6b-a9df-a712f3defab7
md"""
1. **Existing local:** If `x` is *already a local variable*, then the existing local `x` is assigned;
2. **Hard scope:** If `x` is *not already a local variable* and assignment occurs inside of any hard scope construct (i.e. within a let block, function or macro body, comprehension, or generator), a new local named `x` is created in the scope of the assignment;
3. **Soft scope:** If `x` is *not already a local variable* and all of the scope constructs containing the assignment are soft scopes (loops, `try`/`catch` blocks, or `struct` blocks), the behavior depends on whether the global variable `x` is defined:

      * if global `x` is *undefined*, a new local named `x` is created in the scope of the assignment;
      * if global `x` is *defined*, the assignment is considered ambiguous:

          * in *non-interactive* contexts (files, eval), an ambiguity warning is printed and a new local is created;
          * in *interactive* contexts (REPL, notebooks), the global variable `x` is assigned.
"""

# ╔═╡ c48011be-162e-47a0-a089-692d7818d88c
md"""
You may note that in non-interactive contexts the hard and soft scope behaviors are identical except that a warning is printed when an implicitly local variable (i.e. not declared with `local x`) shadows a global. In interactive contexts, the rules follow a more complex heuristic for the sake of convenience. This is covered in depth in examples that follow.
"""

# ╔═╡ eedc1d3e-8426-48ee-8e8d-0e3d803d987d
md"""
Now that you know the rules, let's look at some examples. Each example is assumed to be evaluated in a fresh REPL session so that the only globals in each snippet are the ones that are assigned in that block of code.
"""

# ╔═╡ 8d2a208d-29c9-478e-8f13-9a2b8c1251e5
md"""
We'll begin with a nice and clear-cut situation—assignment inside of a hard scope, in this case a function body, when no local variable by that name already exists:
"""

# ╔═╡ b108a0c9-0626-4852-8661-288ceaaef524
function greet()
     x = "hello" # new local
     println(x)
 end

# ╔═╡ d03cc383-eea4-4a5b-b3a8-cc3744634071
greet()

# ╔═╡ 33aa023f-1fb1-40e8-9849-e80272713bbe
x # global

# ╔═╡ 65dbccb7-2dc8-4ffc-b41a-99d9afe1767c
md"""
Inside of the `greet` function, the assignment `x = \"hello\"` causes `x` to be a new local variable in the function's scope. There are two relevant facts: the assignment occurs in local scope and there is no existing local `x` variable. Since `x` is local, it doesn't matter if there is a global named `x` or not. Here for example we define `x = 123` before defining and calling `greet`:
"""

# ╔═╡ f43c1f00-84da-4cd2-8977-049c3b21ccf3
x = 123 # global

# ╔═╡ 782095d5-c920-4a05-936d-8ecafd0e7c31
function greet()
     x = "hello" # new local
     println(x)
 end

# ╔═╡ 3f98d87e-27ba-494e-aeff-003f5ab7e4f1
greet()

# ╔═╡ 67772b18-ff01-4376-9ac5-0aa96fbb7393
x # global

# ╔═╡ 112824b0-2b61-4fc9-ac2c-d09282184bc4
md"""
Since the `x` in `greet` is local, the value (or lack thereof) of the global `x` is unaffected by calling `greet`. The hard scope rule doesn't care whether a global named `x` exists or not: assignment to `x` in a hard scope is local (unless `x` is declared global).
"""

# ╔═╡ c5c26251-386b-466f-af5b-e14f9696645f
md"""
The next clear cut situation we'll consider is when there is already a local variable named `x`, in which case `x = <value>` always assigns to this existing local `x`.  The function `sum_to` computes the sum of the numbers from one up to `n`:
"""

# ╔═╡ aaab0c73-1368-4097-90bb-af16219a28de
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

# ╔═╡ cedc697c-d908-427f-abc1-0f3220313ed5
md"""
As in the previous example, the first assignment to `s` at the top of `sum_to` causes `s` to be a new local variable in the body of the function. The `for` loop has its own inner local scope within the function scope. At the point where `s = s + i` occurs, `s` is already a local variable, so the assignment updates the existing `s` instead of creating a new local. We can test this out by calling `sum_to` in the REPL:
"""

# ╔═╡ cb00ce61-a206-44d6-913b-98bb7361a6a4
function sum_to(n)
     s = 0 # new local
     for i = 1:n
         s = s + i # assign existing local
     end
     return s # same local
 end

# ╔═╡ 2a93a74f-5a9a-4a50-8601-cd57bd85f737
sum_to(10)

# ╔═╡ 3cc95427-c9fd-49fa-aa27-ce4b288efa29
s # global

# ╔═╡ 86303da7-735c-4d2a-a703-2d34e315bda2
md"""
Since `s` is local to the function `sum_to`, calling the function has no effect on the global variable `s`. We can also see that the update `s = s + i` in the `for` loop must have updated the same `s` created by the initialization `s = 0` since we get the correct sum of 55 for the integers 1 through 10.
"""

# ╔═╡ 9993e021-287a-4444-ba91-936d2081c626
md"""
Let's dig into the fact that the `for` loop body has its own scope for a second by writing a slightly more verbose variation which we'll call `sum_to_def`, in which we save the sum `s + i` in a variable `t` before updating `s`:
"""

# ╔═╡ 98f78120-6c04-4b0a-9c0e-fb294ead8cc8
function sum_to_def(n)
     s = 0 # new local
     for i = 1:n
         t = s + i # new local `t`
         s = t # assign existing local `s`
     end
     return s, @isdefined(t)
 end

# ╔═╡ 9588ff2f-f743-41d1-93d8-2236e684c3a2
sum_to_def(10)

# ╔═╡ f876f8ea-826b-4a4d-b456-192656b8881c
md"""
This version returns `s` as before but it also uses the `@isdefined` macro to return a boolean indicating whether there is a local variable named `t` defined in the function's outermost local scope. As you can see, there is no `t` defined outside of the `for` loop body. This is because of the hard scope rule again: since the assignment to `t` occurs inside of a function, which introduces a hard scope, the assignment causes `t` to become a new local variable in the local scope where it appears, i.e. inside of the loop body. Even if there were a global named `t`, it would make no difference—the hard scope rule isn't affected by anything in global scope.
"""

# ╔═╡ 88cfbdd1-6076-4b56-afec-b260b9cb62f6
md"""
Let's move onto some more ambiguous cases covered by the soft scope rule. We'll explore this by extracting the bodies of the `greet` and `sum_to_def` functions into soft scope contexts. First, let's put the body of `greet` in a `for` loop—which is soft, rather than hard—and evaluate it in the REPL:
"""

# ╔═╡ b11542a7-13cc-4f2b-8a5b-6ee65de96eda
for i = 1:3
     x = "hello" # new local
     println(x)
 end

# ╔═╡ d546e9d4-b48c-44d3-a27d-78483435c956
x

# ╔═╡ 93e20d7d-91e6-4a0a-a73e-68e596698b55
md"""
Since the global `x` is not defined when the `for` loop is evaluated, the first clause of the soft scope rule applies and `x` is created as local to the `for` loop and therefore global `x` remains undefined after the loop executes. Next, let's consider the body of `sum_to_def` extracted into global scope, fixing its argument to `n = 10`
"""

# ╔═╡ 56645dd2-f5d9-4149-82f9-f0d9c99c9f66
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

# ╔═╡ 6e675534-8d08-4afe-b801-91ef0fcffc67
md"""
What does this code do? Hint: it's a trick question. The answer is \"it depends.\" If this code is entered interactively, it behaves the same way it does in a function body. But if the code appears in a file, it  prints an ambiguity warning and throws an undefined variable error. Let's see it working in the REPL first:
"""

# ╔═╡ 17516355-ffd9-4079-a34d-34bfb1be76ed
s = 0 # global

# ╔═╡ ab4e2c99-9c4c-40b8-8dd3-d067fb2a2e33
for i = 1:10
     t = s + i # new local `t`
     s = t # assign global `s`
 end

# ╔═╡ c897c1f8-c823-4c50-9320-c08927d63c41
s # global

# ╔═╡ 0096fc7e-bbd7-46e9-9392-19b95fcde205
@isdefined(t) # global

# ╔═╡ f55ee07d-be9a-45ee-9d88-4f13e6093edb
md"""
The REPL approximates being in the body of a function by deciding whether assignment inside the loop assigns to a global or creates new local based on whether a global variable by that name is defined or not. If a global by the name exists, then the assignment updates it. If no global exists, then the assignment creates a new local variable. In this example we see both cases in action:
"""

# ╔═╡ 95a71e58-dccb-4381-a269-c2eefeec0470
md"""
  * There is no global named `t`, so `t = s + i` creates a new `t` that is local to the `for` loop;
  * There is a global named `s`, so `s = t` assigns to it.
"""

# ╔═╡ 8525eef7-04f5-427b-bc97-98dcd9168fb6
md"""
The second fact is why execution of the loop changes the global value of `s` and the first fact is why `t` is still undefined after the loop executes. Now, let's try evaluating this same code as though it were in a file instead:
"""

# ╔═╡ 6bb3dc54-c35f-425f-927b-078c1a2c203e
code = """
 s = 0 # global
 for i = 1:10
     t = s + i # new local `t`
     s = t # new local `s` with warning
 end
 s, # global
 @isdefined(t) # global
 """;

# ╔═╡ fc7600a5-498a-4bea-acd6-79233548ac44
include_string(Main, code)

# ╔═╡ 9963ccdc-77bf-4699-ab43-341de6198f55
md"""
Here we use [`include_string`](@ref), to evaluate `code` as though it were the contents of a file. We could also save `code` to a file and then call `include` on that file—the result would be the same. As you can see, this behaves quite different from evaluating the same code in the REPL. Let's break down what's happening here:
"""

# ╔═╡ b927d6d4-99a4-46be-90d0-55a3d0c6330b
md"""
  * global `s` is defined with the value `0` before the loop is evaluated
  * the assignment `s = t` occurs in a soft scope—a `for` loop outside of any function body or other hard scope construct
  * therefore the second clause of the soft scope rule applies, and the assignment is ambiguous so a warning is emitted
  * execution continues, making `s` local to the `for` loop body
  * since `s` is local to the `for` loop, it is undefined when `t = s + i` is evaluated, causing an error
  * evaluation stops there, but if it got to `s` and `@isdefined(t)`, it would return `0` and `false`.
"""

# ╔═╡ 09bd4927-2293-4f11-9c9f-62987a403d8f
md"""
This demonstrates some important aspects of scope: in a scope, each variable can only have one meaning, and that meaning is determined regardless of the order of expressions. The presence of the expression `s = t` in the loop causes `s` to be local to the loop, which means that it is also local when it appears on the right hand side of `t = s + i`, even though that expression appears first and is evaluated first. One might imagine that the `s` on the first line of the loop could be global while the `s` on the second line of the loop is local, but that's not possible since the two lines are in the same scope block and each variable can only mean one thing in a given scope.
"""

# ╔═╡ 14808c61-d337-426b-888f-541214c80636
md"""
#### On Soft Scope
"""

# ╔═╡ d05e1ab3-a6dc-4ec4-8bf6-bf60c699207c
md"""
We have now covered all the local scope rules, but before wrapping up this section, perhaps a few words should be said about why the ambiguous soft scope case is handled differently in interactive and non-interactive contexts. There are two obvious questions one could ask:
"""

# ╔═╡ ca8ddaa8-5723-4fb8-83f8-0de136238959
md"""
1. Why doesn't it just work like the REPL everywhere?
2. Why doesn't it just work like in files everywhere? And maybe skip the warning?
"""

# ╔═╡ dcdacd12-78c8-418a-84e7-d1f365b3f315
md"""
In Julia ≤ 0.6, all global scopes did work like the current REPL: when `x = <value>` occurred in a loop (or `try`/`catch`, or `struct` body) but outside of a function body (or `let` block or comprehension), it was decided based on whether a global named `x` was defined or not whether `x` should be local to the loop. This behavior has the advantage of being intuitive and convenient since it approximates the behavior inside of a function body as closely as possible. In particular, it makes it easy to move code back and forth between a function body and the REPL when trying to debug the behavior of a function. However, it has some downsides. First, it's quite a complex behavior: many people over the years were confused about this behavior and complained that it was complicated and hard both to explain and understand. Fair point. Second, and arguably worse, is that it's bad for programming \"at scale.\" When you see a small piece of code in one place like this, it's quite clear what's going on:
"""

# ╔═╡ e2bff0f3-38a2-48e8-b2c5-36bf59e85b96
md"""
```julia
s = 0
for i = 1:10
    s += i
end
```
"""

# ╔═╡ 6bbd7560-6938-42fe-857f-e20b875d46b4
md"""
Obviously the intention is to modify the existing global variable `s`. What else could it mean? However, not all real world code is so short or so clear. We found that code like the following often occurs in the wild:
"""

# ╔═╡ b8775af6-c21d-47f2-8288-55847ed74fa4
md"""
```julia
x = 123

# much later
# maybe in a different file

for i = 1:10
    x = \"hello\"
    println(x)
end

# much later
# maybe in yet another file
# or maybe back in the first one where `x = 123`

y = x + 234
```
"""

# ╔═╡ c977acac-bdd9-4dd9-84f7-e33b96be4622
md"""
It's far less clear what should happen here. Since `x + \"hello\"` is a method error, it seems probable that the intention is for `x` to be local to the `for` loop. But runtime values and what methods happen to exist cannot be used to determine the scopes of variables. With the Julia ≤ 0.6 behavior, it's especially concerning that someone might have written the `for` loop first, had it working just fine, but later when someone else adds a new global far away—possibly in a different file—the code suddenly changes meaning and either breaks noisily or, worse still, silently does the wrong thing. This kind of [\"spooky action at a distance\"](https://en.wikipedia.org/wiki/Action_at_a_distance_(computer_programming)) is something that good programming language designs should prevent.
"""

# ╔═╡ 0f3ebecd-6320-43fa-acec-d56bf16b33b4
md"""
So in Julia 1.0, we simplified the rules for scope: in any local scope, assignment to a name that wasn't already a local variable created a new local variable. This eliminated the notion of soft scope entirely as well as removing the potential for spooky action. We uncovered and fixed a significant number of bugs due to the removal of soft scope, vindicating the choice to get rid of it. And there was much rejoicing! Well, no, not really. Because some people were angry that they now had to write:
"""

# ╔═╡ 55a024e3-e514-46b4-95ee-70337e9d69d0
md"""
```julia
s = 0
for i = 1:10
    global s += i
end
```
"""

# ╔═╡ e0437065-3bc4-4e14-967c-3b51bc278770
md"""
Do you see that `global` annotation in there? Hideous. Obviously this situation could not be tolerated. But seriously, there are two main issues with requiring `global` for this kind of top-level code:
"""

# ╔═╡ c37b06e5-afb8-4125-b218-7599437a6ee7
md"""
1. It's no longer convenient to copy and paste the code from inside a function body into the REPL to debug it—you have to add `global` annotations and then remove them again to go back;
2. Beginners will write this kind of code without the `global` and have no idea why their code doesn't work—the error that they get is that `s` is undefined, which does not seem to enlighten anyone who happens to make this mistake.
"""

# ╔═╡ 9079ff22-0f1f-4926-9a48-dca4b9e1684a
md"""
As of Julia 1.5, this code works without the `global` annotation in interactive contexts like the REPL or Jupyter notebooks (just like Julia 0.6) and in files and other non-interactive contexts, it prints this very direct warning:
"""

# ╔═╡ 474fa40d-d893-4fc2-b4c1-02c5daf3ce84
md"""
> Assignment to `s` in soft scope is ambiguous because a global variable by the same name exists: `s` will be treated as a new local. Disambiguate by using `local s` to suppress this warning or `global s` to assign to the existing global variable.
"""

# ╔═╡ ca9232eb-80c8-4132-98e9-7645de76f474
md"""
This addresses both issues while preserving the \"programming at scale\" benefits of the 1.0 behavior: global variables have no spooky effect on the meaning of code that may be far away; in the REPL copy-and-paste debugging works and beginners don't have any issues; any time someone either forgets a `global` annotation or accidentally shadows an existing global with a local in a soft scope, which would be confusing anyway, they get a nice clear warning.
"""

# ╔═╡ 678193d4-fc55-4bb8-bc37-dbe239a51bb8
md"""
An important property of this design is that any code that executes in a file without a warning will behave the same way in a fresh REPL. And on the flip side, if you take a REPL session and save it to file, if it behaves differently than it did in the REPL, then you will get a warning.
"""

# ╔═╡ 70619e90-6e20-48f7-b93a-3f6cb56d2569
md"""
### Let Blocks
"""

# ╔═╡ f5b5c93a-d65c-444f-96f1-90d90ce23957
md"""
Unlike assignments to local variables, `let` statements allocate new variable bindings each time they run. An assignment modifies an existing value location, and `let` creates new locations. This difference is usually not important, and is only detectable in the case of variables that outlive their scope via closures. The `let` syntax accepts a comma-separated series of assignments and variable names:
"""

# ╔═╡ 2e63cc31-5e6c-4d09-a8a1-55e8bbfc1d39
x, y, z = -1, -1, -1;

# ╔═╡ e457f296-46f4-4a16-915e-81d1a358f149
let x = 1, z
     println("x: $x, y: $y") # x is local variable, y the global
     println("z: $z") # errors as z has not been assigned yet but is local
 end

# ╔═╡ ec741b17-0b2c-4d99-a995-b038d70e98bf
md"""
The assignments are evaluated in order, with each right-hand side evaluated in the scope before the new variable on the left-hand side has been introduced. Therefore it makes sense to write something like `let x = x` since the two `x` variables are distinct and have separate storage. Here is an example where the behavior of `let` is needed:
"""

# ╔═╡ 77b52c82-e9de-49f3-aca9-3fe03ba1ea8c
Fs = Vector{Any}(undef, 2); i = 1;

# ╔═╡ 176138a7-fcf3-4e64-a1e8-a537fc2d9e36
while i <= 2
     Fs[i] = ()->i
     global i += 1
 end

# ╔═╡ e1714c04-3fae-4d81-a0b7-9f0919e3f185
Fs[1]()

# ╔═╡ 1a68d999-8724-4ebb-8eb1-5e1605d05578
Fs[2]()

# ╔═╡ 40d8ad32-1a6d-45d3-a478-3d15244a0c1a
md"""
Here we create and store two closures that return variable `i`. However, it is always the same variable `i`, so the two closures behave identically. We can use `let` to create a new binding for `i`:
"""

# ╔═╡ ff57f218-40d7-48e4-9fe1-125fb1339d29
Fs = Vector{Any}(undef, 2); i = 1;

# ╔═╡ f2d4439f-353e-4bba-962f-560f9d04d5ea
while i <= 2
     let i = i
         Fs[i] = ()->i
     end
     global i += 1
 end

# ╔═╡ 30045199-6cf2-4af3-8c63-312958fe4795
Fs[1]()

# ╔═╡ 9088d113-74eb-4533-932a-85fcf09c1cff
Fs[2]()

# ╔═╡ 9e33f6da-31a2-49bb-99d6-217d3763a055
md"""
Since the `begin` construct does not introduce a new scope, it can be useful to use a zero-argument `let` to just introduce a new scope block without creating any new bindings:
"""

# ╔═╡ 1de2cbe3-0d17-46cf-a02c-cbb1a9a875d6
let
     local x = 1
     let
         local x = 2
     end
     x
 end

# ╔═╡ c91aabd2-72cc-4713-adbc-5c8725572c5d
md"""
Since `let` introduces a new scope block, the inner local `x` is a different variable than the outer local `x`.
"""

# ╔═╡ f28cf116-8be2-4f0e-861c-809d7bce9889
md"""
### Loops and Comprehensions
"""

# ╔═╡ 169a64bf-a4a6-46e9-a247-08e83bcc6fec
md"""
In loops and [comprehensions](@ref man-comprehensions), new variables introduced in their body scopes are freshly allocated for each loop iteration, as if the loop body were surrounded by a `let` block, as demonstrated by this example:
"""

# ╔═╡ 7beb71d9-fdf0-4e3d-9ae8-49c610653c62
Fs = Vector{Any}(undef, 2);

# ╔═╡ 5b5b561a-d368-4586-876b-1d36af730cea
for j = 1:2
     Fs[j] = ()->j
 end

# ╔═╡ 1c833359-3ece-449d-973f-70ead9a62c54
Fs[1]()

# ╔═╡ 52454908-44c5-4fbc-a0b3-f9c877eb5bf9
Fs[2]()

# ╔═╡ 46d8328f-761a-4e74-a7d1-0804e615e1c9
md"""
A `for` loop or comprehension iteration variable is always a new variable:
"""

# ╔═╡ 01402019-0255-4fe7-964a-5b3d953cdad0
function f()
     i = 0
     for i = 1:3
         # empty
     end
     return i
 end;

# ╔═╡ 6a2d5f31-54dc-4a30-a459-baea560333c1
f()

# ╔═╡ fef32557-b599-406e-b1e3-71c123024347
md"""
However, it is occasionally useful to reuse an existing local variable as the iteration variable. This can be done conveniently by adding the keyword `outer`:
"""

# ╔═╡ f130d79a-b5a4-4ed2-a651-7435d39349ba
function f()
     i = 0
     for outer i = 1:3
         # empty
     end
     return i
 end;

# ╔═╡ 011571bf-79e4-4353-b052-2a5d43132185
f()

# ╔═╡ a875e340-3009-46db-b2d0-c9700f605e0e
md"""
## Constants
"""

# ╔═╡ b2a75805-11d5-4782-a746-993771993818
md"""
A common use of variables is giving names to specific, unchanging values. Such variables are only assigned once. This intent can be conveyed to the compiler using the [`const`](@ref) keyword:
"""

# ╔═╡ 410832a7-a090-49b9-84da-b580a6629586
const e  = 2.71828182845904523536;

# ╔═╡ 183468ab-731e-4cb2-a7da-309446a6dd79
const pi = 3.14159265358979323846;

# ╔═╡ 9d316fc8-eb77-455c-8986-ba8d4594906c
md"""
Multiple variables can be declared in a single `const` statement:
"""

# ╔═╡ 3621a71b-de3e-44e7-a640-77477165a8a3
const a, b = 1, 2

# ╔═╡ b5a298ab-1a06-44f6-b047-b63bbcce0288
md"""
The `const` declaration should only be used in global scope on globals. It is difficult for the compiler to optimize code involving global variables, since their values (or even their types) might change at almost any time. If a global variable will not change, adding a `const` declaration solves this performance problem.
"""

# ╔═╡ 3fa525f3-91b6-4efe-a1da-ed8dd7e1a9b8
md"""
Local constants are quite different. The compiler is able to determine automatically when a local variable is constant, so local constant declarations are not necessary, and in fact are currently not supported.
"""

# ╔═╡ e9acb3f0-39df-4232-9cc5-47d9c6d0953b
md"""
Special top-level assignments, such as those performed by the `function` and `struct` keywords, are constant by default.
"""

# ╔═╡ bb8d68c1-f596-4104-9e85-4826d727f2cd
md"""
Note that `const` only affects the variable binding; the variable may be bound to a mutable object (such as an array), and that object may still be modified. Additionally when one tries to assign a value to a variable that is declared constant the following scenarios are possible:
"""

# ╔═╡ 3f8e6327-9a2b-4812-9d08-75843cd5e9be
md"""
  * if a new value has a different type than the type of the constant then an error is thrown:
"""

# ╔═╡ 0948832d-4614-4526-862c-39518a141968
const x = 1.0

# ╔═╡ 656f6c07-478e-4ac4-b2e3-d3bdb6e4b74b
x = 1

# ╔═╡ f1e2b5f7-57a5-400f-b8e8-10aa1026575a
md"""
  * if a new value has the same type as the constant then a warning is printed:
"""

# ╔═╡ 2216685b-5116-4d90-ac9e-fcae2b5ba3f4
const y = 1.0

# ╔═╡ f0e69bc8-93a5-47b8-939c-ad9978baf82e
y = 2.0

# ╔═╡ 8947cbd5-6641-4217-932f-665ad1b762cd
md"""
  * if an assignment would not result in the change of variable value no message is given:
"""

# ╔═╡ ddf82902-e21f-4b47-bbff-f5733470bcd8
const z = 100

# ╔═╡ 13c1d468-f6be-4250-8c61-32b2602fa649
z = 100

# ╔═╡ ec093988-1ad1-4dcc-9d9f-4d74d6418dcf
md"""
The last rule applies to immutable objects even if the variable binding would change, e.g.:
"""

# ╔═╡ b0ab8023-81f4-4933-8e11-7acb6d5aad04
const s1 = "1"

# ╔═╡ e72fa7a1-18ae-4292-bd97-95edf0d2370f
s2 = "1"

# ╔═╡ e598f599-e5cd-4e64-9f38-cc2a98ebf9dd
pointer.([s1, s2], 1)

# ╔═╡ ff7f945f-06ed-45d1-a950-31f5a9c8cff4
s1 = s2

# ╔═╡ f17c3c31-7112-4e2b-b8a3-634348ddb09f
pointer.([s1, s2], 1)

# ╔═╡ e90cef71-3a09-4b5c-b15e-026d26162d7b
md"""
However, for mutable objects the warning is printed as expected:
"""

# ╔═╡ 246e8a3b-d4ee-4eb9-bb4b-4f430801844f
const a = [1]

# ╔═╡ c3c872e9-6684-47c1-b3a0-6aba1725706f
a = [1]

# ╔═╡ 9c7e3a0b-a8af-4cf1-866e-618d7944ff91
md"""
Note that although sometimes possible, changing the value of a `const` variable is strongly discouraged, and is intended only for convenience during interactive use. Changing constants can cause various problems or unexpected behaviors. For instance, if a method references a constant and is already compiled before the constant is changed, then it might keep using the old value:
"""

# ╔═╡ 032f36f3-4350-48cc-af50-9f2e89456854
const x = 1

# ╔═╡ cd767095-0681-4911-ae85-7dd62da09182
f() = x

# ╔═╡ 3b3189a0-ab0e-465b-a0f6-cc8092160615
f()

# ╔═╡ 802b5cd9-8ae6-4696-9162-4ad96ccfca90
x = 2

# ╔═╡ 2c0ce6d5-fa04-444d-b5a6-03e5310d1f7e
f()

# ╔═╡ Cell order:
# ╟─f44c8733-85c1-4877-a9c6-39600c971e31
# ╟─b220b0aa-9915-459c-9746-750911594eeb
# ╟─684efc27-0763-4de6-aa76-41d1aadf2311
# ╟─9b03afa7-f028-43f4-b214-0b76a51b3d96
# ╟─09cabcf1-56b6-4451-bd1b-335f6bc79711
# ╟─9e7ced20-5fec-4390-866b-c8ed90664f72
# ╟─761868f3-39e4-4c69-bdd5-44053a40a6ef
# ╟─d8de0234-c33d-4e8d-8ce8-318e0399e0de
# ╠═236b2b56-7875-4983-862c-a8a6df019b21
# ╟─346c4c46-210f-4e77-9658-3314f482ef02
# ╠═61c58f3e-20fa-4975-91af-c983b602ec29
# ╠═6ce69d54-3d9e-49a6-b425-78d9b2941919
# ╠═eecd2373-1c38-4f6d-a94e-f67ec5a008ba
# ╟─e4cbdb26-c779-43bc-81cd-84e5ad10844a
# ╟─694f40c6-b695-46d3-92f6-46bc60874f66
# ╟─4109d5bd-7ff6-4a10-9099-b9cbbf4d8252
# ╠═d23cde56-de47-4cae-981c-9775ab2018f6
# ╠═dccad65d-a171-4b7e-a1a7-9d0ac01e50ff
# ╠═bcb519c7-a45b-4ecf-a577-462a6e2726b9
# ╠═2b5c0bd2-fca1-41bc-88dd-cf8242d54340
# ╟─e1105d22-9b38-48fb-aed8-82f113aa8b52
# ╟─f87a689f-1a4f-4a32-9536-73082a768513
# ╟─2900fc89-7d29-41b7-af88-80b2a4a3cd90
# ╟─64dae113-6ed5-47bf-a2bb-b792c32be42b
# ╟─35ef4ca0-cc3e-4a6b-a9df-a712f3defab7
# ╟─c48011be-162e-47a0-a089-692d7818d88c
# ╟─eedc1d3e-8426-48ee-8e8d-0e3d803d987d
# ╟─8d2a208d-29c9-478e-8f13-9a2b8c1251e5
# ╠═b108a0c9-0626-4852-8661-288ceaaef524
# ╠═d03cc383-eea4-4a5b-b3a8-cc3744634071
# ╠═33aa023f-1fb1-40e8-9849-e80272713bbe
# ╟─65dbccb7-2dc8-4ffc-b41a-99d9afe1767c
# ╠═f43c1f00-84da-4cd2-8977-049c3b21ccf3
# ╠═782095d5-c920-4a05-936d-8ecafd0e7c31
# ╠═3f98d87e-27ba-494e-aeff-003f5ab7e4f1
# ╠═67772b18-ff01-4376-9ac5-0aa96fbb7393
# ╟─112824b0-2b61-4fc9-ac2c-d09282184bc4
# ╟─c5c26251-386b-466f-af5b-e14f9696645f
# ╟─aaab0c73-1368-4097-90bb-af16219a28de
# ╟─cedc697c-d908-427f-abc1-0f3220313ed5
# ╠═cb00ce61-a206-44d6-913b-98bb7361a6a4
# ╠═2a93a74f-5a9a-4a50-8601-cd57bd85f737
# ╠═3cc95427-c9fd-49fa-aa27-ce4b288efa29
# ╟─86303da7-735c-4d2a-a703-2d34e315bda2
# ╟─9993e021-287a-4444-ba91-936d2081c626
# ╠═98f78120-6c04-4b0a-9c0e-fb294ead8cc8
# ╠═9588ff2f-f743-41d1-93d8-2236e684c3a2
# ╟─f876f8ea-826b-4a4d-b456-192656b8881c
# ╟─88cfbdd1-6076-4b56-afec-b260b9cb62f6
# ╠═b11542a7-13cc-4f2b-8a5b-6ee65de96eda
# ╠═d546e9d4-b48c-44d3-a27d-78483435c956
# ╟─93e20d7d-91e6-4a0a-a73e-68e596698b55
# ╟─56645dd2-f5d9-4149-82f9-f0d9c99c9f66
# ╟─6e675534-8d08-4afe-b801-91ef0fcffc67
# ╠═17516355-ffd9-4079-a34d-34bfb1be76ed
# ╠═ab4e2c99-9c4c-40b8-8dd3-d067fb2a2e33
# ╠═c897c1f8-c823-4c50-9320-c08927d63c41
# ╠═0096fc7e-bbd7-46e9-9392-19b95fcde205
# ╟─f55ee07d-be9a-45ee-9d88-4f13e6093edb
# ╟─95a71e58-dccb-4381-a269-c2eefeec0470
# ╟─8525eef7-04f5-427b-bc97-98dcd9168fb6
# ╠═6bb3dc54-c35f-425f-927b-078c1a2c203e
# ╠═fc7600a5-498a-4bea-acd6-79233548ac44
# ╟─9963ccdc-77bf-4699-ab43-341de6198f55
# ╟─b927d6d4-99a4-46be-90d0-55a3d0c6330b
# ╟─09bd4927-2293-4f11-9c9f-62987a403d8f
# ╟─14808c61-d337-426b-888f-541214c80636
# ╟─d05e1ab3-a6dc-4ec4-8bf6-bf60c699207c
# ╟─ca8ddaa8-5723-4fb8-83f8-0de136238959
# ╟─dcdacd12-78c8-418a-84e7-d1f365b3f315
# ╟─e2bff0f3-38a2-48e8-b2c5-36bf59e85b96
# ╟─6bbd7560-6938-42fe-857f-e20b875d46b4
# ╟─b8775af6-c21d-47f2-8288-55847ed74fa4
# ╟─c977acac-bdd9-4dd9-84f7-e33b96be4622
# ╟─0f3ebecd-6320-43fa-acec-d56bf16b33b4
# ╟─55a024e3-e514-46b4-95ee-70337e9d69d0
# ╟─e0437065-3bc4-4e14-967c-3b51bc278770
# ╟─c37b06e5-afb8-4125-b218-7599437a6ee7
# ╟─9079ff22-0f1f-4926-9a48-dca4b9e1684a
# ╟─474fa40d-d893-4fc2-b4c1-02c5daf3ce84
# ╟─ca9232eb-80c8-4132-98e9-7645de76f474
# ╟─678193d4-fc55-4bb8-bc37-dbe239a51bb8
# ╟─70619e90-6e20-48f7-b93a-3f6cb56d2569
# ╟─f5b5c93a-d65c-444f-96f1-90d90ce23957
# ╠═2e63cc31-5e6c-4d09-a8a1-55e8bbfc1d39
# ╠═e457f296-46f4-4a16-915e-81d1a358f149
# ╟─ec741b17-0b2c-4d99-a995-b038d70e98bf
# ╠═77b52c82-e9de-49f3-aca9-3fe03ba1ea8c
# ╠═176138a7-fcf3-4e64-a1e8-a537fc2d9e36
# ╠═e1714c04-3fae-4d81-a0b7-9f0919e3f185
# ╠═1a68d999-8724-4ebb-8eb1-5e1605d05578
# ╟─40d8ad32-1a6d-45d3-a478-3d15244a0c1a
# ╠═ff57f218-40d7-48e4-9fe1-125fb1339d29
# ╠═f2d4439f-353e-4bba-962f-560f9d04d5ea
# ╠═30045199-6cf2-4af3-8c63-312958fe4795
# ╠═9088d113-74eb-4533-932a-85fcf09c1cff
# ╟─9e33f6da-31a2-49bb-99d6-217d3763a055
# ╠═1de2cbe3-0d17-46cf-a02c-cbb1a9a875d6
# ╟─c91aabd2-72cc-4713-adbc-5c8725572c5d
# ╟─f28cf116-8be2-4f0e-861c-809d7bce9889
# ╟─169a64bf-a4a6-46e9-a247-08e83bcc6fec
# ╠═7beb71d9-fdf0-4e3d-9ae8-49c610653c62
# ╠═5b5b561a-d368-4586-876b-1d36af730cea
# ╠═1c833359-3ece-449d-973f-70ead9a62c54
# ╠═52454908-44c5-4fbc-a0b3-f9c877eb5bf9
# ╟─46d8328f-761a-4e74-a7d1-0804e615e1c9
# ╠═01402019-0255-4fe7-964a-5b3d953cdad0
# ╠═6a2d5f31-54dc-4a30-a459-baea560333c1
# ╟─fef32557-b599-406e-b1e3-71c123024347
# ╠═f130d79a-b5a4-4ed2-a651-7435d39349ba
# ╠═011571bf-79e4-4353-b052-2a5d43132185
# ╟─a875e340-3009-46db-b2d0-c9700f605e0e
# ╟─b2a75805-11d5-4782-a746-993771993818
# ╠═410832a7-a090-49b9-84da-b580a6629586
# ╠═183468ab-731e-4cb2-a7da-309446a6dd79
# ╟─9d316fc8-eb77-455c-8986-ba8d4594906c
# ╠═3621a71b-de3e-44e7-a640-77477165a8a3
# ╟─b5a298ab-1a06-44f6-b047-b63bbcce0288
# ╟─3fa525f3-91b6-4efe-a1da-ed8dd7e1a9b8
# ╟─e9acb3f0-39df-4232-9cc5-47d9c6d0953b
# ╟─bb8d68c1-f596-4104-9e85-4826d727f2cd
# ╟─3f8e6327-9a2b-4812-9d08-75843cd5e9be
# ╠═0948832d-4614-4526-862c-39518a141968
# ╠═656f6c07-478e-4ac4-b2e3-d3bdb6e4b74b
# ╟─f1e2b5f7-57a5-400f-b8e8-10aa1026575a
# ╠═2216685b-5116-4d90-ac9e-fcae2b5ba3f4
# ╠═f0e69bc8-93a5-47b8-939c-ad9978baf82e
# ╟─8947cbd5-6641-4217-932f-665ad1b762cd
# ╠═ddf82902-e21f-4b47-bbff-f5733470bcd8
# ╠═13c1d468-f6be-4250-8c61-32b2602fa649
# ╟─ec093988-1ad1-4dcc-9d9f-4d74d6418dcf
# ╠═b0ab8023-81f4-4933-8e11-7acb6d5aad04
# ╠═e72fa7a1-18ae-4292-bd97-95edf0d2370f
# ╠═e598f599-e5cd-4e64-9f38-cc2a98ebf9dd
# ╠═ff7f945f-06ed-45d1-a950-31f5a9c8cff4
# ╠═f17c3c31-7112-4e2b-b8a3-634348ddb09f
# ╟─e90cef71-3a09-4b5c-b15e-026d26162d7b
# ╠═246e8a3b-d4ee-4eb9-bb4b-4f430801844f
# ╠═c3c872e9-6684-47c1-b3a0-6aba1725706f
# ╟─9c7e3a0b-a8af-4cf1-866e-618d7944ff91
# ╠═032f36f3-4350-48cc-af50-9f2e89456854
# ╠═cd767095-0681-4911-ae85-7dd62da09182
# ╠═3b3189a0-ab0e-465b-a0f6-cc8092160615
# ╠═802b5cd9-8ae6-4696-9162-4ad96ccfca90
# ╠═2c0ce6d5-fa04-444d-b5a6-03e5310d1f7e
