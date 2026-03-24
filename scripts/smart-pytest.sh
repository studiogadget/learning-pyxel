#!/usr/bin/env bash
# smart-pytest.sh
# プロジェクト規模（テストファイル数）に応じて pytest を自動切り替えする。
#
# モード判定:
#   テストファイル数 <  PYTEST_THRESHOLD  → 標準モード: 全テスト・coverage 付き
#   テストファイル数 >= PYTEST_THRESHOLD  → 高速モード: tests/unit のみ・並列・coverage 無効
#
# 環境変数:
#   PYTEST_THRESHOLD   閾値（デフォルト: 20）
#   PYTEST_WORKERS     並列ワーカー数（デフォルト: auto）
#                      VS Code フリーズを抑制したい場合は数値指定（例: 4）
#
# 使用例:
#   # Makefile から（Docker コンテナー内で実行される）
#   docker compose run --rm dev bash scripts/smart-pytest.sh
#
#   # 閾値・ワーカー数を上書き
#   PYTEST_THRESHOLD=50 PYTEST_WORKERS=4 make docker-pytest
#
#   # 追加の pytest オプションを渡す（-- 以降を転送）
#   docker compose run --rm dev bash scripts/smart-pytest.sh -k "test_foo"
#
set -euo pipefail

THRESHOLD="${PYTEST_THRESHOLD:-20}"
WORKERS="${PYTEST_WORKERS:-auto}"

# tests/ 内のテストファイル数をカウント
# pyproject.toml の python_files = ["test_*.py", "*_test.py"] に合わせて両パターンを集計
TEST_COUNT="$(find tests \( -name "test_*.py" -o -name "*_test.py" \) 2>/dev/null | wc -l | tr -d '[:space:]')"

printf '[smart-pytest] ファイル数=%s 閾値=%s\n' "${TEST_COUNT}" "${THRESHOLD}"

if [ "${TEST_COUNT}" -ge "${THRESHOLD}" ]; then
    printf '[smart-pytest] 大規模モード: tests/unit を並列実行 (coverage・統合テスト除外)\n'
    printf '[smart-pytest] 全テスト実行は: make docker-pytest-full\n'
    exec uv run pytest \
        tests/unit \
        -q \
        -n "${WORKERS}" \
        --no-cov \
        --tb=short \
        "$@"
else
    printf '[smart-pytest] 標準モード: 全テストを通常実行\n'
    exec uv run pytest -q "$@"
fi
