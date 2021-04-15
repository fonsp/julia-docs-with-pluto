### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03d05a1e-9e19-11eb-241c-09727e6b4206
md"""
# [Modules](@id modules)
"""

# ╔═╡ 03d05a3c-9e19-11eb-2ca7-e38ad3fdbc79
md"""
Modules in Julia help organize code into coherent units. They are delimited syntactically inside `module NameOfModule ... end`, and have the following features:
"""

# ╔═╡ 03d05b2c-9e19-11eb-0a67-838433489224
md"""
1. Modules are separate namespaces, each introducing a new global scope. This is useful, because it allows the same name to be used for different functions or global variables without conflict, as long as they are in separate modules.
2. Modules have facilities for detailed namespace management: each defines a set of names it `export`s, and can import names from other modules with `using` and `import` (we explain these below).
3. Modules can be precompiled for faster loading, and contain code for runtime initialization.
"""

# ╔═╡ 03d05b40-9e19-11eb-0d22-97f33265737a
md"""
Typically, in larger Julia packages you will see module code organized into files, eg
"""

# ╔═╡ 03d05b7c-9e19-11eb-23ea-8f689f85db2c
md"""
```julia
module SomeModule

# export, using, import statements are usually here; we discuss these below

include("file1.jl")
include("file2.jl")

end
```
"""

# ╔═╡ 03d05b90-9e19-11eb-062c-fd21e4c141ff
md"""
Files and file names are mostly unrelated to modules; modules are associated only with module expressions. One can have multiple files per module, and multiple modules per file. `include` behaves as if the contents of the source file were evaluated in its place. In this chapter, we use short and simplified examples, so we won't use `include`.
"""

# ╔═╡ 03d05bae-9e19-11eb-31ed-1f2cf37beafe
md"""
The recommended style is not to indent the body of the module, since that would typically lead to whole files being indented. Also, it is common to use `UpperCamelCase` for module names (just like types), and use the plural form if applicable, especially if the module contains a similarly named identifier, to avoid name clashes. For example,
"""

# ╔═╡ 03d05bd6-9e19-11eb-1db5-71345f885855
md"""
```julia
module FastThings

struct FastThing
    ...
end

end
```
"""

# ╔═╡ 03d05bea-9e19-11eb-3c45-3d22149ba1bb
md"""
## [Namespace management](@id namespace-management)
"""

# ╔═╡ 03d05bfe-9e19-11eb-185b-0f48076b6399
md"""
Namespace management refers to the facilities the language offers for making names in a module available in other modules. We discuss the related concepts and functionality below in detail.
"""

# ╔═╡ 03d05c56-9e19-11eb-2cda-09df70c609da
md"""
### Qualified names
"""

# ╔═╡ 03d05c80-9e19-11eb-3807-a946cbb83ac2
md"""
Names for functions, variables and types in the global scope like `sin`, `ARGS`, and `UnitRange` always belong to a module, called the *parent module*, which can be found interactively with [`parentmodule`](@ref), for example
"""

# ╔═╡ 03d05dfc-9e19-11eb-1a77-fbf3a361bcc3
parentmodule(UnitRange)

# ╔═╡ 03d05e2e-9e19-11eb-01bd-d1bd554713c0
md"""
One can also refer to these names outside their parent module by prefixing them with their module, eg `Base.UnitRange`. This is called a *qualified name*. The parent module may be accessible using a chain of submodules like `Base.Math.sin`, where `Base.Math` is called the *module path*. Due to syntactic ambiguities, qualifying a name that contains only symbols, such as an operator, requires inserting a colon, e.g. `Base.:+`. A small number of operators additionally require parentheses, e.g. `Base.:(==)`.
"""

# ╔═╡ 03d05e4c-9e19-11eb-0478-ab8490836d63
md"""
If a name is qualified, then it is always *accessible*, and in case of a function, it can also have methods added to it by using the qualified name as the function name.
"""

# ╔═╡ 03d05e60-9e19-11eb-3685-813b774977f5
md"""
Within a module, a variable name can be “reserved” without assigning to it by declaring it as `global x`. This prevents name conflicts for globals initialized after load time. The syntax `M.x = y` does not work to assign a global in another module; global assignment is always module-local.
"""

# ╔═╡ 03d05e7e-9e19-11eb-31fe-75be3af5c5ca
md"""
### Export lists
"""

# ╔═╡ 03d05e94-9e19-11eb-283f-87cd3e432806
md"""
Names (referring to functions, types, global variables, and constants) can be added to the *export list* of a module with `export`. Typically, they are at or near the top of the module definition so that readers of the source code can find them easily, as in
"""

# ╔═╡ 03d05ea6-9e19-11eb-3dac-a334cdc612b1
md"""
```julia
module NiceStuff

export nice, DOG

struct Dog end      # singleton type, not exported

const DOG = Dog()   # named instance, exported

nice(x) = "nice $x" # function, exported

end
```
"""

# ╔═╡ 03d05ec6-9e19-11eb-1aae-8be4b253c23d
md"""
but this is just a style suggestion — a module can have multiple `export` statements in arbitrary locations.
"""

