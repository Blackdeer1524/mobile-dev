import asyncio
import json
import sys
from typing import Any, Dict

import websockets
from websockets.server import WebSocketServerProtocol


async def send_json(ws: WebSocketServerProtocol, payload: Dict[str, Any]) -> None:
  await ws.send(json.dumps(payload))


async def send_status(ws: WebSocketServerProtocol, message: str) -> None:
  await send_json(ws, {"type": "status", "message": message})


def clamp(v: int, lo: int, hi: int) -> int:
  return max(lo, min(hi, v))


def create_handler():
  # In-memory device state
  is_on: int = 0
  slider: int = 0

  async def handler(ws: WebSocketServerProtocol):
    nonlocal is_on, slider
    await send_status(ws, "connected")
    try:
      async for raw in ws:
        try:
          if isinstance(raw, (bytes, bytearray)):
            text = raw.decode("utf-8", errors="strict")
          else:
            text = str(raw)
          msg = json.loads(text)
          if not isinstance(msg, dict):
            await send_json(ws, {"type": "error", "error": "Invalid JSON: expected object"})
            continue

          action = msg.get("action")
          if action is None:
            await send_json(ws, {"type": "error", "error": "Missing 'action'"})
            continue

          # 1) isOn → respond with current power state (0 or 1)
          if action == "isOn":
            await send_json(ws, {"isOn": is_on})
            continue

          # 2) getSlider → respond with current slider value (only meaningful when on)
          if action == "getSlider":
            await send_json(ws, {"slider": slider})
            continue

          # 3) setSlider → set only when device is on
          if action == "setSlider":
            if is_on == 0:
              await send_json(ws, {"type": "error", "error": "Device is off"})
              continue
            value = msg.get("value")
            try:
              value_int = int(value)
            except Exception:
              await send_json(ws, {"type": "error", "error": "setSlider requires integer 'value'"})
              continue
            slider = clamp(value_int, 0, 100)
            await send_json(ws, {"slider": slider})
            continue

          # 5) turnOn → switch on and report isOn and current slider
          if action == "turnOn":
            is_on = 1
            await send_json(ws, {"isOn": is_on})
            await send_json(ws, {"slider": slider})
            continue

          # 6) turnOff → switch off and report isOn
          if action == "turnOff":
            is_on = 0
            await send_json(ws, {"isOn": is_on})
            continue

          await send_json(ws, {"type": "error", "error": f"Unknown action: {action}"})
        except Exception as e:
          await send_json(ws, {"type": "error", "error": f"Failed to process message: {e}"})
    except Exception as e:
      try:
        await send_status(ws, f"Socket error: {e}")
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


