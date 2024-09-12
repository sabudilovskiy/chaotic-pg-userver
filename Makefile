CLANG_FORMAT ?= clang-format-17
DOCKER_COMPOSE ?= docker-compose

# NOTE: use Makefile.local to override the options defined above.
-include Makefile.local

.PHONY: all
all: test-debug test-release

# configure cmake project
.PHONY: cmake-%
cmake-debug cmake-release: cmake-%: 
	cmake --preset $*

# build project via cmake
.PHONY: build-%
build-debug build-release: build-%:
	@if [ ! -f build_$* ]; then \
        echo "build_$* does not exist. Running cmake configure..."; \
        $(MAKE) cmake-$*; \
    fi
	cmake --build build_$*

# run all tests via ctest
.PHONY: test-%
test-debug test-release: test-%: build-%
	cd build_$* && ((test -t 1 && GTEST_COLOR=1 PYTEST_ADDOPTS="--color=yes" ctest -V) || ctest -V)
	pycodestyle tests

# run testsuite tests. F=filter for filter some tests
.PHONY: testsuite-%
testsuite-debug testsuite-release: testsuite-%: build-%
	@rm -rf tests/results
	./build_$*/runtests-testsuite-service_template --service-logs-pretty -vv tests $(if $(F),-k $(F))

# clean cmake project
.PHONY: clean-%
clean-debug clean-release: clean-%
	cmake --build build_debug --target clean

# start the service (via testsuite service runner)
.PHONY: service-start-%
service-start-debug service-start-release: service-start-%: build-%
	cmake --build build_$* -v --target start-service_template

# drop all data 
.PHONY: dist-clean
dist-clean:
	sudo rm -rf build_*
	sudo rm -rf release
	rm -rf tests/__pycache__/
	rm -rf tests/.pytest_cache/

# add EOL(end of line) in end of file. P=directory
.PHONY: add-eol
add-eol:
	@find $(P) -type f | while read file; do \
        if ! tail -c1 "$$file" | grep -q "^$$"; then \
            echo >> "$$file"; \
        fi \
    done

# add EOL(end of line) in end of file in all root files.
.PHONY: add-eol-root
add-eol-root:
	@find . -maxdepth 1 -type f | while read file; do \
		if ! tail -c1 "$$file" | grep -q "^$$"; then \
			echo >> "$$file"; \
		fi \
    done

# add EOL(end of line) in all project.
.PHONY: add-eol-all
add-eol-all:
	$(MAKE) add-eol-root
	$(MAKE) add-eol P=.github
	$(MAKE) add-eol P=.vscode
	$(MAKE) add-eol P=benchs
	$(MAKE) add-eol P=configs
	$(MAKE) add-eol P=postgresql
	$(MAKE) add-eol P=schemas
	$(MAKE) add-eol P=scripts
	$(MAKE) add-eol P=service
	$(MAKE) add-eol P=src
	$(MAKE) add-eol P=tests
	$(MAKE) add-eol P=unit_tests


# format all files
.PHONY: format
format: add-eol-all
	find src -name '*pp' -type f | xargs $(CLANG_FORMAT) -i
	find benchs -name '*pp' -type f | xargs $(CLANG_FORMAT) -i
	find unit_tests -name '*pp' -type f | xargs $(CLANG_FORMAT) -i
	find service -name '*pp' -type f | xargs $(CLANG_FORMAT) -i
	find tests -name '*.py' -type f | xargs autopep8 -i


# check dif in git
.PHONY: check-git-status
check-git-status:
	@echo "Checking if all files are committed to git..."
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "The following files are not committed:"; \
		git status --short; \
		echo "Please commit all changes and try again."; \
		git diff --color | cat; \
		exit 1; \
	else \
		echo "All files are committed to git."; \
	fi

# find C compiler. compiler=TYPE(gcc or clang) version=VERSION(for example 12 to gcc)
.PHONY: find-c-compiler
find-c-compiler:
	@if [ "$(compiler)" = "clang" ]; then \
        echo "/usr/bin/clang-$(version)"; \
      elif [ "$(compiler)" = "gcc" ]; then \
        echo "/usr/bin/gcc-$(version)"; \
      else \
        echo "Unknown compiler" >&2;  \
      fi

# find CXX compiler. compiler=TYPE(gcc or clang) version=VERSION(for example 12 to gcc)
.PHONY: find-cxx-compiler
find-cxx-compiler:
	@if [ "$(compiler)" = "clang" ]; then \
        echo "/usr/bin/clang++-$(version)"; \
      elif [ "$(compiler)" = "gcc" ]; then \
        echo "/usr/bin/g++-$(version)"; \
      else \
        echo "Unknown compiler" >&2; \
      fi

# install C/CXX compilers. compiler=TYPE(gcc or clang) version=VERSION(for example 12 to gcc)
.PHONY: install-compiler
install-compiler:
	@if [ "$(compiler)" = "clang" ]; then \
            wget https://apt.llvm.org/llvm.sh; \
            chmod +x llvm.sh; \
            sudo ./llvm.sh $(version); \
            rm llvm.sh;\
    elif [ "$(compiler)" = "gcc" ]; then \
      	sudo apt install -y g++-$(version); \
      	sudo apt install -y gcc-$(version); \
  	else \
      echo "Unknown compiler" >&2; \
  	fi



