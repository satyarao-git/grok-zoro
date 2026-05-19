import { createReadStream, existsSync, statSync } from 'node:fs';
import { createServer } from 'node:http';
import { extname, join, normalize, resolve } from 'node:path';

const port = Number.parseInt(process.env.PORT ?? '3200', 10);
const root = resolve(process.cwd(), 'build', 'web');

const contentTypes = new Map([
  ['.html', 'text/html; charset=utf-8'],
  ['.js', 'text/javascript; charset=utf-8'],
  ['.css', 'text/css; charset=utf-8'],
  ['.json', 'application/json; charset=utf-8'],
  ['.png', 'image/png'],
  ['.jpg', 'image/jpeg'],
  ['.jpeg', 'image/jpeg'],
  ['.svg', 'image/svg+xml'],
  ['.wasm', 'application/wasm'],
  ['.ico', 'image/x-icon'],
]);

createServer((request, response) => {
  const url = new URL(request.url ?? '/', 'http://127.0.0.1');
  const requestedPath = decodeURIComponent(url.pathname);
  const candidate = normalize(join(root, requestedPath));
  const filePath =
    candidate.startsWith(root) && existsSync(candidate) && statSync(candidate).isFile()
      ? candidate
      : join(root, 'index.html');

  response.writeHead(200, {
    'content-type': contentTypes.get(extname(filePath)) ?? 'application/octet-stream',
    'cache-control': 'no-cache',
  });
  createReadStream(filePath).pipe(response);
}).listen(port, '127.0.0.1', () => {
  console.log(`Zoro web preview listening on http://127.0.0.1:${port}`);
});
