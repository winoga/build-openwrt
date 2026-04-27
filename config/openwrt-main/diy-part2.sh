#!/bin/bash
#========================================================================================================================
# 专为 Firefly-RK3399 定制
# 基于 OpenWrt/LEDE 源码，集成 iStore 商店
#========================================================================================================================

# ------------------------------- 1. 修改 root 默认密码（改为 password）------------------------------
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# ------------------------------- 2. 设置版本号（显示编译日期）------------------------------
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='Firefly-RK3399'" >> package/base-files/files/etc/openwrt_release

# ------------------------------- 3. 添加第三方软件源（关键！包含 iStore）------------------------------
# 添加 iStore 主仓库（linkease 官方）
echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
# 添加 iStore 依赖软件包仓库
echo 'src-git istore_istoreos https://github.com/istoreos/istoreos-packages.git;main' >> feeds.conf.default

# ------------------------------- 4. 修改默认 IP（可选，默认 192.168.1.1 改成你想要的）------------------------------
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate

# ------------------------------- 5. 添加常用软件包（在编译时额外打包进去）------------------------------
# 注意：这些包名需要和 feeds 里的实际名字一致
cat >> .config <<EOF
# 启用 iStore 商店
CONFIG_PACKAGE_luci-app-store=y

# 启用 iStore 中文支持
CONFIG_PACKAGE_luci-i18n-store-zh-cn=y

# 推荐同时安装的实用组件
CONFIG_PACKAGE_openssh-sftp-server=y          # SFTP 支持
CONFIG_PACKAGE_screen=y                       # 多窗口终端
CONFIG_PACKAGE_htop=y                         # 系统状态查看
CONFIG_PACKAGE_nano=y                         # 文本编辑器
CONFIG_PACKAGE_ttyd=y                         # 网页版终端
CONFIG_PACKAGE_curl=y                         # 网络工具
CONFIG_PACKAGE_wget-ssl=y                     # Wget SSL 支持
CONFIG_PACKAGE_docker-ce=y                    # Docker 容器
CONFIG_PACKAGE_docker-compose=y               # Docker Compose

# 可选：主题美化
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-i18n-argon-zh-cn=y
EOF

# ------------------------------- 6. 更新 feeds（让添加的源生效）------------------------------
./scripts/feeds update -a
./scripts/feeds install -a

# ------------------------------- 7. 针对 RK3399 的内核优化（可选）------------------------------
# 开启 kvm 虚拟化支持（RK3399 硬件支持）
echo "CONFIG_KVM=y" >> .config
echo "CONFIG_KVM_ARM_HOST=y" >> .config

# ------------------------------- 8. 指定 Firefly-RK3399 设备型号（关键！）------------------------------
cat >> .config <<EOF
# 选择 Rockchip 平台和 RK3399 系列
CONFIG_TARGET_rockchip=y
CONFIG_TARGET_rockchip_rk3399=y
# 明确指定设备为 Firefly RK3399
CONFIG_TARGET_rockchip_rk3399_DEVICE_firefly-rk3399=y
EOF