# ╔═╡ 03d05ee2-9e19-11eb-2359-f56fb2902a0d
md"""
It is common to export names which form part of the API (application programming interface). In the above code, the export list suggests that users should use `nice` and `DOG`. However, since qualified names always make identifiers accessible, this is just an option for organizing APIs: unlike other languages, Julia has no facilities for truly hiding module internals.
"""

# ╔═╡ 03d05ef8-9e19-11eb-0483-a78043107b10
md"""
Also, some modules don't export names at all. This is usually done if they use common words, such as `derivative`, in their API, which could easily clash with the export lists of other modules. We will see how to manage name clashes below.
"""

# ╔═╡ 03d05f1e-9e19-11eb-0ecb-6b2c52581bce
md"""
### Standalone `using` and `import`
"""

# ╔═╡ 03d05f3c-9e19-11eb-17ee-17d583b284fc
md"""
Possibly the most common way of loading a module is `using ModuleName`. This [loads](@ref code-loading) the code associated with `ModuleName`, and brings
"""

# ╔═╡ 03d05f8c-9e19-11eb-0e2d-cdac9e4601c1
md"""
1. the module name
2. and the elements of the export list into the surrounding global namespace.
"""

# ╔═╡ 03d05faa-9e19-11eb-2a82-7fed748581fc
md"""
Technically, the statement `using ModuleName` means that a module called `ModuleName` will be available for resolving names as needed. When a global variable is encountered that has no definition in the current module, the system will search for it among variables exported by `ModuleName` and use it if it is found there. This means that all uses of that global within the current module will resolve to the definition of that variable in `ModuleName`.
"""

# ╔═╡ 03d05fbe-9e19-11eb-2d89-29ad239f1288
md"""
To continue with our example,
"""

# ╔═╡ 03d05fd2-9e19-11eb-08ef-5feaa4e25181
md"""
```julia
using NiceStuff
```
"""

# ╔═╡ 03d05ff0-9e19-11eb-019b-b78004b2edb0
md"""
would load the above code, making `NiceStuff` (the module name), `DOG` and `nice` available. `Dog` is not on the export list, but it can be accessed if the name is qualified with the module path (which here is just the module name) as `NiceStuff.Dog`.
"""

# ╔═╡ 03d06018-9e19-11eb-1cbb-8b63774b7d48
md"""
Importantly, **`using ModuleName` is the only form for which export lists matter at all**.
"""

# ╔═╡ 03d06036-9e19-11eb-0aa5-f732067df3cf
md"""
In contrast,
"""

# ╔═╡ 03d0604a-9e19-11eb-179f-5151c5be9176
md"""
```julia
import NiceStuff
```
"""

# ╔═╡ 03d06072-9e19-11eb-15b0-21828156b442
md"""
brings *only* the module name into scope. Users would need to use `NiceStuff.DOG`, `NiceStuff.Dog`, and `NiceStuff.nice` to access its contents. Usually, `import ModuleName` is used in contexts when the user wants to keep the namespace clean. As we will see in the next section `import NiceStuff` is equivalent to `using NiceStuff: NiceStuff`.
"""

# ╔═╡ 03d06086-9e19-11eb-1a30-dfd84bf52375
md"""
You can combine multiple `using` and `import` statements of the same kind in a comma-separated expression, e.g.
"""

# ╔═╡ 03d0609a-9e19-11eb-1dde-795ef17a3d2c
md"""
```julia
using LinearAlgebra, Statistics
```
"""

# ╔═╡ 03d060c0-9e19-11eb-2ccf-ed5eebb7ccbf
md"""
### `using` and `import` with specific identifiers, and adding methods
"""

# ╔═╡ 03d060e0-9e19-11eb-1fed-33c9e507c4ed
md"""
When `using ModuleName:` or `import ModuleName:` is followed by a comma-separated list of names, the module is loaded, but *only those specific names are brought into the namespace* by the statement. For example,
"""

# ╔═╡ 03d060f4-9e19-11eb-239e-65d18ce2ccd5
md"""
```julia
using NiceStuff: nice, DOG
```
"""

# ╔═╡ 03d06112-9e19-11eb-3072-c17bafa902e0
md"""
will import the names `nice` and `DOG`.
"""

# ╔═╡ 03d06126-9e19-11eb-22c4-5bff512ca6d1
md"""
Importantly, the module name `NiceStuff` will *not* be in the namespace. If you want to make it accessible, you have to list it explicitly, as
"""

# ╔═╡ 03d0613a-9e19-11eb-121c-25f6afef0a69
md"""
```julia
using NiceStuff: nice, DOG, NiceStuff
```
"""

# ╔═╡ 03d0614e-9e19-11eb-2a3e-ab5276417efd
md"""
Julia has two forms for seemingly the same thing because only `import ModuleName: f` allows adding methods to `f` *without a module path*. That is to say, the following example will give an error:
"""

# ╔═╡ 03d0616c-9e19-11eb-0bc4-6d457ac1af97
md"""
```julia
using NiceStuff: nice
struct Cat end
nice(::Cat) = "nice 😸"
```
"""

