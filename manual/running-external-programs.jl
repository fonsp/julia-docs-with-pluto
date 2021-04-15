### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03d57800-9e19-11eb-3b55-c1438963bce4
md"""
# Running External Programs
"""

# ╔═╡ 03d5780a-9e19-11eb-2f49-efb674222651
md"""
Julia borrows backtick notation for commands from the shell, Perl, and Ruby. However, in Julia, writing
"""

# ╔═╡ 03d57936-9e19-11eb-196e-67899fc4c42d
`echo hello`

# ╔═╡ 03d5795e-9e19-11eb-010a-d3cbf18d7f83
md"""
differs in several aspects from the behavior in various shells, Perl, or Ruby:
"""

# ╔═╡ 03d57a3a-9e19-11eb-2c94-1902f341f9e9
md"""
  * Instead of immediately running the command, backticks create a [`Cmd`](@ref) object to represent the command. You can use this object to connect the command to others via pipes, [`run`](@ref) it, and [`read`](@ref) or [`write`](@ref) to it.
  * When the command is run, Julia does not capture its output unless you specifically arrange for it to. Instead, the output of the command by default goes to [`stdout`](@ref) as it would using `libc`'s `system` call.
  * The command is never run with a shell. Instead, Julia parses the command syntax directly, appropriately interpolating variables and splitting on words as the shell would, respecting shell quoting syntax. The command is run as `julia`'s immediate child process, using `fork` and `exec` calls.
"""

# ╔═╡ 03d57b5c-9e19-11eb-2ba7-a7510a0369b1
md"""
!!! note
    The following assumes a Posix environment as on Linux or MacOS. On Windows, many similar commands, such as `echo` and `dir`, are not external programs and instead are built into the shell `cmd.exe` itself. One option to run these commands is to invoke `cmd.exe`, for example `cmd /C echo hello`. Alternatively Julia can be run inside a Posix environment such as Cygwin.
"""

# ╔═╡ 03d57b70-9e19-11eb-1fb4-5d93551b7bed
md"""
Here's a simple example of running an external program:
"""

# ╔═╡ 03d57e40-9e19-11eb-0485-bd195d80f67b
mycommand = `echo hello`

# ╔═╡ 03d57e40-9e19-11eb-0587-bb4095c63ad5
typeof(mycommand)

# ╔═╡ 03d57e40-9e19-11eb-1a85-53ffdb5de6ab
run(mycommand);

# ╔═╡ 03d57e72-9e19-11eb-0e35-afb2c68d0df7
md"""
The `hello` is the output of the `echo` command, sent to [`stdout`](@ref). The run method itself returns `nothing`, and throws an [`ErrorException`](@ref) if the external command fails to run successfully.
"""

# ╔═╡ 03d57e9a-9e19-11eb-34e4-f79bb23144c0
md"""
If you want to read the output of the external command, [`read`](@ref) or [`readchomp`](@ref) can be used instead:
"""

# ╔═╡ 03d580c2-9e19-11eb-2d41-c74ebaa36683
read(`echo hello`, String)

# ╔═╡ 03d580d4-9e19-11eb-0bd6-8d228dd19bce
readchomp(`echo hello`)

# ╔═╡ 03d580e8-9e19-11eb-301b-6beba8af1a9c
md"""
More generally, you can use [`open`](@ref) to read from or write to an external command.
"""

# ╔═╡ 03d58610-9e19-11eb-0968-3bc18fbf9aa8
open(`less`, "w", stdout) do io
           for i = 1:3
               println(io, i)
           end
       end

# ╔═╡ 03d58624-9e19-11eb-3344-b9790db013b5
md"""
The program name and the individual arguments in a command can be accessed and iterated over as if the command were an array of strings:
"""

# ╔═╡ 03d58854-9e19-11eb-2fa9-79fc11084fd4
collect(`echo "foo bar"`)

# ╔═╡ 03d58854-9e19-11eb-13dc-d9ed4269785c
`echo "foo bar"`[2]

# ╔═╡ 03d58886-9e19-11eb-2693-83778af8ee13
md"""
## [Interpolation](@id command-interpolation)
"""

