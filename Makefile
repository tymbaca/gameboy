FLAGS:=-collection:src=src -collection:lib=lib
TEST_FLAGS:=-define:ODIN_TEST_SHORT_LOGS=true -define:ODIN_TEST_LOG_LEVEL=debug -define:ODIN_TEST_CLIPBOARD=true -define:ODIN_TEST_PROGRESS_WIDTH=0

run:
	odin run src -out:bin/main.bin $(FLAGS) 

test:
	odin test tests/ -out:bin/test.bin -all-packages $(TEST_FLAGS) $(FLAGS)