# ╔═╡ 03d06176-9e19-11eb-2fa3-effd404d01d2
md"""
This error prevents accidentally adding methods to functions in other modules that you only intended to use.
"""

# ╔═╡ 03d06180-9e19-11eb-0ca5-6ba1e2027b3e
md"""
There are two ways to deal with this. You can always qualify function names with a module path:
"""

# ╔═╡ 03d0619e-9e19-11eb-1a86-81bb86c0153d
md"""
```julia
using NiceStuff
struct Cat end
NiceStuff.nice(::Cat) = "nice 😸"
```
"""

# ╔═╡ 03d061b2-9e19-11eb-298a-692d16504c22
md"""
Alternatively, you can `import` the specific function name:
"""

# ╔═╡ 03d061bc-9e19-11eb-20d8-c3db75a10bef
md"""
```julia
import NiceStuff: nice
struct Cat end
nice(::Cat) = "nice 😸"
```
"""

# ╔═╡ 03d061da-9e19-11eb-3206-0bc094a6d501
md"""
Which one you choose is a matter of style. The first form makes it clear that you are adding a method to a function in another module (remember, that the imports and the method defintion may be in separate files), while the second one is shorter, which is especially convenient if you are defining multiple methods.
"""

# ╔═╡ 03d061f6-9e19-11eb-3a2d-d1237e857e2f
md"""
Once a variable is made visible via `using` or `import`, a module may not create its own variable with the same name. Imported variables are read-only; assigning to a global variable always affects a variable owned by the current module, or else raises an error.
"""

# ╔═╡ 03d0620c-9e19-11eb-110e-6180ff968420
md"""
### Renaming with `as`
"""

# ╔═╡ 03d0623e-9e19-11eb-1093-bf61a75b282d
md"""
An identifier brought into scope by `import` or `using` can be renamed with the keyword `as`. This is useful for working around name conflicts as well as for shortening names. For example, `Base` exports the function name `read`, but the CSV.jl package also provides `CSV.read`. If we are going to invoke CSV reading many times, it would be convenient to drop the `CSV.` qualifier. But then it is ambiguous whether we are referring to `Base.read` or `CSV.read`:
"""

# ╔═╡ 03d06252-9e19-11eb-0503-73073904884e
md"""
```julia
julia> read;

julia> import CSV: read
WARNING: ignoring conflicting import of CSV.read into Main
```
"""

# ╔═╡ 03d0625c-9e19-11eb-01f8-4d9685b2bb39
md"""
Renaming provides a solution:
"""

# ╔═╡ 03d06270-9e19-11eb-1497-650d64fe41b0
md"""
```julia
julia> import CSV: read as rd
```
"""

# ╔═╡ 03d06284-9e19-11eb-1302-57aeed87a32b
md"""
Imported packages themselves can also be renamed:
"""

# ╔═╡ 03d0629a-9e19-11eb-361c-f5a1ae64b90d
md"""
```julia
import BenchmarkTools as BT
```
"""

# ╔═╡ 03d062b6-9e19-11eb-1687-392262daea0e
md"""
`as` works with `using` only when a single identifier is brought into scope. For example `using CSV: read as rd` works, but `using CSV as C` does not, since it operates on all of the exported names in `CSV`.
"""

# ╔═╡ 03d062d4-9e19-11eb-3373-6ffc48f5d1fd
md"""
### Mixing multiple `using` and `import` statements
"""

# ╔═╡ 03d062f2-9e19-11eb-15b3-c184e61e02bb
md"""
When multiple `using` or `import` statements of any of the forms above are used, their effect is combined in the order they appear. For example,
"""

# ╔═╡ 03d062fe-9e19-11eb-246d-1fdea51a316a
md"""
```julia
using NiceStuff         # exported names and the module name
import NiceStuff: nice  # allows adding methods to unqualified functions
```
"""

# ╔═╡ 03d06324-9e19-11eb-2690-9f1216eb1163
md"""
would bring all the exported names of `NiceStuff` and the module name itself into scope, and also allow adding methods to `nice` without prefixing it with a module name.
"""

# ╔═╡ 03d06338-9e19-11eb-19c8-dd675fbfb628
md"""
### Handling name conflicts
"""

# ╔═╡ 03d06342-9e19-11eb-2179-b7d4eab43389
md"""
Consider the situation where two (or more) packages export the same name, as in
"""

# ╔═╡ 03d0635e-9e19-11eb-081f-5f32cd11a4ea
md"""
```julia
module A
export f
f() = 1
end

module B
export f
f() = 2
end
```
"""

# ╔═╡ 03d06374-9e19-11eb-00e8-55b40024ed5c
md"""
The statement `using A, B` works, but when you try to call `f`, you get a warning
"""

# ╔═╡ 03d06388-9e19-11eb-377a-77ae941dba6c
md"""
```julia
WARNING: both B and A export "f"; uses of it in module Main must be qualified
ERROR: LoadError: UndefVarError: f not defined
```
"""

# ╔═╡ 03d0639c-9e19-11eb-1898-4ff786b3bc42
md"""
Here, Julia cannot decide which `f` you are referring to, so you have to make a choice. The following solutions are commonly used:
"""