# ╔═╡ 03d588a4-9e19-11eb-0709-ebb4326147db
md"""
Suppose you want to do something a bit more complicated and use the name of a file in the variable `file` as an argument to a command. You can use `$` for interpolation much as you would in a string literal (see [Strings](@ref)):
"""

# ╔═╡ 03d58a36-9e19-11eb-2486-83324d1c6394
file = "/etc/passwd"

# ╔═╡ 03d58a3e-9e19-11eb-17f5-952c0f7f81ff
`sort $file`

# ╔═╡ 03d58a5c-9e19-11eb-3f12-1fafcccd480c
md"""
A common pitfall when running external programs via a shell is that if a file name contains characters that are special to the shell, they may cause undesirable behavior. Suppose, for example, rather than `/etc/passwd`, we wanted to sort the contents of the file `/Volumes/External HD/data.csv`. Let's try it:
"""

# ╔═╡ 03d58c0a-9e19-11eb-29b5-c1fdae0a0894
file = "/Volumes/External HD/data.csv"

# ╔═╡ 03d58c14-9e19-11eb-20ff-c7173306a8b4
`sort $file`

# ╔═╡ 03d58c30-9e19-11eb-2aa7-dfb654ef83bc
md"""
How did the file name get quoted? Julia knows that `file` is meant to be interpolated as a single argument, so it quotes the word for you. Actually, that is not quite accurate: the value of `file` is never interpreted by a shell, so there's no need for actual quoting; the quotes are inserted only for presentation to the user. This will even work if you interpolate a value as part of a shell word:
"""

# ╔═╡ 03d59010-9e19-11eb-223a-2b1757026cfc
path = "/Volumes/External HD"

# ╔═╡ 03d59010-9e19-11eb-3d04-c51e32a3b46a
name = "data"

# ╔═╡ 03d5901a-9e19-11eb-36b9-8b8e0c5b8e92
ext = "csv"

# ╔═╡ 03d5901a-9e19-11eb-2a41-2bed6598391f
`sort $path/$name.$ext`

# ╔═╡ 03d59036-9e19-11eb-3003-d15e54d94b32
md"""
As you can see, the space in the `path` variable is appropriately escaped. But what if you *want* to interpolate multiple words? In that case, just use an array (or any other iterable container):
"""

# ╔═╡ 03d592d4-9e19-11eb-24b1-01a33d732298
files = ["/etc/passwd","/Volumes/External HD/data.csv"]

# ╔═╡ 03d592e0-9e19-11eb-379f-1ba87de240f1
`grep foo $files`

# ╔═╡ 03d592f4-9e19-11eb-3f82-716a5cf424ca
md"""
If you interpolate an array as part of a shell word, Julia emulates the shell's `{a,b,c}` argument generation:
"""

# ╔═╡ 03d5957e-9e19-11eb-3008-f7f5d0c52320
names = ["foo","bar","baz"]

# ╔═╡ 03d5959c-9e19-11eb-1a70-4500183f6b63
`grep xylophone $names.txt`

# ╔═╡ 03d595b0-9e19-11eb-02a7-0f54303d8ca4
md"""
Moreover, if you interpolate multiple arrays into the same word, the shell's Cartesian product generation behavior is emulated:
"""

# ╔═╡ 03d5998e-9e19-11eb-17c0-73f353c29fbc
names = ["foo","bar","baz"]

# ╔═╡ 03d5998e-9e19-11eb-0ec8-598265f7dd52
exts = ["aux","log"]

# ╔═╡ 03d599a2-9e19-11eb-18ef-5b89af6f5477
`rm -f $names.$exts`

# ╔═╡ 03d599b6-9e19-11eb-1f06-437e4ab98b4b
md"""
Since you can interpolate literal arrays, you can use this generative functionality without needing to create temporary array objects first:
"""

# ╔═╡ 03d59aa6-9e19-11eb-3e42-499dccaab2a0
`rm -rf $["foo","bar","baz","qux"].$["aux","log","pdf"]`

# ╔═╡ 03d59aba-9e19-11eb-3cbe-672031c6575b
md"""
## Quoting
"""