# find all shared libraries for release
.PHONY: get_all_so
get_all_so:
	rm -rf _so
	mkdir _so
	ldd build_release/service_template | grep "=>" | awk '{print $$3}' | xargs -I {} cp {} _so


# build docker image
.PHONY: docker-build
docker-build: build-release get_all_so
	sudo docker build -t service_template:latest .
	rm -rf _so
	mkdir -p release
	sudo docker save -o release/service_template.tar service_template:latest
	sudo chmod 777 release/service_template.tar

# collect all files for release
.PHONY: docker-release
docker-release:
	@if [ ! -f release/service_template.tar ]; then \
        echo "release/service_template.tar does not exist. Running make docker-build..."; \
        $(MAKE) docker-build; \
    fi
	sudo mkdir -p _tmp/container/configs
	sudo mkdir -p _tmp/container/cores
	sudo mkdir -p _tmp/container/pg_data
	sudo cp configs/config_vars.docker.yaml _tmp/container/configs/config_vars.yaml
	sudo cp configs/static_config.yaml _tmp/container/configs/static_config.yaml
	sudo cp docker-compose.yml _tmp/docker-compose.yml
	sudo tar -C _tmp -cvf release/container.tar .
	sudo rm -rf _tmp
	sudo chmod 777 release/container.tar

# clean docker container data 
.PHONY: docker-clean
docker-clean:
	sudo rm -rf container

# deploy docker container
.PHONY: docker-install
docker-install:
	@if [ ! -f release/container.tar ]; then \
        echo "release/container.tar does not exist. Running make docker-release..."; \
        $(MAKE) docker-release; \
	fi
	sudo mkdir container
	sudo cp release/container.tar container/container.tar
	sudo docker load -i release/service_template.tar
	sudo tar -xf container/container.tar
	sudo rm -rf container.tar
	sudo docker-compose up

# start docker container
.PHONY: docker-start
docker-start:
	@if [ ! -f container ]; then \
        echo "Directory container does not exist. Running docker-install..."; \
        $(MAKE) docker-install; \
    fi
	sudo rm -rf container/configs
	sudo mkdir -p container/configs
	sudo cp configs/config_vars.docker.yaml container/configs/config_vars.yaml
	sudo cp configs/static_config.yaml container/configs/static_config.yaml
	sudo docker-compose up

.PHONY: help
help:
	@echo "Доступные цели:"
	@echo "  all                 - Собрать и запустить тесты для debug и release конфигураций"
	@echo "  cmake-debug         - Настроить проект с помощью CMake для debug конфигурации"
	@echo "  cmake-release       - Настроить проект с помощью CMake для release конфигурации"
	@echo "  build-debug         - Собрать проект с помощью CMake (debug конфигурация)"
	@echo "  build-release       - Собрать проект с помощью CMake (release конфигурация)"
	@echo "  test-debug          - Запустить все тесты (debug конфигурация)"
	@echo "  test-release        - Запустить все тесты (release конфигурация)"
	@echo "  testsuite-debug     - Запустить набор тестов для debug конфигурации. Используйте F для фильтрации тестов"
	@echo "  testsuite-release   - Запустить набор тестов для release конфигурации. Используйте F для фильтрации тестов"
	@echo "  clean-debug         - Очистить собранные файлы (debug конфигурация)"
	@echo "  clean-release       - Очистить собранные файлы (release конфигурация)"
	@echo "  service-start-debug - Запустить сервис (debug конфигурация)"
	@echo "  service-start-release - Запустить сервис (release конфигурация)"
	@echo "  dist-clean          - Удалить все данные и сгенерированные файлы"
	@echo "  add-eol             - Добавить конец строки (EOL) в конце файлов в указанной директории. Use P to specify directory"
	@echo "  add-eol-root        - Добавить конец строки (EOL) в конце файлов в корне проекта"
	@echo "  add-eol-all         - Добавить конец строки (EOL) во все файлы проекта"
	@echo "  format              - Отформатировать все файлы проекта"
	@echo "  check-git-status    - Проверить, все ли файлы закоммичены в git"
	@echo "  find-c-compiler     - Найти C компилятор. Use compiler and version to specify"
	@echo "  find-cxx-compiler   - Найти C++ компилятор. Use compiler and version to specify"
	@echo "  install-compiler    - Установить C/C++ компилятор. Use compiler and version to specify"
	@echo "  get_all_so          - Найти все общие библиотеки для релиза"
	@echo "  docker-build        - Собрать Docker образ"
	@echo "  docker-release      - Собрать все файлы для релиза в Docker"
	@echo "  docker-clean        - Удалить данные контейнера Docker"
	@echo "  docker-install      - Развернуть Docker контейнер"
	@echo "  docker-start        - Запустить Docker контейнер"
