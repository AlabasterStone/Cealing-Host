#!/bin/bash

# 依赖：jq, curl, uuidgen 或 openssl rand

json_url="https://cealinghost.netlify.app/cealing-host.json"
json_file="Cealing-Host.json"
curl -sSL "$json_url" -o "$json_file"

if ! command -v jq >/dev/null 2>&1; then
  echo "请先安装 jq 工具"
  exit 1
fi

# 随机字符串生成函数（8位）
generate_random() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen | tr -d '-' | head -c 8
  else
    openssl rand -hex 4
  fi
}

random_codes=""

map_domain_code=()
map_code_ip=()

while read -r item; do
  domains=$(echo "$item" | jq -r '.[0][]')
  code=$(echo "$item" | jq -r '.[1]')
  ip=$(echo "$item" | jq -r '.[2]')

  # 处理第二项
  if [[ "$code" == "null" ]]; then
    code=""
  elif [[ "$code" == "" ]]; then
    while :; do
      rand=$(generate_random)
      # 判重
      if ! echo "$random_codes" | grep -q "$rand"; then
        random_codes="$random_codes $rand"
        code="$rand"
        break
      fi
    done
  fi

  for domain in $domains; do
    # 删除 ^ # $ 字符
    clean_domain=$(echo "$domain" | tr -d '^#$')
    map_domain_code+=("MAP $clean_domain $code")
    map_code_ip+=("MAP $code $ip")
  done
done < <(jq -c '.[]' "$json_file")

# 用逗号拼接
host_rules=$(IFS=, ; echo "${map_domain_code[*]}")
resolver_rules=$(IFS=, ; echo "${map_code_ip[*]}")

line1="--host-rules=\"$host_rules\""
line2="--host-resolver-rules=\"$resolver_rules\""

# 输出两行用空格连接
command="open -a Microsoft\ Edge --args $line1 $line2 --test-type --ignore-certificate-errors"
echo $command
eval $command

# 删除临时文件
rm -f "$json_file"