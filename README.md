![sham](logo.png "sham")

`sham` is management tool for `bash` plugs.

`sham` example
-----------------

```.bashrc
# If
[[ -d ~/.sham ]] || git clone https://github.com/mijime/sham ~/.sham;
source ~/.sham/dist/sham.sh;

sham mijime/sham --dir ~/.sham;
sham mijime/dotfiles --of=".shrc.d/*.{sh,bash} shrc.d/mysh/*.{sh,bash}" use:".bin/*";
sham yourname/yourapp --from git://your.git.server/yourapp.git at:v3.0.0 --use cool-cli;

sham install 2>/dev/null && sham load;
```

`sham` options
-----------------

| options | description | default                        | examples                         |
| :------ | :------     | :------                        | :------                          |
| `of`    |             |                                | `of: "*.{zsh,sh}"`               |
| `use`   |             |                                | `use:"bin/*"`                    |
| `at`    |             |                                | `at:master`                      |
| `do`    |             |                                | `do:'./install --all'`           |
| `dir`   |             | `{repository dir}/plugin name` | `dir: ~/.fzf`                    |
| `as`    |             | `{plugin name}`                | `as: other_unique_name`          |
| `from`  |             | `github://{plugin name}`       | `from: github://mijime/dotfiles` |

`sham` commands
-----------------

| command   | description                                     | options               |
| :------   | :------                                         | :------               |
| `install` | Install described items                         | `--color` `--verbose` |
| `update`  | Update installed items                          | `--color` `--verbose` |
| `status`  | List installed items                            | `--color` `--verbose` |
| `load`    | Source installed plugins                        |                       |
| `clean`   | Remove repositories which are no longer managed | `--color` `--yes`     |

