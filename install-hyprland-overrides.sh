#!/bin/bash

set -e

hypr_symlink() {
  local LOCAL_FILE="$1"

  # 1. Проверяем, существует ли локальный файл-источник
  if [ ! -f "$LOCAL_FILE" ]; then
    echo "Ошибка: Локальный файл '$LOCAL_FILE' не найден."
    return 1
  fi

  # Получаем только имя файла (например, input.lua)
  local FILE_NAME=$(basename "$LOCAL_FILE")

  # Задаем целевой путь в конфигах Hypr
  local TARGET_DIR="$HOME/.config/hypr"
  local TARGET_PATH="${TARGET_DIR}/${FILE_NAME}"

  # 2. Если в ~/.config/hypr/ уже есть файл/ссылка, делаем бэкап
  if [ -f "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]; then
    local TIMESTAMP=$(date +%s)
    local BACKUP_PATH="${TARGET_PATH}.bak.${TIMESTAMP}"

    # Копируем реальный файл (разворачивая старые ссылки, если они были)
    cp --remove-destination "$(realpath "$TARGET_PATH")" "$BACKUP_PATH" 2>/dev/null || cp "$TARGET_PATH" "$BACKUP_PATH"
    echo "Создан бэкап старого конфига: $BACKUP_PATH"
  fi

  # 3. Создаем целевую директорию, если её нет
  mkdir -p "$TARGET_DIR"

  # 4. Создаем симлинк (используем абсолютный путь через realpath)
  ln -sf "$(realpath "$LOCAL_FILE")" "$TARGET_PATH"
  echo "Симлинк успешно создан: $TARGET_PATH -> $(realpath "$LOCAL_FILE")"
}

hypr_symlink hyprland-overrides/input.lua
hypr_symlink hyprland-overrides/bindings.lua
