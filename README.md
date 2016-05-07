# poops

## Protocol
| action  | data  | example |
| :------------:  | :------------:  | :------------:  |
| change_eyecolor |  red, blue, green  | {"action":"change_eyecolor", "data":"red"}  |
| move_head  |  [Pitch(float), Yaw(float)] | {"action":"move_head", "data":"[-1.0, -1.0]"} |
| move_rshoulder  |  [Roll(float), Pitch(float)] | {"action":"move_rshoulder", "data":"[-1.0, -1.0]"} |
| move_lshoulder  |  [Roll(float), Pitch(float)] | {"action":"move_lshoulder", "data":"[1.0, -1.0]"} |
| move_relbow  |  [Roll(float), Yaw(float)] | {"action":"move_relbow", "data":"[1.0, 1.0]"} |
| move_lelbow  |  [Roll(float), Yaw(float)] | {"action":"move_lelbow", "data":"[-1.0, -1.0]"} |
| move_rwrist  |  Yaw(float) | {"action":"move_rwrist", "data":"1.0"} |
| move_lwrist  |  Yaw(float) | {"action":"move_lwrist", "data":"-1.0"} |
| move_hip  |  [Roll(float), Pitch(float)] | {"action":"move_hip", "data":"[-1.0, -1.0]"} |
| reset  | null  | {"action":"reset", "data": null} |
| V8  | null  | {"action":"V8", "data": null} |

関節の動きについては[Qiitaのこの記事](http://qiita.com/Suna/items/9ab7f805c2a2d2b1efef)を参照
