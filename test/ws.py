import asyncio
import json
import sys
from typing import Any, Dict, Optional

import websockets
from websockets.server import WebSocketServerProtocol


def as_double(value):
  if isinstance(value, (int, float)):
    return float(value)
  if isinstance(value, str):
    try:
      return float(value)
    except ValueError:
      return None
  return None


async def send_json(ws: WebSocketServerProtocol, payload) -> None:
  await ws.send(json.dumps(payload))


async def send_ok(ws: WebSocketServerProtocol, payload) -> None:
  res = {"type": "ok", **payload}
  print(res)
  await send_json(ws, res)


async def send_error(ws: WebSocketServerProtocol, message: str) -> None:
  await send_json(ws, {"type": "error", "error": message})


def create_handler():
  stored_value: Optional[float] = None

  async def handler(ws: WebSocketServerProtocol):
    nonlocal stored_value
    try:
      async for raw in ws:
        try:
          if isinstance(raw, (bytes, bytearray)):
            text = raw.decode("utf-8", errors="strict")
          else:
            text = str(raw)
          decoded = json.loads(text)
          if not isinstance(decoded, dict):
            await send_error(ws, "Invalid JSON: expected an object")
            continue

          action = decoded.get("action")
          print("got " + str(action))
          if action is None:
            await send_error(ws, 'Missing "action"')
            continue

          if action in ("add", "sub", "mul", "div"):
            a = as_double(decoded.get("a"))
            b = as_double(decoded.get("b"))
            if a is None or b is None:
              await send_error(ws, 'add/sub/mul/div require numeric "a" and "b"')
              continue
            if action == "div" and b == 0.0:
              await send_error(ws, "Division by zero")
              continue
            if action == "add":
              result = a + b
            elif action == "sub":
              result = a - b
            elif action == "mul":
              result = a * b
            else:
              result = a / b
            await send_ok(ws, {"result": result})
            continue

          if action == "store":
            value = as_double(decoded.get("value"))
            if value is None:
              await send_error(ws, 'store requires numeric "value"')
              continue
            stored_value = value
            await send_ok(ws, {"stored": value})
            continue

          if action == "load":
            value = stored_value
            if value is None:
              await send_error(ws, "No value stored")
              continue
            await send_ok(ws, {"value": value})
            continue

          await send_error(ws, f"Unknown action: {action}")
        except Exception as e:
          await send_error(ws, f"Failed to process message: {e}")
    except Exception as e:
      try:
        await send_error(ws, f"Socket error: {e}")
      except Exception:
        pass

  return handler


async def main_async(argv) -> None:
  host = argv[1] if len(argv) > 1 else "127.0.0.1"
  try:
    port = int(argv[2]) if len(argv) > 2 else 8080
  except ValueError:
    raise SystemExit("Port must be an integer")

  handler = create_handler()
  async with websockets.serve(handler, host, port):
    print(f"WebSocket server listening on ws://{host}:{port}")
    await asyncio.Future()


def main() -> None:
  try:
    asyncio.run(main_async(sys.argv))
  except KeyboardInterrupt:
    pass


if __name__ == "__main__":
  main()


