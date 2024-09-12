from datetime import datetime, timezone
import pytest

from testsuite.databases import pgsql


# Start the tests via `make test-debug` or `make test-release`

K_NOW = datetime(2024, 3, 30, 10, 0, 0, tzinfo=timezone.utc)

pytestmark = [pytest.mark.now(K_NOW.isoformat())]


async def test_first_time_users(service_client):
    response = await service_client.post(
        '/v1/hello',
        json={'name': 'userver'},
    )
    assert response.status == 200
    assert response.json()['text'] == 'Hello, userver!\n'
    assert response.json()['current-time'] == K_NOW.isoformat()


async def test_db_updates(service_client):
    response = await service_client.post('/v1/hello', json={'name': 'World'})
    assert response.status == 200
    assert response.json()['text'] == 'Hello, World!\n'
    assert response.json()['current-time'] == K_NOW.isoformat()

    response = await service_client.post('/v1/hello', json={'name': 'World'})
    assert response.status == 200
    assert response.json()['text'] == 'Hi again, World!\n'
    assert response.json()['current-time'] == K_NOW.isoformat()

    response = await service_client.post('/v1/hello', json={'name': 'World'})
    assert response.status == 200
    assert response.json()['text'] == 'Hi again, World!\n'
    assert response.json()['current-time'] == K_NOW.isoformat()


@pytest.mark.pgsql('db_1', files=['initial_data.sql'])
async def test_db_initial_data(service_client):
    response = await service_client.post(
        '/v1/hello',
        json={'name': 'user-from-initial_data.sql'},
    )
    assert response.status == 200
    assert response.json()['text'] == 'Hi again, user-from-initial_data.sql!\n'
    assert response.json()['current-time'] == K_NOW.isoformat()
