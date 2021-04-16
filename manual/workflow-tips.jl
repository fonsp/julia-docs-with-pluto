### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ e21ada18-53c0-4224-9389-1817321a7dba
md"""
# [Workflow Tips](@id man-workflow-tips)
"""

# ╔═╡ 172e5816-4e33-47d0-a76d-e218278fbb1f
md"""
Here are some tips for working with Julia efficiently.
"""

# ╔═╡ fdd219fd-baf7-4507-a1cd-84c10718f914
md"""
## REPL-based workflow
"""

# ╔═╡ 10e9f46c-763d-4b45-a7f0-736328c3391a
md"""
As already elaborated in [The Julia REPL](@ref), Julia's REPL provides rich functionality that facilitates an efficient interactive workflow. Here are some tips that might further enhance your experience at the command line.
"""

# ╔═╡ ce79f781-43a8-486b-b4e0-8d93b706a61e
md"""
### A basic editor/REPL workflow
"""

# ╔═╡ 4c1a7880-9105-495c-bc8c-e5b5b8dd1d0f
md"""
The most basic Julia workflows involve using a text editor in conjunction with the `julia` command line. A common pattern includes the following elements:
"""

# ╔═╡ a76be422-f698-4076-a8e8-c4072197bd38
md"""
  * **Put code under development in a temporary module.** Create a file, say `Tmp.jl`, and include within it

    ```julia
    module Tmp
    export say_hello

    say_hello() = println(\"Hello!\")

    # your other definitions here

    end
    ```
  * **Put your test code in another file.** Create another file, say `tst.jl`, which looks like

    ```julia
    include(\"Tmp.jl\")
    import .Tmp
    # using .Tmp # we can use `using` to bring the exported symbols in `Tmp` into our namespace

    Tmp.say_hello()
    # say_hello()

    # your other test code here
    ```

    and includes tests for the contents of `Tmp`. Alternatively, you can wrap the contents of your test file in a module, as

    ```julia
    module Tst
        include(\"Tmp.jl\")
        import .Tmp
        #using .Tmp

        Tmp.say_hello()
        # say_hello()

        # your other test code here
    end
    ```

    The advantage is that your testing code is now contained in a module and does not use the global scope in `Main` for definitions, which is a bit more tidy.
  * `include` the `tst.jl` file in the Julia REPL with `include(\"tst.jl\")`.
  * **Lather. Rinse. Repeat.** Explore ideas at the `julia` command prompt. Save good ideas in `tst.jl`. To execute `tst.jl` after it has been changed, just `include` it again.
"""

# ╔═╡ e8e02139-f8cd-43d7-9ce4-3393442a5cd5
md"""
## Browser-based workflow
"""

# ╔═╡ 2fb9f6e0-251e-4e28-ac17-3bc92bdd4d82
md"""
It is also possible to interact with a Julia REPL in the browser via [IJulia](https://github.com/JuliaLang/IJulia.jl). See the package home for details.
"""

# ╔═╡ 0090f62e-2ca0-47f1-8a99-09ee8bf79229
md"""
## Revise-based workflows
"""

# ╔═╡ 0ea71662-2dec-4d08-8265-84296d2298e3
md"""
Whether you're at the REPL or in IJulia, you can typically improve your development experience with [Revise](https://github.com/timholy/Revise.jl). It is common to configure Revise to start whenever julia is started, as per the instructions in the [Revise documentation](https://timholy.github.io/Revise.jl/stable/). Once configured, Revise will track changes to files in any loaded modules, and to any files loaded in to the REPL with `includet` (but not with plain `include`); you can then edit the files and the changes take effect without restarting your julia session. A standard workflow is similar to the REPL-based workflow above, with the following modifications:
"""

# ╔═╡ d58da8a2-6b1a-4a99-8586-a55c17f73244
md"""
1. Put your code in a module somewhere on your load path. There are several options for achieving this, of which two recommended choices are:

      * For long-term projects, use [PkgTemplates](https://github.com/invenia/PkgTemplates.jl):

        ```julia
        using PkgTemplates
        t = Template()
        t(\"MyPkg\")
        ```

        This will create a blank package, `\"MyPkg\"`, in your `.julia/dev` directory. Note that PkgTemplates allows you to control many different options through its `Template` constructor.

        In step 2 below, edit `MyPkg/src/MyPkg.jl` to change the source code, and `MyPkg/test/runtests.jl` for the tests.
      * For \"throw-away\" projects, you can avoid any need for cleanup by doing your work in your temporary directory (e.g., `/tmp`).

        Navigate to your temporary directory and launch Julia, then do the following:

        ```julia
        pkg> generate MyPkg            # type ] to enter pkg mode
        julia> push!(LOAD_PATH, pwd())   # hit backspace to exit pkg mode
        ```

        If you restart your Julia session you'll have to re-issue that command modifying `LOAD_PATH`.

        In step 2 below, edit `MyPkg/src/MyPkg.jl` to change the source code, and create any test file of your choosing.
2. Develop your package

    *Before* loading any code, make sure you're running Revise: say `using Revise` or follow its documentation on configuring it to run automatically.

    Then navigate to the directory containing your test file (here assumed to be `\"runtests.jl\"`) and do the following:

    ```julia
    julia> using MyPkg

    julia> include(\"runtests.jl\")
    ```

    You can iteratively modify the code in MyPkg in your editor and re-run the tests with `include(\"runtests.jl\")`.  You generally should not need to restart your Julia session to see the changes take effect (subject to a few [limitations](https://timholy.github.io/Revise.jl/stable/limitations/)).
"""

# ╔═╡ Cell order:
# ╟─e21ada18-53c0-4224-9389-1817321a7dba
# ╟─172e5816-4e33-47d0-a76d-e218278fbb1f
# ╟─fdd219fd-baf7-4507-a1cd-84c10718f914
# ╟─10e9f46c-763d-4b45-a7f0-736328c3391a
# ╟─ce79f781-43a8-486b-b4e0-8d93b706a61e
# ╟─4c1a7880-9105-495c-bc8c-e5b5b8dd1d0f
# ╟─a76be422-f698-4076-a8e8-c4072197bd38
# ╟─e8e02139-f8cd-43d7-9ce4-3393442a5cd5
# ╟─2fb9f6e0-251e-4e28-ac17-3bc92bdd4d82
# ╟─0090f62e-2ca0-47f1-8a99-09ee8bf79229
# ╟─0ea71662-2dec-4d08-8265-84296d2298e3
# ╟─d58da8a2-6b1a-4a99-8586-a55c17f73244