# ╔═╡ 03d59ace-9e19-11eb-01df-3332fffbc9c6
md"""
Inevitably, one wants to write commands that aren't quite so simple, and it becomes necessary to use quotes. Here's a simple example of a Perl one-liner at a shell prompt:
"""

# ╔═╡ 03d59c04-9e19-11eb-06b2-5578549f2ab6
sh$ perl -le '

# ╔═╡ 03d59c22-9e19-11eb-3c7b-519da2e15615
md"""
The Perl expression needs to be in single quotes for two reasons: so that spaces don't break the expression into multiple shell words, and so that uses of Perl variables like `$|` (yes, that's the name of a variable in Perl), don't cause interpolation. In other instances, you may want to use double quotes so that interpolation *does* occur:
"""

# ╔═╡ 03d59d62-9e19-11eb-2315-9b0e845de4c7
sh$ first="A"

# ╔═╡ 03d59d94-9e19-11eb-1564-55f51540aff8
md"""
In general, the Julia backtick syntax is carefully designed so that you can just cut-and-paste shell commands as is into backticks and they will work: the escaping, quoting, and interpolation behaviors are the same as the shell's. The only difference is that the interpolation is integrated and aware of Julia's notion of what is a single string value, and what is a container for multiple values. Let's try the above two examples in Julia:
"""

# ╔═╡ 03d5a2f8-9e19-11eb-1c87-1769a5791cb3
A = `perl -le '$|=1; for (0..3) { print }'`

# ╔═╡ 03d5a2f8-9e19-11eb-0b44-e5d6c27780a4
run(A);

# ╔═╡ 03d5a2f8-9e19-11eb-1a6f-8f4c12c59398
first = "A"; second = "B";

# ╔═╡ 03d5a30c-9e19-11eb-306d-b1364918f670
B = `perl -le 'print for @ARGV' "1: $first" "2: $second"`

# ╔═╡ 03d5a316-9e19-11eb-312f-d15e264ecb1e
run(B);

# ╔═╡ 03d5a322-9e19-11eb-1c43-8f3993743a93
md"""
The results are identical, and Julia's interpolation behavior mimics the shell's with some improvements due to the fact that Julia supports first-class iterable objects while most shells use strings split on spaces for this, which introduces ambiguities. When trying to port shell commands to Julia, try cut and pasting first. Since Julia shows commands to you before running them, you can easily and safely just examine its interpretation without doing any damage.
"""

# ╔═╡ 03d5a334-9e19-11eb-1ac4-53cb51ed2bb5
md"""
## Pipelines
"""

# ╔═╡ 03d5a350-9e19-11eb-1fa3-c30e3e763264
md"""
Shell metacharacters, such as `|`, `&`, and `>`, need to be quoted (or escaped) inside of Julia's backticks:
"""

# ╔═╡ 03d5a5aa-9e19-11eb-3f82-73e0033ce750
run(`echo hello '|' sort`);

# ╔═╡ 03d5a5aa-9e19-11eb-23a1-8b234cfda55e
run(`echo hello \| sort`);

# ╔═╡ 03d5a5dc-9e19-11eb-21df-350b4d15ce7c
md"""
This expression invokes the `echo` command with three words as arguments: `hello`, `|`, and `sort`. The result is that a single line is printed: `hello | sort`. How, then, does one construct a pipeline? Instead of using `'|'` inside of backticks, one uses [`pipeline`](@ref):
"""

# ╔═╡ 03d5a8b6-9e19-11eb-3f98-8f017d8d5ef6
run(pipeline(`echo hello`, `sort`));

# ╔═╡ 03d5a8de-9e19-11eb-280c-8d48010bf9b8
md"""
This pipes the output of the `echo` command to the `sort` command. Of course, this isn't terribly interesting since there's only one line to sort, but we can certainly do much more interesting things:
"""

# ╔═╡ 03d5ab9a-9e19-11eb-1897-df0880feaf7f
run(pipeline(`cut -d: -f3 /etc/passwd`, `sort -n`, `tail -n5`))

