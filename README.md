# 怪物猎人崛起飞智八爪鱼3手柄 Mod

## 功能 

#### 自适应扳机

1. 太刀不同纳刀方式的不同力反馈模式
2. 太刀神威蓄力时不同蓄力阶段的震动反馈
3. 预留了其他武器的自定义接口

## 已知问题

1. 因为飞智空间站还没开放mod接口，目前只能通过一些hack来使空间站识别到此mod，安装过程比较复杂
2. 因为通信方式的限制，通信效率不稳定，游戏中扳机状态反馈延迟可能比较高（需要飞智工程师改进通信方式来解决）

## 安装

#### 1. 安装前置 mod

1. [reframework](https://www.nexusmods.com/monsterhunterrise/mods/26)
2. [ModOptionsMenu (可选)](https://www.nexusmods.com/monsterhunterrise/mods/1292)

#### 2. 安装此 mod

[下载此项目打包文件](https://github.com/songchenwen/MHR-Flydigi-Apex3/archive/refs/heads/master.zip)，解压缩并放到怪猎安装目录下的 `reframework\autorun` 文件夹下

#### 3. 创建手柄配置文件并硬链接到 Cyberpunk 2077 Steam 版对应的目录下

这一步需要通过创建硬链接的方式，来让飞智空间站把怪猎的手柄配置作为2077的手柄配置载入（非 steam 版本的 2077 游戏也可以通过此方法让飞智空间站识别到手柄配置）

先安装图形化创建硬链接的工具，[Link Shell Extension](https://schinagl.priv.at/nt/hardlinkshellext/linkshellextension.html)

在怪猎安装目录下的 `reframework\data\flydigi_apex3` 文件夹里，创建文本文件 `DualSenseXConfig.txt`，如果文件夹不存在则手动创建此文件夹

如果你没有 Cyberpunk 2077 这个游戏，或者没有安装飞智对 2077 的 mod，那么创建这个文件夹 `C:\Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\DualSense Support\config`

注意 `C:\Program Files (x86)\Steam` 这部分换成你的 steam 安装目录

用 Link Shell Extension 工具，创建从怪猎目录下 `reframework\data\flydigi_apex3\DualSenseXConfig.txt` 到刚才创建的2077 mod 里的 `config` 文件夹下 `DualSenseXConfig.txt` 的硬链接(Hardlink)

如果 `config` 文件夹下已经存在 `DualSenseXConfig.txt`, 先删除它再创建硬链接即可。

如果不想安装工具，也可以通过 windows cmd 来创建硬链接，命令为 `mklink /h "Link" "Source"`, 其中 `Link` 为 2077 mod 里的 `DualSenseXConfig.txt` 文件，`Source` 为怪猎 mod 里的 `DualSenseXConfig.txt` 文件

#### 4. 修改飞智空间站的配置文件，来增加此mod里用到的扳机配置模式

找到飞智空间站安装目录下的 `config\dsx\trigger.ini` 文件，飞智空间站默认安装目录在 `C:\Program Files\FlydigiPcSpace`

打开 `trigger.ini` 增加如下这些行，并保存，你可能需要管理员权限才能保存此文件

```
[PushBack]
Mode=1
param1=0
param2=255
param3=0
param4=0

[LockHalf]
Mode=1
param1=100
param2=255
param3=1
param4=0

[VibHardHalf]
Mode=2
param1=80
param2=1
param3=200
param4=30

[VibVerySoftBottom]
Mode=2
param1=160
param2=1
param3=10
param4=30

[VibSoftBottom]
Mode=2
param1=160
param2=1
param3=30
param4=30

[VibHardSlowBottom]
Mode=2
param1=160
param2=1
param3=200
param4=3
```

#### 5. 安装完成

如果以上步骤你都顺利执行下来了，那么保持飞智空间站在后台运行，打开怪猎，拿起太刀，去训练场体验一下自适应板机吧