# ╔═╡ 03d064b4-9e19-11eb-10c5-8584faf80e93
md"""
1. Simply proceed with qualified names like `A.f` and `B.f`. This makes the context clear to the reader of your code, especially if `f` just happens to coincide but has different meaning in various packages. For example, `degree` has various uses in mathematics, the natural sciences, and in everyday life, and these meanings should be kept separate.
2. Use the `as` keyword above to rename one or both identifiers, eg

    ```julia
    using A: f as f
    using B: f as g
    ```

    would make `B.f` available as `g`. Here, we are assuming that you did not use `using A` before, which would have brought `f` into the namespace.
3. When the names in question *do* share a meaning, it is common for one module to import it from another, or have a lightweight “base” package with the sole function of defining an interface like this, which can be used by other packages. It is conventional to have such package names end in `...Base` (which has nothing to do with Julia's `Base` module).
"""

# ╔═╡ 03d064be-9e19-11eb-33c7-0d906420bdcc
md"""
### Default top-level definitions and bare modules
"""

# ╔═╡ 03d06504-9e19-11eb-3be4-d903b66ba3d1
md"""
Modules automatically contain `using Core`, `using Base`, and definitions of the [`eval`](@ref) and [`include`](@ref) functions, which evaluate expressions/files within the global scope of that module.
"""

# ╔═╡ 03d06522-9e19-11eb-0549-05a68be8c7c9
md"""
If these default definitions are not wanted, modules can be defined using the keyword [`baremodule`](@ref) instead (note: `Core` is still imported). In terms of `baremodule`, a standard `module` looks like this:
"""

# ╔═╡ 03d06996-9e19-11eb-0103-3ff80a7355e2
baremodule Mod

using Base

eval(x) = Core.eval(Mod, x)
include(p) = Base.include(Mod, p)

...

# ╔═╡ 03d069aa-9e19-11eb-1146-25c5e3cb87f3
md"""
### Standard modules
"""

# ╔═╡ 03d069d4-9e19-11eb-1ca2-e7d020297350
md"""
There are three important standard modules:
"""

# ╔═╡ 03d06a54-9e19-11eb-0417-79003f3b149c
md"""
  * [`Core`](@ref) contains all functionality "built into" the language.
  * [`Base`](@ref) contains basic functionality that is useful in almost all cases.
  * [`Main`](@ref) is the top-level module and the current module, when Julia is started.
"""

# ╔═╡ 03d06acc-9e19-11eb-2fee-19d8598a8c02
md"""
!!! note "Standard library modules"
    By default Julia ships with some standard library modules. These behave like regular Julia packages except that you don't need to install them explicitly. For example, if you wanted to perform some unit testing, you could load the `Test` standard library as follows:

    ```julia
    using Test
    ```
"""

# ╔═╡ 03d06aea-9e19-11eb-08ce-a79c2d10ea6a
md"""
## Submodules and relative paths
"""

# ╔═╡ 03d06b12-9e19-11eb-1dbc-b38e3100e6c4
md"""
Modules can contain *submodules*, nesting the same syntax `module ... end`. They can be used to introduce separate namespaces, which can be helpful for organizing complex codebases. Note that each `module` introduces its own [scope](@ref scope-of-variables), so submodules do not automatically “inherit” names from their parent.
"""

# ╔═╡ 03d06b3c-9e19-11eb-1469-85ab24e80265
md"""
It is recommended that submodules refer to other modules within the enclosing parent module (including the latter) using *relative module qualifiers* in `using` and `import` statements. A relative module qualifier starts with a period (`.`), which corresponds to the current module, and each successive `.` leads to the parent of the current module. This should be followed by modules if necessary, and eventually the actual name to access, all separated by `.`s.
"""

# ╔═╡ 03d06b4e-9e19-11eb-06ec-b9d7105e0472
md"""
Consider the following example, where the submodule `SubA` defines a function, which is then extended in its “sibling” module:
"""

# ╔═╡ 03d06b6a-9e19-11eb-0929-8b8907adda47
md"""
```julia
module ParentModule

module SubA
export add_D  # exported interface
const D = 3
add_D(x) = x + D
end

using .SubA  # brings `add_D` into the namespace

export add_D # export it from ParentModule too

module SubB
import ..SubA: add_D # relative path for a “sibling” module
struct Infinity end
add_D(x::Infinity) = x
end

end
```
"""

# ╔═╡ 03d06b76-9e19-11eb-2314-21ae69805f5f
md"""
You may see code in packages, which, in a similar situation, uses
"""

# ╔═╡ 03d06b8a-9e19-11eb-061e-fd88d2b2ed46
md"""
```julia
import ParentModule.SubA: add_D
```
"""

# ╔═╡ 03d06bb2-9e19-11eb-170b-ff8b7ee6b255
md"""
However, this operates through [code loading](@ref code-loading), and thus only works if `ParentModule` is in a package. It is better to use relative paths.
"""

# ╔═╡ 03d06bc6-9e19-11eb-21c0-9bdc5fba670c
md"""
Note that the order of definitions also matters if you are evaluating values. Consider
"""