# ╔═╡ 03d5abea-9e19-11eb-3406-cf8ef189d7d2
md"""
This prints the highest five user IDs on a UNIX system. The `cut`, `sort` and `tail` commands are all spawned as immediate children of the current `julia` process, with no intervening shell process. Julia itself does the work to setup pipes and connect file descriptors that is normally done by the shell. Since Julia does this itself, it retains better control and can do some things that shells cannot.
"""

# ╔═╡ 03d5abfe-9e19-11eb-0625-37f1c908ebf9
md"""
Julia can run multiple commands in parallel:
"""

# ╔═╡ 03d5adde-9e19-11eb-3516-4d2f146afc78
run(`echo hello` & `echo world`);

# ╔═╡ 03d5ae06-9e19-11eb-2bce-93633c9af6f2
md"""
The order of the output here is non-deterministic because the two `echo` processes are started nearly simultaneously, and race to make the first write to the [`stdout`](@ref) descriptor they share with each other and the `julia` parent process. Julia lets you pipe the output from both of these processes to another program:
"""

# ╔═╡ 03d5b05e-9e19-11eb-10ea-39ce2b883df0
run(pipeline(`echo world` & `echo hello`, `sort`));

# ╔═╡ 03d5b07c-9e19-11eb-09cf-59f76509533c
md"""
In terms of UNIX plumbing, what's happening here is that a single UNIX pipe object is created and written to by both `echo` processes, and the other end of the pipe is read from by the `sort` command.
"""

# ╔═╡ 03d5b090-9e19-11eb-12b7-e154236c4225
md"""
IO redirection can be accomplished by passing keyword arguments `stdin`, `stdout`, and `stderr` to the `pipeline` function:
"""

# ╔═╡ 03d5b0ae-9e19-11eb-185c-83deaf8dc172
md"""
```julia
pipeline(`do_work`, stdout=pipeline(`sort`, "out.txt"), stderr="errs.txt")
```
"""

# ╔═╡ 03d5b0f4-9e19-11eb-1ced-75639f978f90
md"""
### Avoiding Deadlock in Pipelines
"""

# ╔═╡ 03d5b108-9e19-11eb-1138-07089ef98de2
md"""
When reading and writing to both ends of a pipeline from a single process, it is important to avoid forcing the kernel to buffer all of the data.
"""

# ╔═╡ 03d5b11c-9e19-11eb-3d98-0b9a5660755a
md"""
For example, when reading all of the output from a command, call `read(out, String)`, not `wait(process)`, since the former will actively consume all of the data written by the process, whereas the latter will attempt to store the data in the kernel's buffers while waiting for a reader to be connected.
"""

# ╔═╡ 03d5b13a-9e19-11eb-3d7b-7d8045e1fb2e
md"""
Another common solution is to separate the reader and writer of the pipeline into separate [`Task`](@ref)s:
"""

# ╔═╡ 03d5b158-9e19-11eb-2e80-c5691250759d
md"""
```julia
writer = @async write(process, "data")
reader = @async do_compute(read(process, String))
wait(writer)
fetch(reader)
```
"""

# ╔═╡ 03d5b160-9e19-11eb-0fac-9b6efe14208a
md"""
### Complex Example
"""

# ╔═╡ 03d5b194-9e19-11eb-0a77-27843359e408
md"""
The combination of a high-level programming language, a first-class command abstraction, and automatic setup of pipes between processes is a powerful one. To give some sense of the complex pipelines that can be created easily, here are some more sophisticated examples, with apologies for the excessive use of Perl one-liners:
"""

# ╔═╡ 03d5b888-9e19-11eb-3cf7-1742ce5f50d1
prefixer(prefix, sleep) = `perl -nle '$|=1; print "'$prefix' ", $_; sleep '$sleep';'`;

# ╔═╡ 03d5b888-9e19-11eb-29f3-2bf229c408a2
run(pipeline(`perl -le '$|=1; for(0..5){ print; sleep 1 }'`, prefixer("A",2) & prefixer("B",2)));

