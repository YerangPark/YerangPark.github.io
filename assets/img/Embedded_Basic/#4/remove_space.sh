#/bin/sh

# 현재 디렉토리에 있는 모든 파일을 순회하며 공백을 없앱니다.
for file in *; do
    # 파일 이름에서 공백을 제거한 새로운 이름을 생성합니다.
    new_name=$(echo "$file" | tr -d ' ')
    
    # 파일 이름이 바뀌었으면 파일을 이동합니다.
    if [ "$file" != "$new_name" ]; then
        mv "$file" "$new_name"
        echo "파일 이름 변경: $file -> $new_name"
    fi
done