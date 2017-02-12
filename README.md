# 仿微信小功能之“投诉”

- 在info.plist添加下面字段

```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