# ╔═╡ 03d5b8ce-9e19-11eb-0ef2-eb65d2482baa
md"""
This is a classic example of a single producer feeding two concurrent consumers: one `perl` process generates lines with the numbers 0 through 5 on them, while two parallel processes consume that output, one prefixing lines with the letter "A", the other with the letter "B". Which consumer gets the first line is non-deterministic, but once that race has been won, the lines are consumed alternately by one process and then the other. (Setting `$|=1` in Perl causes each print statement to flush the [`stdout`](@ref) handle, which is necessary for this example to work. Otherwise all the output is buffered and printed to the pipe at once, to be read by just one consumer process.)
"""

# ╔═╡ 03d5b8ec-9e19-11eb-17db-4d57e7210556
md"""
Here is an even more complex multi-stage producer-consumer example:
"""

# ╔═╡ 03d5c118-9e19-11eb-0a89-5f155abf1248
run(pipeline(`perl -le '$|=1; for(0..5){ print; sleep 1 }'`,
           prefixer("X",3) & prefixer("Y",3) & prefixer("Z",3),
           prefixer("A",2) & prefixer("B",2)));

# ╔═╡ 03d5c12a-9e19-11eb-0e13-1b5fcfaee0a2
md"""
This example is similar to the previous one, except there are two stages of consumers, and the stages have different latency so they use a different number of parallel workers, to maintain saturated throughput.
"""

# ╔═╡ 03d5c13e-9e19-11eb-1483-b3a221da5d96
md"""
We strongly encourage you to try all these examples to see how they work.
"""

