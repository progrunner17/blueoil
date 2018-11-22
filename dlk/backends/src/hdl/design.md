# design overview
## 問題点、改善可能点
- ic=0だけでなく、kw=kh=０をoutbufのマルチプレクサの条件に追加する必要あり。
- icのループに対し、毎回
- control_flow.mdの説明がアップデートできていない。
- icのループが続くうちは、outbufに戻さず、FFでaccしていけば良いのでは？


## 大まかな処理の流れ
![control_flow](./design/control_flow.png)

## マイクロアーキテクチャ
### calculation unit
![control_flow](./design/calc_unit.png)

there can be several types of units. see[./design/calc_unit_discuss.png]

### unroll
- input channel unroll  

![](./design/unroll_input_channel.png)

- output channel time unroll  

![](./design/unroll_output_channel_time.png)

- output channel area unroll

![](./design/unroll_output_channel_area.png)

- all integrated unroll are as follows.(2×2×4)

![](./design/unroll_all.png)


## timing
[spreadsheet](https://docs.google.com/spreadsheets/d/1vuLFVfZyjgWhiUy8i6Kdp5oRs9EIJO7mR0NpXOelV7Y/edit?usp=sharing)
![](./design/calc_unit_timing.png)
 	