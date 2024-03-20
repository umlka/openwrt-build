#!/bin/bash

# 这个脚本的作用是从不同的仓库中克隆openwrt相关的代码，并进行一些处理

# 定义一个函数，用来克隆指定的仓库和分支
clone_repo() {
	# 参数1是仓库地址，参数2是分支名，参数3是目标目录
	repo_url=$1
	branch_name=$2
	target_dir=$3
	# 克隆仓库到目标目录，并指定分支名和深度为1
	git clone -b $branch_name --depth 1 $repo_url $target_dir
}

# 定义一些变量，存储仓库地址和分支名
openwrt_repo="https://github.com/openwrt/openwrt.git"
openwrt_pkg_repo="https://github.com/openwrt/packages.git"
openwrt_luci_repo="https://github.com/openwrt/luci.git"
immortalwrt_repo="https://github.com/immortalwrt/immortalwrt.git"
immortalwrt_pkg_repo="https://github.com/immortalwrt/packages.git"
immortalwrt_luci_repo="https://github.com/immortalwrt/luci.git"
lean_lede_repo="https://github.com/coolsnowwolf/lede.git"
umlka_pkg_repo="https://github.com/umlka/openwrt-pkgs.git"
sbwml_pkg_repo="https://github.com/sbwml/openwrt_pkgs.git"

# 开始克隆仓库，并行执行
clone_repo $openwrt_repo openwrt-23.05 openwrt &
clone_repo $openwrt_repo main openwrt_ma &
clone_repo $openwrt_pkg_repo master openwrt_pkg_ma &
clone_repo $openwrt_luci_repo master openwrt_luci_ma &
clone_repo $immortalwrt_repo master immortalwrt_ma &
clone_repo $immortalwrt_pkg_repo master immortalwrt_pkg_ma &
clone_repo $immortalwrt_luci_repo master immortalwrt_luci_ma &
clone_repo $immortalwrt_repo openwrt-23.05 immortalwrt_23 &
clone_repo $immortalwrt_pkg_repo openwrt-23.05 immortalwrt_pkg_23 &
clone_repo $immortalwrt_luci_repo openwrt-23.05 immortalwrt_luci_23 &
clone_repo $lean_lede_repo master lean_lede &
clone_repo $umlka_pkg_repo main umlka_pkg &
clone_repo $sbwml_pkg_repo master sbwml_pkg &

# 等待所有后台任务完成
wait

# 退出脚本
exit 0
