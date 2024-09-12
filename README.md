# service_template

Template of a C++ service that uses [userver framework](https://github.com/userver-framework/userver) with PostgreSQL.


## Download and Build

To create your own userver-based service follow the following steps:

1. Press the green "Use this template button" at the top of this github page
2. Clone the service `git clone your-service-repo && cd your-service-repo`
3. Give a propper name to your service and replace all the occurences of "service_template" string with that name
   (could be done via `find . -not -path "./third_party/*" -not -path ".git/*" -not -path './build_*' -type f | xargs sed -i 's/service_template/YOUR_SERVICE_NAME/g'`).
4. Feel free to tweak, adjust or fully rewrite the source code of your service.


## Makefile

Makefile contains typicaly useful targets for development:

| Команда                     | Описание                                                                                      |
|-----------------------------|-----------------------------------------------------------------------------------------------|
| `make all`                  | Собрать и запустить тесты для debug и release конфигураций                                     |
| `make cmake-debug`          | Настроить проект с помощью CMake для debug конфигурации                                       |
| `make cmake-release`        | Настроить проект с помощью CMake для release конфигурации                                     |
| `make build-debug`          | Собрать проект с помощью CMake (debug конфигурация)                                           |
| `make build-release`        | Собрать проект с помощью CMake (release конфигурация)                                         |
| `make test-debug`           | Запустить все тесты (debug конфигурация)                                                      |
| `make test-release`         | Запустить все тесты (release конфигурация)                                                    |
| `make testsuite-debug`      | Запустить набор тестов для debug конфигурации. Используйте F для фильтрации тестов            |
| `make testsuite-release`    | Запустить набор тестов для release конфигурации. Используйте F для фильтрации тестов          |
| `make clean-debug`          | Очистить собранные файлы (debug конфигурация)                                                 |
| `make clean-release`        | Очистить собранные файлы (release конфигурация)                                               |
| `make service-start-debug`  | Запустить сервис (debug конфигурация)                                                         |
| `make service-start-release`| Запустить сервис (release конфигурация)                                                       |
| `make dist-clean`           | Удалить все данные и сгенерированные файлы                                                    |
| `make add-eol`              | Добавить конец строки (EOL) в конце файлов в указанной директории. Use P to specify directory |
| `make add-eol-root`         | Добавить конец строки (EOL) в конце файлов в корне проекта                                    |
| `make add-eol-all`          | Добавить конец строки (EOL) во все файлы проекта                                              |
| `make format`               | Отформатировать все файлы проекта                                                             |
| `make check-git-status`     | Проверить, все ли файлы закоммичены в git                                                     |
| `make find-c-compiler`      | Найти C компилятор. Use compiler and version to specify                                       |
| `make find-cxx-compiler`    | Найти C++ компилятор. Use compiler and version to specify                                     |
| `make install-compiler`     | Установить C/C++ компилятор. Use compiler and version to specify                              |
| `make get_all_so`           | Найти все общие библиотеки для релиза                                                         |
| `make docker-build`         | Собрать Docker образ                                                                          |
| `make docker-release`       | Собрать все файлы для релиза в Docker                                                         |
| `make docker-clean`         | Удалить данные контейнера Docker                                                              |
| `make docker-install`       | Развернуть Docker контейнер                                                                   |
| `make docker-start`         | Запустить Docker контейнер   

Edit `Makefile.local` to change the default configuration and build options.


## License

The original template is distributed under the [Apache-2.0 License](https://github.com/userver-framework/userver/blob/develop/LICENSE)
and [CLA](https://github.com/userver-framework/userver/blob/develop/CONTRIBUTING.md). Services based on the template may change
the license and CLA.

## How to build docker and release

```sh
make docker-release
```

After all commands are executed correctly, container.tar and service_template.tar will be in /release

## How to run via docker

You need to take service_template.tar and container.tar from the releases.

```sh
docker load -i service_template.tar
tar -xf container.tar
docker-compose up
```

All data from container will be in /container.
