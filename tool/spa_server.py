#!/usr/bin/env python3
"""SPA-friendly static server for Flutter web (path URL strategy)."""

from __future__ import annotations

import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


class SpaHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, directory: str | None = None, **kwargs):
        super().__init__(*args, directory=directory, **kwargs)

    def end_headers(self) -> None:
        # Avoid stale Flutter builds / service-worker caches during local demos.
        path = self.path.split('?', 1)[0]
        if path.endswith(('.html', '/', '.js', '.json')) or path in ('', '/'):
            self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
            self.send_header('Pragma', 'no-cache')
        super().end_headers()

    def do_GET(self) -> None:  # noqa: N802
        path = Path(self.translate_path(self.path))
        if path.is_file():
            return super().do_GET()

        # Flutter client routes (e.g. /login, /ticketing) → index.html
        self.path = '/index.html'
        return super().do_GET()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=43123)
    parser.add_argument('--bind', default='0.0.0.0')
    parser.add_argument(
        '--directory',
        default=str(Path(__file__).resolve().parents[1] / 'build' / 'web'),
    )
    args = parser.parse_args()

    handler = partial(SpaHandler, directory=args.directory)
    server = ThreadingHTTPServer((args.bind, args.port), handler)
    print(f'Serving SPA at http://{args.bind}:{args.port} from {args.directory}')
    server.serve_forever()


if __name__ == '__main__':
    main()
