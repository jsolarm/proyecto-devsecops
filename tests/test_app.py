from app import app

def test_hello_route():
    client = app.test_client()

    response = client.get('/hello?name=alumno')

    assert response.status_code == 200
    assert response.data == b'Hello, alumno!'

def test_hello_without_name():
    client = app.test_client()

    response = client.get('/hello')

    assert response.status_code == 200
    assert response.data == b'Hello, None!'