# ╔═╡ Cell order:
# ╟─03d57800-9e19-11eb-3b55-c1438963bce4
# ╟─03d5780a-9e19-11eb-2f49-efb674222651
# ╠═03d57936-9e19-11eb-196e-67899fc4c42d
# ╟─03d5795e-9e19-11eb-010a-d3cbf18d7f83
# ╟─03d57a3a-9e19-11eb-2c94-1902f341f9e9
# ╟─03d57b5c-9e19-11eb-2ba7-a7510a0369b1
# ╟─03d57b70-9e19-11eb-1fb4-5d93551b7bed
# ╠═03d57e40-9e19-11eb-0485-bd195d80f67b
# ╠═03d57e40-9e19-11eb-0587-bb4095c63ad5
# ╠═03d57e40-9e19-11eb-1a85-53ffdb5de6ab
# ╟─03d57e72-9e19-11eb-0e35-afb2c68d0df7
# ╟─03d57e9a-9e19-11eb-34e4-f79bb23144c0
# ╠═03d580c2-9e19-11eb-2d41-c74ebaa36683
# ╠═03d580d4-9e19-11eb-0bd6-8d228dd19bce
# ╟─03d580e8-9e19-11eb-301b-6beba8af1a9c
# ╠═03d58610-9e19-11eb-0968-3bc18fbf9aa8
# ╟─03d58624-9e19-11eb-3344-b9790db013b5
# ╠═03d58854-9e19-11eb-2fa9-79fc11084fd4
# ╠═03d58854-9e19-11eb-13dc-d9ed4269785c
# ╟─03d58886-9e19-11eb-2693-83778af8ee13
# ╟─03d588a4-9e19-11eb-0709-ebb4326147db
# ╠═03d58a36-9e19-11eb-2486-83324d1c6394
# ╠═03d58a3e-9e19-11eb-17f5-952c0f7f81ff
# ╟─03d58a5c-9e19-11eb-3f12-1fafcccd480c
# ╠═03d58c0a-9e19-11eb-29b5-c1fdae0a0894
# ╠═03d58c14-9e19-11eb-20ff-c7173306a8b4
# ╟─03d58c30-9e19-11eb-2aa7-dfb654ef83bc
# ╠═03d59010-9e19-11eb-223a-2b1757026cfc
# ╠═03d59010-9e19-11eb-3d04-c51e32a3b46a
# ╠═03d5901a-9e19-11eb-36b9-8b8e0c5b8e92
# ╠═03d5901a-9e19-11eb-2a41-2bed6598391f
# ╟─03d59036-9e19-11eb-3003-d15e54d94b32
# ╠═03d592d4-9e19-11eb-24b1-01a33d732298
# ╠═03d592e0-9e19-11eb-379f-1ba87de240f1
# ╟─03d592f4-9e19-11eb-3f82-716a5cf424ca
# ╠═03d5957e-9e19-11eb-3008-f7f5d0c52320
# ╠═03d5959c-9e19-11eb-1a70-4500183f6b63
# ╟─03d595b0-9e19-11eb-02a7-0f54303d8ca4
# ╠═03d5998e-9e19-11eb-17c0-73f353c29fbc
# ╠═03d5998e-9e19-11eb-0ec8-598265f7dd52
# ╠═03d599a2-9e19-11eb-18ef-5b89af6f5477
# ╟─03d599b6-9e19-11eb-1f06-437e4ab98b4b
# ╠═03d59aa6-9e19-11eb-3e42-499dccaab2a0
# ╟─03d59aba-9e19-11eb-3cbe-672031c6575b
# ╟─03d59ace-9e19-11eb-01df-3332fffbc9c6
# ╠═03d59c04-9e19-11eb-06b2-5578549f2ab6
# ╟─03d59c22-9e19-11eb-3c7b-519da2e15615
# ╠═03d59d62-9e19-11eb-2315-9b0e845de4c7
# ╟─03d59d94-9e19-11eb-1564-55f51540aff8
# ╠═03d5a2f8-9e19-11eb-1c87-1769a5791cb3
# ╠═03d5a2f8-9e19-11eb-0b44-e5d6c27780a4
# ╠═03d5a2f8-9e19-11eb-1a6f-8f4c12c59398
# ╠═03d5a30c-9e19-11eb-306d-b1364918f670
# ╠═03d5a316-9e19-11eb-312f-d15e264ecb1e
# ╟─03d5a322-9e19-11eb-1c43-8f3993743a93
# ╟─03d5a334-9e19-11eb-1ac4-53cb51ed2bb5
# ╟─03d5a350-9e19-11eb-1fa3-c30e3e763264
# ╠═03d5a5aa-9e19-11eb-3f82-73e0033ce750
# ╠═03d5a5aa-9e19-11eb-23a1-8b234cfda55e
# ╟─03d5a5dc-9e19-11eb-21df-350b4d15ce7c
# ╠═03d5a8b6-9e19-11eb-3f98-8f017d8d5ef6
# ╟─03d5a8de-9e19-11eb-280c-8d48010bf9b8
# ╠═03d5ab9a-9e19-11eb-1897-df0880feaf7f
# ╟─03d5abea-9e19-11eb-3406-cf8ef189d7d2
# ╟─03d5abfe-9e19-11eb-0625-37f1c908ebf9
# ╠═03d5adde-9e19-11eb-3516-4d2f146afc78
# ╟─03d5ae06-9e19-11eb-2bce-93633c9af6f2
# ╠═03d5b05e-9e19-11eb-10ea-39ce2b883df0
# ╟─03d5b07c-9e19-11eb-09cf-59f76509533c
# ╟─03d5b090-9e19-11eb-12b7-e154236c4225
# ╟─03d5b0ae-9e19-11eb-185c-83deaf8dc172
# ╟─03d5b0f4-9e19-11eb-1ced-75639f978f90
# ╟─03d5b108-9e19-11eb-1138-07089ef98de2
# ╟─03d5b11c-9e19-11eb-3d98-0b9a5660755a
# ╟─03d5b13a-9e19-11eb-3d7b-7d8045e1fb2e
# ╟─03d5b158-9e19-11eb-2e80-c5691250759d
# ╟─03d5b160-9e19-11eb-0fac-9b6efe14208a
# ╟─03d5b194-9e19-11eb-0a77-27843359e408
# ╠═03d5b888-9e19-11eb-3cf7-1742ce5f50d1
# ╠═03d5b888-9e19-11eb-29f3-2bf229c408a2
# ╟─03d5b8ce-9e19-11eb-0ef2-eb65d2482baa
# ╟─03d5b8ec-9e19-11eb-17db-4d57e7210556
# ╠═03d5c118-9e19-11eb-0a89-5f155abf1248
# ╟─03d5c12a-9e19-11eb-0e13-1b5fcfaee0a2
# ╟─03d5c13e-9e19-11eb-1483-b3a221da5d96
