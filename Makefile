.PHONY: help test test-cov test-unit test-property test-integration format lint typecheck security audit check check-all benchmark setup sync lock-upgrade clean

# ==============================
# Docker variables (override OK)
# ==============================
DOCKER_IMAGE ?= project-name-dev
DOCKER_TAG ?= latest
DOCKER_NAME := $(DOCKER_IMAGE):$(DOCKER_TAG)
DOCKER_SHM_SIZE ?= 1gb
DOCKER_RUN_OPTS ?=
# Default command when running the container
CMD ?= python --version
# Extras for uv sync inside Docker image (space-separated)
DOCKER_INSTALL_EXTRAS ?= dev

# デフォルトターゲット
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
ifeq ("$(OS)","Windows_NT")
	@echo "  setup        - Setup (install dependencies, configure pre-commit)"
	@echo "  lock-upgrade - Update dependency lockfile (uv lock --upgrade)"
	@echo "  sync         - Synchronize all dependencies"
	@echo "  test         - Run all tests (unit, property, integration)"
	@echo "  test-cov     - Run tests with coverage"
	@echo "  test-unit    - Run unit tests only"
	@echo "  test-property - Run property-based tests only"
	@echo "  test-integration - Run integration tests only"
	@echo "  format       - Format code (ruff format)"
	@echo "  lint         - Lint check (ruff check --fix)"
	@echo "  typecheck    - Type check (pyright)"
	@echo "  security     - Security check (bandit)"
	@echo "  audit        - Dependency vulnerability check (pip-audit)"
	@echo "  benchmark    - Run performance benchmarks"
	@echo "  check        - Run format, lint, typecheck, test in sequence"
	@echo "  check-all    - Check all files with pre-commit"
	@echo "  clean        - Remove cache files"
else
	@echo "  setup        - セットアップ（依存関係インストール、pre-commit設定）"
	@echo "  lock-upgrade - 依存ロックの更新（uv lock --upgrade）"
	@echo "  sync         - 全依存関係を同期"
	@echo "  test         - 全テスト実行（単体・プロパティ・統合）"
	@echo "  test-cov     - カバレッジ付きテスト実行"
	@echo "  test-unit    - 単体テストのみ実行"
	@echo "  test-property - プロパティベーステストのみ実行"
	@echo "  test-integration - 統合テストのみ実行"
	@echo "  format       - コードフォーマット（ruff format）"
	@echo "  lint         - リントチェック（ruff check --fix）"
	@echo "  typecheck    - 型チェック（pyright）"
	@echo "  security     - セキュリティーチェック（bandit）"
	@echo "  audit        - 依存関係の脆弱性チェック（pip-audit）"
	@echo "  benchmark    - パフォーマンスベンチマーク実行"
	@echo "  check        - format, lint, typecheck, testを順番に実行"
	@echo "  check-all    - pre-commitで全ファイルをチェック"
	@echo "  clean        - キャッシュファイルの削除"
endif

# セットアップ
ifeq ("$(OS)","Windows_NT")
setup:
	powershell -ExecutionPolicy Bypass -File ./scripts/setup.ps1
else
setup:
	chmod +x scripts/setup.sh && ./scripts/setup.sh
endif

# ロックファイル更新
lock-upgrade:
	uv lock --upgrade

sync:
	uv sync --frozen --extra dev
    # 必要に応じて依存関係を追加
    # uv sync --frozen --extra dev --extra rpa

# テスト関連
test:
	uv run pytest

test-cov:
	uv run pytest --cov=src --cov-report=html --cov-report=term

test-unit:
	uv run pytest tests/unit/ -v

test-property:
	uv run pytest tests/property/ -v

test-integration:
	uv run pytest tests/integration/ -v

# コード品質チェック
format:
	uv run ruff format . --config=pyproject.toml

lint:
	uv run ruff check . --fix --config=pyproject.toml

typecheck:
	uv run pyright

security:
	uv run bandit -r src/

audit:
	uv run pip-audit

# パフォーマンス測定
benchmark:
	@echo "Running performance benchmarks..."
	@if [ -f benchmark_suite.py ]; then \
		uv run pytest benchmark_suite.py --benchmark-only --benchmark-autosave; \
	else \
		echo "Creating benchmark suite..."; \
		echo 'import pytest\nfrom learning-pyxel.utils.helpers import chunk_list\n\ndef test_chunk_list_benchmark(benchmark):\n    data = list(range(1000))\n    result = benchmark(chunk_list, data, 10)\n    assert len(result) == 100' > benchmark_suite.py; \
		uv add --dev pytest-benchmark; \
		uv run pytest benchmark_suite.py --benchmark-only --benchmark-autosave; \
	fi

# 統合チェック
check: format lint typecheck test

check-all:
	uv run pre-commit run --all-files

# クリーンアップ
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name ".mypy_cache" -exec rm -rf {} +
	find . -type d -name ".ruff_cache" -exec rm -rf {} +
	find . -type d -name "htmlcov" -exec rm -rf {} +
	find . -type f -name ".coverage" -delete
