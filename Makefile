TESTS_INIT = tests/minimal_init.lua
# 30 mins
TIMEOUT_MINS := $(shell echo $$((30 * 60 * 1000)))


.PHONY: test
.PHONY: test-all
.PHONY: test-all-sequential
.PHONY: test-demo
.PHONY: test-demo-main
.PHONY: test-demo-config

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests ! -regex .*_demo_spec.*]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

test-all:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

test-all-sequential:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", sequential = true, })"

test-demo:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests -regex .*_demo_spec.*]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

test-demo-main:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests -name kitty_scrollback_demo_spec.lua]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

test-demo-config:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests -name kitty_scrollback_config_demo_spec.lua]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

