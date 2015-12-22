![sham](logo.png "sham")

`sham` options
-----------------

| options | description | default                                | examples                                   |
| :------ | :------     | :------                                | :------                                    |
| `of`    |             |                                        | `of: "*.{zsh,sh}"`                         |
| `use`   |             |                                        | `use:"bin/*"`                              |
| `at`    |             |                                        | `at:master`                                |
| `do`    |             |                                        | `do:'./install --all'`                     |
| `dir`   |             | `{repository dir}/plugin name`         | `dir: ~/.fzf`                              |
| `as`    |             |                                        | `as: other_unique_name`                    |
| `from`  |             | `https://github.com/{plugin name}.git` | `from:https://gist.github.com/9580883.git` |

`sham` commands
-----------------

| command   | description                                     | options             |
| :------   | :------                                         | :------             |
| `install` | Install described items                         | `--verbose`         |
| `load`    | Source installed plugins                        |                     |
| `list`    | List installed items                            | `--verbose`         |
| `update`  | Update installed items                          | `--verbose`         |
| `status`  | Check if the remote repositories are up to date | `--verbose`         |
| `clean`   | Remove repositories which are no longer managed | `--yes` `--verbose` |