# ╔═╡ 03d06bda-9e19-11eb-04ef-1d54c2c507d2
md"""
```julia
module TestPackage

export x, y

x = 0

module Sub
using ..TestPackage
z = y # ERROR: UndefVarError: y not defined
end

y = 1

end
```
"""

# ╔═╡ 03d06c16-9e19-11eb-3386-6bcf5ba0758a
md"""
where `Sub` is trying to use `TestPackage.y` before it was defined, so it does not have a value.
"""

# ╔═╡ 03d06c2a-9e19-11eb-1d2f-29411af01aa0
md"""
For similar reasons, you cannot use a cyclic ordering:
"""

# ╔═╡ 03d06c40-9e19-11eb-0a53-f1573b10a31c
md"""
```julia
module A

module B
using ..C # ERROR: UndefVarError: C not defined
end

module C
using ..B
end

end
```
"""

# ╔═╡ 03d06c52-9e19-11eb-18c3-9dcf4dfb4dd4
md"""
### Module initialization and precompilation
"""

# ╔═╡ 03d06c66-9e19-11eb-10aa-2bcf9ea25eca
md"""
Large modules can take several seconds to load because executing all of the statements in a module often involves compiling a large amount of code. Julia creates precompiled caches of the module to reduce this time.
"""

# ╔═╡ 03d06c8e-9e19-11eb-3fdc-d3cdff4bc873
md"""
The incremental precompiled module file are created and used automatically when using `import` or `using` to load a module.  This will cause it to be automatically compiled the first time it is imported. Alternatively, you can manually call [`Base.compilecache(modulename)`](@ref). The resulting cache files will be stored in `DEPOT_PATH[1]/compiled/`. Subsequently, the module is automatically recompiled upon `using` or `import` whenever any of its dependencies change; dependencies are modules it imports, the Julia build, files it includes, or explicit dependencies declared by [`include_dependency(path)`](@ref) in the module file(s).
"""

# ╔═╡ 03d06cb6-9e19-11eb-3482-c76ff2d364f5
md"""
For file dependencies, a change is determined by examining whether the modification time (`mtime`) of each file loaded by `include` or added explicitly by `include_dependency` is unchanged, or equal to the modification time truncated to the nearest second (to accommodate systems that can't copy mtime with sub-second accuracy). It also takes into account whether the path to the file chosen by the search logic in `require` matches the path that had created the precompile file. It also takes into account the set of dependencies already loaded into the current process and won't recompile those modules, even if their files change or disappear, in order to avoid creating incompatibilities between the running system and the precompile cache.
"""

# ╔═╡ 03d06cd2-9e19-11eb-387e-9714aef89a3f
md"""
If you know that a module is *not* safe to precompile your module (for example, for one of the reasons described below), you should put `__precompile__(false)` in the module file (typically placed at the top). This will cause `Base.compilecache` to throw an error, and will cause `using` / `import` to load it directly into the current process and skip the precompile and caching. This also thereby prevents the module from being imported by any other precompiled module.
"""

# ╔═╡ 03d06cfc-9e19-11eb-3331-b57a27005888
md"""
You may need to be aware of certain behaviors inherent in the creation of incremental shared libraries which may require care when writing your module. For example, external state is not preserved. To accommodate this, explicitly separate any initialization steps that must occur at *runtime* from steps that can occur at *compile time*. For this purpose, Julia allows you to define an `__init__()` function in your module that executes any initialization steps that must occur at runtime. This function will not be called during compilation (`--output-*`). Effectively, you can assume it will be run exactly once in the lifetime of the code. You may, of course, call it manually if necessary, but the default is to assume this function deals with computing state for the local machine, which does not need to be – or even should not be – captured in the compiled image. It will be called after the module is loaded into a process, including if it is being loaded into an incremental compile (`--output-incremental=yes`), but not if it is being loaded into a full-compilation process.
"""

# ╔═╡ 03d06d2e-9e19-11eb-36e2-abe2cc9096dc
md"""
In particular, if you define a `function __init__()` in a module, then Julia will call `__init__()` immediately *after* the module is loaded (e.g., by `import`, `using`, or `require`) at runtime for the *first* time (i.e., `__init__` is only called once, and only after all statements in the module have been executed). Because it is called after the module is fully imported, any submodules or other imported modules have their `__init__` functions called *before* the `__init__` of the enclosing module.
"""

# ╔═╡ 03d06d56-9e19-11eb-333e-6378f9bb6bae
md"""
Two typical uses of `__init__` are calling runtime initialization functions of external C libraries and initializing global constants that involve pointers returned by external libraries.  For example, suppose that we are calling a C library `libfoo` that requires us to call a `foo_init()` initialization function at runtime. Suppose that we also want to define a global constant `foo_data_ptr` that holds the return value of a `void *foo_data()` function defined by `libfoo` – this constant must be initialized at runtime (not at compile time) because the pointer address will change from run to run.  You could accomplish this by defining the following `__init__` function in your module:
"""

# ╔═╡ 03d06d6a-9e19-11eb-2977-9ffe03c5f8a9
md"""
```julia
const foo_data_ptr = Ref{Ptr{Cvoid}}(0)
function __init__()
    ccall((:foo_init, :libfoo), Cvoid, ())
    foo_data_ptr[] = ccall((:foo_data, :libfoo), Ptr{Cvoid}, ())
    nothing
end
```
"""

