# poops

## Protocol
| action  | data  | example |
| :------------:  | :------------:  | :------------:  |
| change_eyecolor | string (red, blue, green)  | {"action":"change_eyecolor", "data":"red"}  |
| move_rshoulder  | string (float, float) | {"action":"move_rshoulder", "data":"[-1.0, 1.0]"} |
| move_lshoulder  | string (float, float) | {"action":"move_lshoulder", "data":"[-1.0, 1.0]"} |
| reset  | null  | {"action":"reset", "data": null} |
| V8  | null  | {"action":"V8", "data": null} |

関節の動きについては[Qiitaのこの記事](http://qiita.com/Suna/items/9ab7f805c2a2d2b1efef)を参照
