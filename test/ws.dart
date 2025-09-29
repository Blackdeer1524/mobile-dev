import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final String host = args.isNotEmpty ? args[0] : '192.168.32.184';
  final int port = args.length > 1 ? int.parse(args[1]) : 8080;

  final HttpServer server = await HttpServer.bind(host, port);
  print('WebSocket server listening on ws://$host:$port');

  double? storedValue; 

  await for (final HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final WebSocket socket = await WebSocketTransformer.upgrade(request);
      _handleSocket(socket, () => storedValue, (double? v) => storedValue = v);
    } else {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.text
        ..write('WebSocket server is running. Connect via WS protocol.')
        ..close();
    }
  }
}

void _handleSocket(
  WebSocket socket,
  double? Function() getStored,
  void Function(double?) setStored,
) {
  socket.listen(
    (dynamic data) {
      try {
        final String text = data is String
            ? data
            : utf8.decode(data as List<int>);
        final Object? decoded = jsonDecode(text);
        if (decoded is! Map<String, dynamic>) {
          _sendError(socket, 'Invalid JSON: expected an object');
          return;
        }

        final String? action = decoded['action'] as String?;
        print("got " + action.toString());
        if (action == null) {
          _sendError(socket, 'Missing "action"');
          return;
        }

        switch (action) {
          case 'add':
          case 'sub':
          case 'mul':
          case 'div':
            {
              final double? a = _asDouble(decoded['a']);
              final double? b = _asDouble(decoded['b']);
              if (a == null || b == null) {
                _sendError(
                  socket,
                  'add/sub/mul/div require numeric "a" and "b"',
                );
                return;
              }
              if (action == 'div' && b == 0.0) {
                _sendError(socket, 'Division by zero');
                return;
              }
              final double result = action == 'add'
                  ? a + b
                  : action == 'sub'
                  ? a - b
                  : action == 'mul'
                  ? a * b
                  : a / b;
              _sendOk(socket, {'result': result});
              break;
            }

          case 'store':
            {
              final double? value = _asDouble(decoded['value']);
              if (value == null) {
                _sendError(socket, 'store requires numeric "value"');
                return;
              }
              setStored(value);
              _sendOk(socket, {'stored': value});
              break;
            }

          case 'load':
            {
              final double? value = getStored();
              if (value == null) {
                _sendError(socket, 'No value stored');
                return;
              }
              _sendOk(socket, {'value': value});
              break;
            }

          default:
            _sendError(socket, 'Unknown action: $action');
        }
      } catch (e) {
        _sendError(socket, 'Failed to process message: $e');
      }
    },
    onDone: () {},
    onError: (Object error) {
      try {
        _sendError(socket, 'Socket error: $error');
      } catch (_) {}
    },
  );
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

void _sendOk(WebSocket socket, Map<String, Object?> payload) {
  var res = {'type': 'ok', ...payload};
  print(res);
  _sendJson(socket, res);
}

void _sendError(WebSocket socket, String message) {
  _sendJson(socket, {'type': 'error', 'error': message});
}

void _sendJson(WebSocket socket, Map<String, Object?> payload) {
  socket.add(jsonEncode(payload));
}