# ╔═╡ 03d06d88-9e19-11eb-3166-27f1ccabd9cc
md"""
Notice that it is perfectly possible to define a global inside a function like `__init__`; this is one of the advantages of using a dynamic language. But by making it a constant at global scope, we can ensure that the type is known to the compiler and allow it to generate better optimized code. Obviously, any other globals in your module that depends on `foo_data_ptr` would also have to be initialized in `__init__`.
"""

# ╔═╡ 03d06dce-9e19-11eb-2c2b-fd822ef203ac
md"""
Constants involving most Julia objects that are not produced by [`ccall`](@ref) do not need to be placed in `__init__`: their definitions can be precompiled and loaded from the cached module image. This includes complicated heap-allocated objects like arrays. However, any routine that returns a raw pointer value must be called at runtime for precompilation to work ([`Ptr`](@ref) objects will turn into null pointers unless they are hidden inside an [`isbits`](@ref) object). This includes the return values of the Julia functions [`@cfunction`](@ref) and [`pointer`](@ref).
"""

# ╔═╡ 03d06df6-9e19-11eb-12ad-5b8263ee3d74
md"""
Dictionary and set types, or in general anything that depends on the output of a `hash(key)` method, are a trickier case.  In the common case where the keys are numbers, strings, symbols, ranges, `Expr`, or compositions of these types (via arrays, tuples, sets, pairs, etc.) they are safe to precompile.  However, for a few other key types, such as `Function` or `DataType` and generic user-defined types where you haven't defined a `hash` method, the fallback `hash` method depends on the memory address of the object (via its `objectid`) and hence may change from run to run. If you have one of these key types, or if you aren't sure, to be safe you can initialize this dictionary from within your `__init__` function. Alternatively, you can use the [`IdDict`](@ref) dictionary type, which is specially handled by precompilation so that it is safe to initialize at compile-time.
"""

# ╔═╡ 03d06e0c-9e19-11eb-3e37-7f62d7be1e22
md"""
When using precompilation, it is important to keep a clear sense of the distinction between the compilation phase and the execution phase. In this mode, it will often be much more clearly apparent that Julia is a compiler which allows execution of arbitrary Julia code, not a standalone interpreter that also generates compiled code.
"""

# ╔═╡ 03d06e1e-9e19-11eb-36b6-79a34911a891
md"""
Other known potential failure scenarios include:
"""

# ╔═╡ 03d06fae-9e19-11eb-2465-5920a7e4ae43
md"""
1. Global counters (for example, for attempting to uniquely identify objects). Consider the following code snippet:

    ```julia
    mutable struct UniquedById
        myid::Int
        let counter = 0
            UniquedById() = new(counter += 1)
        end
    end
    ```

    while the intent of this code was to give every instance a unique id, the counter value is recorded at the end of compilation. All subsequent usages of this incrementally compiled module will start from that same counter value.

    Note that `objectid` (which works by hashing the memory pointer) has similar issues (see notes on `Dict` usage below).

    One alternative is to use a macro to capture [`@__MODULE__`](@ref) and store it alone with the current `counter` value, however, it may be better to redesign the code to not depend on this global state.
2. Associative collections (such as `Dict` and `Set`) need to be re-hashed in `__init__`. (In the future, a mechanism may be provided to register an initializer function.)
3. Depending on compile-time side-effects persisting through load-time. Example include: modifying arrays or other variables in other Julia modules; maintaining handles to open files or devices; storing pointers to other system resources (including memory);
4. Creating accidental "copies" of global state from another module, by referencing it directly instead of via its lookup path. For example, (in global scope):

    ```julia
    #mystdout = Base.stdout #= will not work correctly, since this will copy Base.stdout into this module =#
    # instead use accessor functions:
    getstdout() = Base.stdout #= best option =#
    # or move the assignment into the runtime:
    __init__() = global mystdout = Base.stdout #= also works =#
    ```
"""

# ╔═╡ 03d06fc2-9e19-11eb-2603-fbf888957acc
md"""
Several additional restrictions are placed on the operations that can be done while precompiling code to help the user avoid other wrong-behavior situations:
"""

# ╔═╡ 03d0704e-9e19-11eb-0e5c-8903a68d5191
md"""
1. Calling [`eval`](@ref) to cause a side-effect in another module. This will also cause a warning to be emitted when the incremental precompile flag is set.
2. `global const` statements from local scope after `__init__()` has been started (see issue #12010 for plans to add an error for this)
3. Replacing a module is a runtime error while doing an incremental precompile.
"""

# ╔═╡ 03d07062-9e19-11eb-317c-3b23fc59ce06
md"""
A few other points to be aware of:
"""

