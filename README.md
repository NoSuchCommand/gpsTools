# gpsTools

GPS tools for STARTX collaborators

## Contributing

This private repository may be contributed to by pushing commits to your own
remote branch and requesting a merge in the master branch to the maintainer. In
order for your changes to be accepted and merged, they **must** conform to the
following guidelines.

### Commit content

One commit should only span an atomic and coherent set of related changes. **Do
not** use commits as a way to "backup" your work at the end of the day. Prefer
either working iteratively between each commit or sorting and splitting your
changes into smaller atomic commits. If needed, learn how to use `git add
--patch` and/or `git add -i` to achieve this.

The benefits from all this are :

- Clearer diff outputs
- Easier rollbacks without affecting other changes
- Easier review and cherry-picking while merging

Further guidelines about good staging habits can be found by reading
[this section](https://www.git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project#_commit_guidelines)
of the online Pro Git book.

### Commit messages

First read [this blog post](https://chris.beams.io/posts/git-commit/) about how
to write a good and useful commit message. The seven rules mentioned there are
strictly mandatory for this repository with some slight exceptions :

#### Rule #2: Subject line

The subject line should be kept as summarized as possible with an extended
length limit to the 70th-ish colmun.

This repository is mutualized for several "subprojects", each of which can be
identified by a "codename". If the commit changes something that is not general
to the repository (e.g. this README.md), it must change things in exactly one
specific subproject. In the latter case, use the subproject's codename between
square brackets as a prefix of your subject line, followed by one space, then
your regular capitalized subject. For example :

```
[myproj] Add this new feature
```

If your commit introduces a new subproject, you get to choose its codename. Keep
it short and meaningful so you save space for your real subject line.

In some rare cases, a subproject may itself be divided in several standalone
sections. The codename of the section is then appended to the subproject inside
the brackets, after a forward slash. For example :

```
[myproj/section] Fix that bug
```

However, try to avoid going deeper than these two levels. If you find yourself
in an absolute need to further subdivide, it might be a better solution to
refactor by splitting in seperate subprojects.

#### Rule #7: Message body

The body is not mandatory. Use it only if the subject line needs clarification.

#### Rule #8: Write in English

The commit messages (subject + body) of this repository have to be written in
proper English language.

### Requesting a merge

During the merge process, the maintainer will only review your commits according
to the above mentioned rules. Therefore, the content of the files you commit
will not be taken in account (although the maintainer may be in a good mood to
handle this burden additionnally :-) ). This way, you are free to make (but also
responsible for) any typo and bug due to changes not properly tested before you
commit.

In case your commits do not comply to the rules, the maintainer may either
reject them, telling you what is wrong and what to change, or alter them on his
own during the merge :

- without warning for minor changes (like small translation mistakes)
- with your consent and help on larger and more specific non-compliances

### Complete change lifecycle

1. Create a working copy
```
# Get a clone
git clone https://github.com/startxfr/gpsTools 
cd startxTools
# Create your branch
git branch mybranch
git checkout mybranch
```

2. Work
```
# change something and do your stuff
touch dummy
git add dummy
#-- and/or
vim existing_file.txt
git add existing_file.txt
# Commit your change
git commit -m "[myproj] Add a file"
```

3. Share
```
# push your change
git push origin mybranch
# request a merge by sending an email to the maintainer
```
