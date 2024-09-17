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

| Command                     | Description                                                                                                           |
|-----------------------------|-----------------------------------------------------------------------------------------------------------------------|
| `make all`                  | Build and run tests for debug and release configurations                                                              |
| `make cmake-debug`          | Configure the project using CMake for debug configuration                                                             |
| `make cmake-release`        | Configure the project using CMake for release configuration                                                           |
| `make build-debug`          | Build the project using CMake (debug configuration)                                                                   |
| `make build-release`        | Build the project using CMake (release configuration)                                                                 |
| `make test-debug`           | Run all tests (debug configuration)                                                                                   |
| `make test-release`         | Run all tests (release configuration)                                                                                 |
| `make testsuite-debug`      | Run a test suite for the debug configuration. Use `F` to filter tests                                                 |
| `make testsuite-release`    | Run a test suite for the release configuration. Use `F` to filter tests                                               |
| `make clean-debug`          | Clean built files (debug configuration)                                                                               |
| `make clean-release`        | Clean built files (release configuration)                                                                             |
| `make service-start-debug`  | Start the service (debug configuration)                                                                               |
| `make service-start-release`| Start the service (release configuration)                                                                             |
| `make dist-clean`           | Remove all data and generated files                                                                                   |
| `make add-eol`              | Add an end-of-line (EOL) character to the end of files in the specified directory. Use `P` to specify directory       |
| `make add-eol-root`         | Add an end-of-line (EOL) character to the end of files in the project root                                            |
| `make add-eol-all`          | Add an end-of-line (EOL) character to all project files                                                               |
| `make format`               | Format all project files                                                                                              |
| `make check-git-status`     | Check if all files are committed in git                                                                               |
| `make find-c-compiler`      | Find a C compiler. Use `compiler` and `version` to specify                                                            |
| `make find-cxx-compiler`    | Find a C++ compiler. Use `compiler` and `version` to specify                                                          |
| `make install-compiler`     | Install a C/C++ compiler. Use `compiler` and `version` to specify                                                     |
| `make get_all_so`           | Find all shared libraries for release                                                                                 |
| `make docker-build`         | Build a Docker image                                                                                                  |
| `make docker-release`       | Build all files for release in Docker                                                                                 |
| `make docker-clean`         | Remove Docker container data                                                                                          |
| `make docker-install`       | Deploy the Docker container                                                                                           |
| `make docker-start`         | Start the Docker container                                                                                            |
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
