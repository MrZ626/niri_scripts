#!/bin/bash

# 功能：聚焦QQ窗口，如果已经在则返回到用该脚本切换来QQ之前的窗口
# 用法：绑定该脚本到快捷键
# 依赖：jq
# 备注：记录上一个窗口的方式上写入/tmp/niri_prev_win

# 获取当前聚焦窗口的信息
FOCUSED_JSON=$(niri msg --json focused-window)
FOCUSED_ID=$(echo "$FOCUSED_JSON" | jq -r '.id')
FOCUSED_APP=$(echo "$FOCUSED_JSON" | jq -r '.app_id')

if [ "$FOCUSED_APP" != "QQ" ]; then
    # 获取QQ窗口的ID，没有就直接退出
    WIN_ID=$(niri msg --json windows | jq -r '.[] | select(.app_id == "QQ") | .id' | head -1)
    [ -z "$WIN_ID" ] && exit 1
    # 记住当前窗口ID，然后聚焦到QQ窗口
    echo "$FOCUSED_ID" > /tmp/niri_prev_win
    niri msg action focus-window --id "$WIN_ID"
else
    # 回到上一个窗口
    PREV_ID=$(cat /tmp/niri_prev_win 2>/dev/null)
    if [ -n "$PREV_ID" ]; then
        niri msg action focus-window --id "$PREV_ID"
        rm -f /tmp/niri_prev_win
    fi
fi
