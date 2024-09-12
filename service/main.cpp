#include <userver/clients/http/component.hpp>
#include <userver/components/minimal_server_component_list.hpp>
#include <userver/server/handlers/ping.hpp>
#include <userver/server/handlers/tests_control.hpp>
#include <userver/testsuite/testsuite_support.hpp>
#include <userver/utils/daemon_run.hpp>

#include <hello.hpp>
#include <userver/clients/dns/component.hpp>
#include <userver/storages/postgres/component.hpp>

int main(int argc, char* argv[]) {
  auto component_list = userver::components::MinimalServerComponentList()
                            .Append<userver::server::handlers::Ping>()
                            .Append<userver::components::TestsuiteSupport>()
                            .Append<userver::components::HttpClient>()
                            .Append<userver::server::handlers::TestsControl>();

  component_list.Append<userver::components::Postgres>("postgres-db-1");
  component_list.Append<userver::clients::dns::Component>();
  service_template::AppendHello(component_list);

  return userver::utils::DaemonMain(argc, argv, component_list);
}
