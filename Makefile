# @authors   pintoved (Pinto Veda)

#------------------------------------------------#
#				   INGREDIENTS                   #
#------------------------------------------------#
# NAME           			project name
# VERSION        			build version
# OS             			operating system
# FILES          			all .cc .h files
# INSTALL_DIR    			installation path
# FILES          			executable file name
# CMAKE          			build system executable

NAME         	:= Telegram
VERSION      	:= 1.0

OS           	:= $(shell uname -s)
FILES        	:= $(shell find . \( -name "*.cc" -o -name "*.h" \) -type f)

# BUILD_TYPE   	:= Debug
BUILD_DIR     	:= ../build
INSTALL_DIR   	:= ../install

TEST_DIR 	  	:= tests
TEST_BUILD_DIR	:= ../build-test

APP		     	:= $(NAME)
OPEN	     	:= ./

#------------------------------------------------#
#                    RECIPES                     #
#------------------------------------------------#
# all      			default goal
# build    			build program
# run				build and run program 
# install 			copy program to install dir
# uninstall			delete program from install dir
# clean    			remove binary
# dvi  				build documentation
# dist  			create .tar file of project
# linter   			run code style check
# fix-linter		run code style fix
# cppcheck 			run static code analys
# time    			run time analysis
# tests    			run tests

all: app

app: build
	$(OPEN)$(BUILD_DIR)/$(APP) 1 ../datasets/HIV-1_AF033819.3.txt ../datasets/RabinKarp.txt
	$(OPEN)$(BUILD_DIR)/$(APP) 2 ../datasets/NeedlemanWunsch.txt
	$(OPEN)$(BUILD_DIR)/$(APP) 3 ../datasets/Regex.txt
	$(OPEN)$(BUILD_DIR)/$(APP) 4 ../datasets/KSimilarity.txt
	$(OPEN)$(BUILD_DIR)/$(APP) 5 ../datasets/MinWindow.txt

run: build
	$(OPEN)$(BUILD_DIR)/$(APP)

install: build
	mkdir -p $(INSTALL_DIR)
	cp -r $(BUILD_DIR)/$(APP) $(INSTALL_DIR)

uninstall:
	rm -rfv $(INSTALL_DIR)

dvi:
	texi2pdf docs.tex
	rm -rfv *.aux *.log *.dvi *.out 

dist: build dvi
	cp -r $(BUILD_DIR)/$(APP) ./$(APP)
	-tar -czvf $(NAME)-$(VERSION).tar.gz $(APP) */ *.cc *.h *.txt *.pdf Makefile					
	rm -rf $(APP)

build:
	cmake -S . -B $(BUILD_DIR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)
	cmake --build $(BUILD_DIR)

tests:
	cmake -S $(TEST_DIR) -B $(TEST_BUILD_DIR)
	cmake --build $(TEST_BUILD_DIR)
	cd $(TEST_BUILD_DIR); ./Tests && make coverage

clean:
	rm -rfv $(BUILD_DIR)* $(INSTALL_DIR) $(TEST_BUILD_DIR) logs/ \
	*.tar.gz *.aux *.log *.dvi *.pdf *.out *.toc  *.user *.info

linter: fix-linter
	clang-format -n -style=Google $(FILES)
	
fix-linter:
	clang-format -i -style=Google $(FILES)

cppcheck:
	cppcheck --language=c++ --std=c++17 \
	--enable=all 						\
	--suppress=missingInclude 			\
	--suppress=unusedFunction 			\
	--suppress=noExplicitConstructor 	\
	--suppress=unmatchedSuppression 	\
	$(FILES)

time: build
	-@{ /usr/bin/time -v $(BUILD_DIR)/$(APP) 1 ../datasets/HIV-1_AF033819.3.txt ../datasets/RabinKarp.txt; } 2>> out.txt
	-@{ /usr/bin/time -v $(BUILD_DIR)/$(APP) 2 ../datasets/NeedlemanWunsch.txt; } 2>> out.txt
	-@{ /usr/bin/time -v $(BUILD_DIR)/$(APP) 3 ../datasets/Regex.txt; } 2>> out.txt
	-@{ /usr/bin/time -v $(BUILD_DIR)/$(APP) 4 ../datasets/KSimilarity.txt; } 2>> out.txt
	-@{ /usr/bin/time -v $(BUILD_DIR)/$(APP) 5 ../datasets/MinWindow.txt ; } 2>> out.txt
	-@echo
	-@cat out.txt | grep -e "Elapsed (wall clock) time (h:mm:ss or m:ss):" \
						 -e  "Maximum resident set size (kbytes):"
	-@rm -rf out.txt

#------------------------------------------------#
#					  SPEC                       #
#------------------------------------------------#

.PHONY: all run install uninstall dvi dist build tests clean linter linter-fix cppcheck time
.SILENT:
