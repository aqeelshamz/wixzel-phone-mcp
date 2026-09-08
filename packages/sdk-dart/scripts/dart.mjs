// Run `dart <args>` from this package, or skip when dart is not installed.
//
// The root `npm test` and `npm run lint` fan out to every workspace, and two
// of the places that run them (Vercel building apps/web, the VPS deploying
// apps/api) have no Dart toolchain. A missing toolchain is not a failure of
// this package, so it is reported and skipped rather than failing the build.
import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const pkg = resolve(here, '..');
const args = process.argv.slice(2);

const probe = spawnSync('dart', ['--version'], { stdio: 'ignore' });
if (probe.error && probe.error.code === 'ENOENT') {
    console.log(`[sdk-dart] dart is not on PATH; skipping "dart ${args.join(' ')}"`);
    process.exit(0);
}

if (!existsSync(resolve(pkg, '.dart_tool/package_config.json'))) {
    const get = spawnSync('dart', ['pub', 'get'], { cwd: pkg, stdio: 'inherit' });
    if (get.status !== 0) process.exit(get.status ?? 1);
}

const run = spawnSync('dart', args, { cwd: pkg, stdio: 'inherit' });
process.exit(run.status ?? 1);