# ╔═╡ 03d07170-9e19-11eb-0df3-73a1785ddd49
md"""
1. No code reload / cache invalidation is performed after changes are made to the source files themselves, (including by `Pkg.update`), and no cleanup is done after `Pkg.rm`
2. The memory sharing behavior of a reshaped array is disregarded by precompilation (each view gets its own copy)
3. Expecting the filesystem to be unchanged between compile-time and runtime e.g. [`@__FILE__`](@ref)/`source_path()` to find resources at runtime, or the BinDeps `@checked_lib` macro. Sometimes this is unavoidable. However, when possible, it can be good practice to copy resources into the module at compile-time so they won't need to be found at runtime.
4. `WeakRef` objects and finalizers are not currently handled properly by the serializer (this will be fixed in an upcoming release).
5. It is usually best to avoid capturing references to instances of internal metadata objects such as `Method`, `MethodInstance`, `MethodTable`, `TypeMapLevel`, `TypeMapEntry` and fields of those objects, as this can confuse the serializer and may not lead to the outcome you desire. It is not necessarily an error to do this, but you simply need to be prepared that the system will try to copy some of these and to create a single unique instance of others.
"""

# ╔═╡ 03d071a2-9e19-11eb-1ed5-b1e5fe04c5ec
md"""
It is sometimes helpful during module development to turn off incremental precompilation. The command line flag `--compiled-modules={yes|no}` enables you to toggle module precompilation on and off. When Julia is started with `--compiled-modules=no` the serialized modules in the compile cache are ignored when loading modules and module dependencies. `Base.compilecache` can still be called manually. The state of this command line flag is passed to `Pkg.build` to disable automatic precompilation triggering when installing, updating, and explicitly building packages.
"""

