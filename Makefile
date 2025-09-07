.PHONY: session chatlog session-cc context check-build hooks

session:
	bash tools/new-session-from-continue-chat.sh

chatlog:
	bash tools/build-chatlog.sh

session-cc: session chatlog

context:
	SUMMARY=1 RUN_FLOW=0 bash tools/new-session-cc.sh

check-build:
	bash tools/check-last-build.sh dev

hooks:
	bash tools/install-hooks.sh

