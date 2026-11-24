"""Capture the 43 Flutter states in both themes using an existing Android device."""

import argparse
import io
from pathlib import Path
import re
import subprocess
import time
from urllib.request import urlopen

from PIL import Image

HOST_PORT = 37456
DEVICE_PORT = 37455
PACKAGE = "com.mamam.mamam_delivery"
ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True, help="Serial from adb devices")
    parser.add_argument("--adb", default="adb")
    parser.add_argument("--start", type=int, choices=range(1, 44), default=1)
    parser.add_argument("--end", type=int, choices=range(1, 44), default=43)
    parser.add_argument("--theme", choices=("light", "dark", "both"), default="both")
    args = parser.parse_args()
    if args.start > args.end:
        parser.error("--start cannot exceed --end")

    def adb(*command):
        return subprocess.check_output([args.adb, "-s", args.device, *command])

    def override(setting):
        output = adb("shell", "wm", setting).decode()
        match = re.search(r"Override \w+: (\S+)", output)
        return match[1] if match else "reset"

    def request(path):
        with urlopen(f"http://127.0.0.1:{HOST_PORT}/{path}", timeout=12) as response:
            return response.read()

    def capture(destination):
        destination.parent.mkdir(parents=True, exist_ok=True)
        for _ in range(8):
            with Image.open(io.BytesIO(adb("exec-out", "screencap", "-p"))) as screenshot:
                if screenshot.size != (750, 1624):
                    raise RuntimeError(f"Unexpected screenshot size: {screenshot.size}")
                screen = screenshot.convert("RGB")
                if any(high - low > 20 for low, high in screen.getextrema()):
                    screen.save(destination, quality=89, method=6)
                    return
            time.sleep(.6)
        raise RuntimeError(f"Only blank frames received for {destination.name}")

    previous_size, previous_density = override("size"), override("density")
    keyboard_setting = "show_ime_with_hard_keyboard"
    previous_keyboard = adb("shell", "settings", "get", "secure", keyboard_setting).decode().strip()
    themes = ("light", "dark") if args.theme == "both" else (args.theme,)
    forwarded = False
    try:
        adb("shell", "wm", "size", "750x1624")
        adb("shell", "wm", "density", "320")
        adb("shell", "settings", "put", "secure", keyboard_setting, "1")
        adb("forward", "--no-rebind", f"tcp:{HOST_PORT}", f"tcp:{DEVICE_PORT}")
        forwarded = True
        adb("shell", "am", "force-stop", PACKAGE)
        adb("shell", "am", "start", "-n", f"{PACKAGE}/.MainActivity")
        for attempt in range(20):
            try:
                if request("ready") == b"ready":
                    break
            except OSError:
                if attempt == 19:
                    raise
                time.sleep(1)
        for theme in themes:
            directory = ROOT / "docs" / "screenshots" / theme
            for index in range(args.start, args.end + 1):
                if request(f"{theme}/{index}") != b"ok":
                    raise RuntimeError(f"Unable to open {theme}/{index}")
                time.sleep(1.15 if index in (9, 40, 41) else .48)
                capture(directory / f"{index:02}.webp")
                print(f"{theme}/{index:02}", flush=True)
    finally:
        if forwarded:
            subprocess.run([args.adb, "-s", args.device, "forward", "--remove", f"tcp:{HOST_PORT}"])
        adb("shell", "wm", "size", previous_size)
        adb("shell", "wm", "density", previous_density)
        if previous_keyboard == "null":
            adb("shell", "settings", "delete", "secure", keyboard_setting)
        else:
            adb("shell", "settings", "put", "secure", keyboard_setting, previous_keyboard)


if __name__ == "__main__":
    main()
