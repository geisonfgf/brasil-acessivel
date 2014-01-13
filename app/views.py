# -*- encoding:utf-8 -*-
from flask import make_response, jsonify
from app import app


@app.errorhandler(500)
def internal_server_error(e):
    error_message = 'Desculpe encontramos um problema, tente mais tarde!'
    model_error = {'error': error_message}
    return make_response(jsonify(model_error), 500)


@app.errorhandler(400)
def bad_request(e):
    return make_response(jsonify({'error': 'Requisição incorreta'}), 400)


@app.errorhandler(401)
def unauthorized(e):
    return make_response(jsonify({'error': 'Não autorizado'}), 401)


@app.errorhandler(403)
def forbidden(e):
    error_message = 'Você não tem permissão para acessar este conteúdo'
    return make_response(jsonify({'error': error_message}), 403)


@app.errorhandler(404)
def page_not_found(e):
    return make_response(jsonify({'error': 'Caminho não encontrado'}), 404)


@app.errorhandler(405)
def method_not_allowed(e):
    error_message = 'Método inexistente para este recurso'
    return make_response(jsonify({'error': error_message}), 405)


@app.route("/")
@app.route("/api/v1.0/index")
def index():
    model_api = {'name': 'Guia Brasil Acessível API',
                 'description': 'API do Guia Brasil Acessível',
                 'version': '1.0'}
    return make_response(jsonify(model_api), 200)
