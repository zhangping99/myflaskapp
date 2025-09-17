import pytest
from app import app


@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_hello(client):
    response = client.get('/')
    assert response.data == b"Hello, CI/CD with Jenkins!"
    assert response.status_code == 200