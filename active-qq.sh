#!/bin/bash

# 功能：聚焦QQ窗口，如果已经在则返回到用该脚本切换来QQ之前的窗口
# 用法：绑定该脚本到快捷键
# 依赖：jq
# 备注：记录上一个窗口的方式上写入/tmp/niri_prev_win

# 获取当前聚焦窗口的信息
FOCUSED_JSON=$(niri msg --json focused-window)
FOCUSED_ID=$(echo "$FOCUSED_JSON" | jq -r '.id')
FOCUSED_APP=$(echo "$FOCUSED_JSON" | jq -r '.app_id')
FOCUSED_TITLE=$(echo "$FOCUSED_JSON" | jq -r '.title')

# 当前是否聚焦在QQ主窗口（app_id和title均为"QQ"）
IS_QQ_MAIN=$([ "$FOCUSED_APP" = "QQ" ] && [ "$FOCUSED_TITLE" = "QQ" ] && echo "1" || echo "0")

if [ "$IS_QQ_MAIN" != "1" ]; then
    # 获取QQ主窗口的ID（app_id和title均为"QQ"），没有就直接退出
    WIN_ID=$(niri msg --json windows | jq -r '.[] | select(.app_id == "QQ" and .title == "QQ") | .id' | head -1)
    [ -z "$WIN_ID" ] && exit 1
    # 记住当前窗口ID（排除QQ子窗口），然后聚焦到QQ主窗口
    [ "$FOCUSED_APP" != "QQ" ] && echo "$FOCUSED_ID" > /tmp/niri_prev_win
    niri msg action focus-window --id "$WIN_ID"
else
    # 回到上一个窗口
    PREV_ID=$(cat /tmp/niri_prev_win 2>/dev/null)
    if [ -n "$PREV_ID" ]; then
        niri msg action focus-window --id "$PREV_ID"
        rm -f /tmp/niri_prev_win
    fi
fi
