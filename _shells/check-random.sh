
复制
#!/bin/sh

# 生成一个 0 到 1 之间的随机数
RANDOM_NUMBER=$(awk -v seed="$RANDOM" 'BEGIN{srand(seed); print rand()}')

echo "Generated random number: $RANDOM_NUMBER"

# 判断随机数是否小于 0.5
if (( $(echo "$RANDOM_NUMBER < 0.5" | bc -l) )); then
  echo "Check passed."
  exit 0
else
  echo "Check failed."
  exit 1
fi