## Ctags

Build ctags:

```
rm -f tags
find ~+ -type f -regex '.*\.\(c\|h\|cpp\|hpp\)$' > ctag-files
ctags --tag-relative=no -L ctag-files # this writes to ./tags
rm -f ctag-files
```

In ~/.vimrc:

```
" ctags
" the trailing semicolon causes vim to search parents up the path until a tags file is found
set tags=./tags;
set notagrelative
```

Reference ctags from vim:

  
| Keyboard command  | Action                                         |
| ----------------- | ---------------------------------------------- |
| `Ctrl-]`          | Jump to the tag underneath the cursor          |
| `:ts <tag> <RET>` | Search for a particular tag                    |
| `:tn`             | Go to the next definition for the last tag     |
| `:tp`             | Go to the previous definition for the last tag |
| `:ts`             | List all of the definitions of the last tag    |
| `Ctrl-t`          | Jump back up in the tag stack                  |

[Tutorial: ctags](https://courses.cs.washington.edu/courses/cse451/10au/tutorials/tutorial_ctags.html)
Consider auto-generating tags on file changes: https://stackoverflow.com/questions/155449/vim-auto-generate-ctags

## Cscope

Build:

```
find ~+ -type f -regex '.*\.\(c\|h\|cpp\|hpp\)$' > ctag-files
cat ctag-files | cscope -b -q -k -i -
rm ctag-files
```

Need to install ~/.vim/plugin/cscope_maps.vim, and then source it in ~/.vimrc:

```
" cscope
source ~/.vim/plugin/cscope_maps.vim
```

Reference cscope from vim:
  
| Keyboard command  | Action                                         |
| ----------------- | ---------------------------------------------- |
| `<C-\s>`          | Find all uses of symbol under cursor           |
| `<C-\g>`          | Find definition of symbol under cursor         |
| `<C-\c>`          | Find all calls to a function                   |
| `<C-\f>`          | Open file under cursor in new window           |
| `<C-spacebar s>`  | Same as above, but opens in a new window       |

Tutorial: [cscope](http://cscope.sourceforge.net/cscope_vim_tutorial.html)  
More information: [Using cscope on large projects (example: the Linux kernel)](http://cscope.sourceforge.net/large_projects.html)
