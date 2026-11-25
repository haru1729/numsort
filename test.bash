#!/bin/bash
#SPDX-FileCopyrightText: 2026 Haruto Handa
#SPDX-License-Identifier: BSD-3-Clause

ng()
{
    echo ${1}行目のテスト失敗
    res=1
}

res=0

#正常処理
#正の整数値のみ
out=$(echo "9 1 5 8 4" | ./numsort)
[ "${out}" = "1 4 5 8 9" ] || ng "$LINENO"

#負の整数を追加
out=$(echo "-3 0 -6 5 3" | ./numsort)
[ "${out}" = "-6 -3 0 3 5" ] || ng "$LINENO"

#小数を追加
out=$(echo "-7.5 2.0 8 -5.4" | ./numsort)
[ "${out}" = "-7.5 -5.4 2.0 8" ] || ng "$LINENO"

#区切り文字の判別(;)
out=$(echo "-1.5;2.0;3;-4" | ./numsort)
[ "${out}" = "-4;-1.5;2.0;3" ] || ng $LINENO

#区切り文字の判別(,)
out=$(echo "-1.5,2.0,3,-4" | ./numsort)
[ "${out}" = "-4,-1.5,2.0,3" ] || ng $LINENO

#オプション(降順)
out=$(echo "-1 0 1.5 2 2.0" | ./numsort -r)
[ "${out}" = "2 2.0 1.5 0 -1" ] || ng $LINENO

#例外処理
#空の入力
out=$(echo "" | ./numsort 2>/dev/null)   #2>dev/null -> 標準エラー出力を捨て、標準出力のみを参照
[ "$?" = 1 ] || ng $LINENO
[ "${out}" = "" ] || ng $LINENO
err=$(echo "" | ./numsort 2>&1 >/dev/null)      #2>&1 -> 標準エラー出力を標準出力へ移動　>dev/null -> 元の標準出力を破棄
[ "${err}" = "エラー：入力データが空です" ] || ng $LINENO

#数値以外の文字の混入
out=$(echo "1 -5 r 7.8" | ./numsort 2>/dev/null)
[ "$?" = 1 ] || ng $LINENO
[ "${out}" = "" ] || ng $LINENO
err=$(echo "1 -5 r 7.8" | ./numsort 2>&1 >/dev/null)
[ "${err}" = "エラー：数値以外のデータが含まれています" ] || ng $LINENO

#NANの入力
out=$(echo "4 NAN 2 -3 -1.5" | ./numsort 2>/dev/null)
[ "$?" = 1 ] || ng $LINENO
[ "${out}" = "" ] || ng $LINENO
err=$(echo "4 NAN 2 -3 -1.5" | ./numsort 2>&1 > /dev/null)
[ "${err}" = "エラー：NANやINFは扱えません" ] || ng $LINENO

#INFの入力
out=$(echo "1 3.5 -INF -2 -4.0" | ./numsort 2>/dev/null)
[ "$?" = 1 ] || ng $LINENO
[ "${out}" = "" ] || ng $LINENO
err=$(echo "1 3.5 -INF -2 -4.0" | ./numsort 2>&1 >/dev/null)
[ "${err}" = "エラー：NANやINFは扱えません" ] || ng $LINENO

#区切り文字の混在(空白+;)
out=$(echo "-2.0 4;6 10.5" | ./numsort 2>/dev/null)
[ "$?" = 1 ] || ng $LINENO
[ "${out}" = "" ] || ng $LINENO
err=$(echo "-2.0 4;6 10.5" | ./numsort 2>&1 >/dev/null)
[ "${err}" = "エラー：区切り文字が統一されていません" ] || ng $LINENO

#区切り文字の混在(空白+,)
out=$(echo "-2.0 4,6 10.5" | ./numsort 2>/dev/null)
[ "$?" = 1 ] || ng $LINENO
[ "${out}" = "" ] || ng $LINENO
err=$(echo "-2.0 4,6 10.5" | ./numsort 2>&1 >/dev/null)
[ "${err}" = "エラー：区切り文字が統一されていません" ] || ng $LINENO

#区切り文字の混在(;+,)
out=$(echo "-2.0;4,6;10.5" | ./numsort 2>/dev/null)
[ "$?" = 1 ] || ng $LINENO
[ "${out}" = "" ] || ng $LINENO
err=$(echo "-2.0;4,6;10.5" | ./numsort 2>&1 >/dev/null)
[ "${err}" = "エラー：区切り文字が統一されていません" ] || ng $LINENO

[ "${res}" = 0 ] && echo OK

exit $res