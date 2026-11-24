# Mamam Delivery 项目架构

## 设计来源

通过 Pixso 桌面 MCP 读取「Millio - Food & Beverage」。文件有五个分类。

| 分类 | 用途 |
| --- | --- |
| 1. Hello! | 设计封面 |
| 2. Design | 浅色 01 和深色 02 各 43 张应用画板 |
| 3. Design System | 配色、Montserrat 与 Luckiest Guy 字体、表单和按钮 |
| 4. Component | 标志、返回按钮、底栏、状态栏和键盘参考 |
| 5. Showcase | 展示图与画板预览 |

使用 Pixso 的 Flutter 代码导出和图层信息核对页面结构。布局与交互用 Flutter 组件编写，图片使用从 Pixso 独立导出的食物、插画、图标和地图素材。画板编号、节点 ID 和应用截图见 [界面截图](SCREENS.md)。

## 目录

```text
MamamDelivery/
├─ lib/
│  ├─ main.dart                应用入口
│  ├─ app.dart                 MaterialApp、主题、Navigator 路由和状态注入
│  ├─ core/
│  │  ├─ session.dart          页面枚举、商品数据、订单和本地会话状态
│  │  └─ ui.dart               页容器、按钮、表单、列表选项、图像和底栏
│  └─ features/
│     ├─ auth.dart             启动、引导、注册、登录、验证、密码和资料表单
│     ├─ shop.dart             首页、分类、商品、评价、聊天、搜索和筛选
│     ├─ checkout.dart         购物车、地址、优惠券、支付、订单和配送
│     └─ account.dart          账户、偏好和通知
├─ assets/
│  ├─ fonts/                  字体及许可证
│  └─ images/                 从 Pixso 节点提取并压缩的 WebP 资源
├─ android/                    Android 打包及应用图标
├─ web/                        Flutter Web 入口
├─ dist/                       ARM64 Android 演示安装包
├─ test/app_test.dart           登录、优惠、订单、搜索和主题回归
├─ tool/
│  ├─ screenshot_app.dart     仅供截图的独立入口和场景数据
│  └─ capture.py              通过 ADB 采集现有设备画面
└─ docs/
   ├─ ARCHITECTURE.md          本文
   ├─ SCREENS.md               画板和截图索引
   └─ screenshots/            Flutter 应用的实际 Android 截图
```

## 状态与导航

- *Session* 是一次运行中的 *ChangeNotifier*。*SessionScope* 向页面暴露会话状态。*MaterialApp* 根据主题设置切换浅色和深色，共用同一组 Widget。
- *ScreenView* 通过 *Screen* 选择页面，页面间导航走 Flutter *Navigator*。底栏切换一级页面，普通子页保留返回路径。选择页在用户点击 **Apply** 后写入会话。新增地址和卡片用路由返回值选中新条目。
- 金额使用整数分，购物车按单品汇总数量并计算折扣。提交订单会先保存金额和编号，再清空购物车。搜索匹配菜名或分类，距离使用演示商品的 1 km 数据，价格和分类由当前筛选条件决定。
- 登录、OTP、资料、购物车、地址、卡片尾号、评论、聊天和通知状态均在当前进程内。更换资料或主题后会立即更新，退出或重启应用时按演示流程处理。应用只保留卡片尾号用于列表展示。
- 地图和扫码使用原设计素材演示；配送路线、验证邮件、第三方登录、远程消息和支付需要接入对应服务。商店价格以共享商品数据为准，画板中同一菜品的不同示例价格统一处理。

## 截图复现

用已有的 Android 设备或模拟器。先构建并安装独立截图入口，运行 *capture.py*；它临时设置 750 × 1624、320 dpi 和软键盘显示，结束时还原设备设置。

```powershell
flutter build apk --debug --target-platform android-x64 -t tool/screenshot_app.dart
adb -s 127.0.0.1:5555 install -r build/app/outputs/flutter-apk/app-debug.apk
python tool/capture.py --device 127.0.0.1:5555
```

截图脚本需要 Python 3 和 Pillow。ADB 未加入 PATH 时可用 *--adb* 传入可执行文件。用 *--theme*、*--start* 和 *--end* 可局部重拍。换用 ARM64 设备时将构建目标改为 *android-arm64*。日常运行使用 *lib/main.dart*。

Android 工程使用 Gradle 8.14、Android Gradle Plugin 8.11.1 和 Kotlin 2.2.20，在本机 Flutter 3.47.7 上完成了构建。Flutter 暂会提示这些版本接近支持周期末期。