# ╔═╡ Cell order:
# ╟─03d05a1e-9e19-11eb-241c-09727e6b4206
# ╟─03d05a3c-9e19-11eb-2ca7-e38ad3fdbc79
# ╟─03d05b2c-9e19-11eb-0a67-838433489224
# ╟─03d05b40-9e19-11eb-0d22-97f33265737a
# ╟─03d05b7c-9e19-11eb-23ea-8f689f85db2c
# ╟─03d05b90-9e19-11eb-062c-fd21e4c141ff
# ╟─03d05bae-9e19-11eb-31ed-1f2cf37beafe
# ╟─03d05bd6-9e19-11eb-1db5-71345f885855
# ╟─03d05bea-9e19-11eb-3c45-3d22149ba1bb
# ╟─03d05bfe-9e19-11eb-185b-0f48076b6399
# ╟─03d05c56-9e19-11eb-2cda-09df70c609da
# ╟─03d05c80-9e19-11eb-3807-a946cbb83ac2
# ╠═03d05dfc-9e19-11eb-1a77-fbf3a361bcc3
# ╟─03d05e2e-9e19-11eb-01bd-d1bd554713c0
# ╟─03d05e4c-9e19-11eb-0478-ab8490836d63
# ╟─03d05e60-9e19-11eb-3685-813b774977f5
# ╟─03d05e7e-9e19-11eb-31fe-75be3af5c5ca
# ╟─03d05e94-9e19-11eb-283f-87cd3e432806
# ╟─03d05ea6-9e19-11eb-3dac-a334cdc612b1
# ╟─03d05ec6-9e19-11eb-1aae-8be4b253c23d
# ╟─03d05ee2-9e19-11eb-2359-f56fb2902a0d
# ╟─03d05ef8-9e19-11eb-0483-a78043107b10
# ╟─03d05f1e-9e19-11eb-0ecb-6b2c52581bce
# ╟─03d05f3c-9e19-11eb-17ee-17d583b284fc
# ╟─03d05f8c-9e19-11eb-0e2d-cdac9e4601c1
# ╟─03d05faa-9e19-11eb-2a82-7fed748581fc
# ╟─03d05fbe-9e19-11eb-2d89-29ad239f1288
# ╟─03d05fd2-9e19-11eb-08ef-5feaa4e25181
# ╟─03d05ff0-9e19-11eb-019b-b78004b2edb0
# ╟─03d06018-9e19-11eb-1cbb-8b63774b7d48
# ╟─03d06036-9e19-11eb-0aa5-f732067df3cf
# ╟─03d0604a-9e19-11eb-179f-5151c5be9176
# ╟─03d06072-9e19-11eb-15b0-21828156b442
# ╟─03d06086-9e19-11eb-1a30-dfd84bf52375
# ╟─03d0609a-9e19-11eb-1dde-795ef17a3d2c
# ╟─03d060c0-9e19-11eb-2ccf-ed5eebb7ccbf
# ╟─03d060e0-9e19-11eb-1fed-33c9e507c4ed
# ╟─03d060f4-9e19-11eb-239e-65d18ce2ccd5
# ╟─03d06112-9e19-11eb-3072-c17bafa902e0
# ╟─03d06126-9e19-11eb-22c4-5bff512ca6d1
# ╟─03d0613a-9e19-11eb-121c-25f6afef0a69
# ╟─03d0614e-9e19-11eb-2a3e-ab5276417efd
# ╟─03d0616c-9e19-11eb-0bc4-6d457ac1af97
# ╟─03d06176-9e19-11eb-2fa3-effd404d01d2
# ╟─03d06180-9e19-11eb-0ca5-6ba1e2027b3e
# ╟─03d0619e-9e19-11eb-1a86-81bb86c0153d
# ╟─03d061b2-9e19-11eb-298a-692d16504c22
# ╟─03d061bc-9e19-11eb-20d8-c3db75a10bef
# ╟─03d061da-9e19-11eb-3206-0bc094a6d501
# ╟─03d061f6-9e19-11eb-3a2d-d1237e857e2f
# ╟─03d0620c-9e19-11eb-110e-6180ff968420
# ╟─03d0623e-9e19-11eb-1093-bf61a75b282d
# ╟─03d06252-9e19-11eb-0503-73073904884e
# ╟─03d0625c-9e19-11eb-01f8-4d9685b2bb39
# ╟─03d06270-9e19-11eb-1497-650d64fe41b0
# ╟─03d06284-9e19-11eb-1302-57aeed87a32b
# ╟─03d0629a-9e19-11eb-361c-f5a1ae64b90d
# ╟─03d062b6-9e19-11eb-1687-392262daea0e
# ╟─03d062d4-9e19-11eb-3373-6ffc48f5d1fd
# ╟─03d062f2-9e19-11eb-15b3-c184e61e02bb
# ╟─03d062fe-9e19-11eb-246d-1fdea51a316a
# ╟─03d06324-9e19-11eb-2690-9f1216eb1163
# ╟─03d06338-9e19-11eb-19c8-dd675fbfb628
# ╟─03d06342-9e19-11eb-2179-b7d4eab43389
# ╟─03d0635e-9e19-11eb-081f-5f32cd11a4ea
# ╟─03d06374-9e19-11eb-00e8-55b40024ed5c
# ╟─03d06388-9e19-11eb-377a-77ae941dba6c
# ╟─03d0639c-9e19-11eb-1898-4ff786b3bc42
# ╟─03d064b4-9e19-11eb-10c5-8584faf80e93
# ╟─03d064be-9e19-11eb-33c7-0d906420bdcc
# ╟─03d06504-9e19-11eb-3be4-d903b66ba3d1
# ╟─03d06522-9e19-11eb-0549-05a68be8c7c9
# ╠═03d06996-9e19-11eb-0103-3ff80a7355e2
# ╟─03d069aa-9e19-11eb-1146-25c5e3cb87f3
# ╟─03d069d4-9e19-11eb-1ca2-e7d020297350
# ╟─03d06a54-9e19-11eb-0417-79003f3b149c
# ╟─03d06acc-9e19-11eb-2fee-19d8598a8c02
# ╟─03d06aea-9e19-11eb-08ce-a79c2d10ea6a
# ╟─03d06b12-9e19-11eb-1dbc-b38e3100e6c4
# ╟─03d06b3c-9e19-11eb-1469-85ab24e80265
# ╟─03d06b4e-9e19-11eb-06ec-b9d7105e0472
# ╟─03d06b6a-9e19-11eb-0929-8b8907adda47
# ╟─03d06b76-9e19-11eb-2314-21ae69805f5f
# ╟─03d06b8a-9e19-11eb-061e-fd88d2b2ed46
# ╟─03d06bb2-9e19-11eb-170b-ff8b7ee6b255
# ╟─03d06bc6-9e19-11eb-21c0-9bdc5fba670c
# ╟─03d06bda-9e19-11eb-04ef-1d54c2c507d2
# ╟─03d06c16-9e19-11eb-3386-6bcf5ba0758a
# ╟─03d06c2a-9e19-11eb-1d2f-29411af01aa0
# ╟─03d06c40-9e19-11eb-0a53-f1573b10a31c
# ╟─03d06c52-9e19-11eb-18c3-9dcf4dfb4dd4
# ╟─03d06c66-9e19-11eb-10aa-2bcf9ea25eca
# ╟─03d06c8e-9e19-11eb-3fdc-d3cdff4bc873
# ╟─03d06cb6-9e19-11eb-3482-c76ff2d364f5
# ╟─03d06cd2-9e19-11eb-387e-9714aef89a3f
# ╟─03d06cfc-9e19-11eb-3331-b57a27005888
# ╟─03d06d2e-9e19-11eb-36e2-abe2cc9096dc
# ╟─03d06d56-9e19-11eb-333e-6378f9bb6bae
# ╟─03d06d6a-9e19-11eb-2977-9ffe03c5f8a9
# ╟─03d06d88-9e19-11eb-3166-27f1ccabd9cc
# ╟─03d06dce-9e19-11eb-2c2b-fd822ef203ac
# ╟─03d06df6-9e19-11eb-12ad-5b8263ee3d74
# ╟─03d06e0c-9e19-11eb-3e37-7f62d7be1e22
# ╟─03d06e1e-9e19-11eb-36b6-79a34911a891
# ╟─03d06fae-9e19-11eb-2465-5920a7e4ae43
# ╟─03d06fc2-9e19-11eb-2603-fbf888957acc
# ╟─03d0704e-9e19-11eb-0e5c-8903a68d5191
# ╟─03d07062-9e19-11eb-317c-3b23fc59ce06
# ╟─03d07170-9e19-11eb-0df3-73a1785ddd49
# ╟─03d071a2-9e19-11eb-1ed5-b1e5fe04c5ec
