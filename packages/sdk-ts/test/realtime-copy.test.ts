import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));

// The landing-page demo runs a copy of the browser helper, because Vercel
// builds apps/web without the workspace. A fix made to one and not the other
// would ship two clients that disagree about the protocol.
const webCopy = resolve(here, '../../../apps/web/lib/realtime-session.ts');

// Skipped in the public SDK mirror, which has no apps/web.
test('the landing demo runs exactly the published browser client', { skip: !existsSync(webCopy) }, () => {
    const sdk = readFileSync(resolve(here, '../src/realtime.ts'), 'utf8');
    const web = readFileSync(webCopy, 'utf8');
    assert.equal(web, sdk, 'copy packages/sdk-ts/src/realtime.ts over apps/web/lib/realtime-session.ts');
});
