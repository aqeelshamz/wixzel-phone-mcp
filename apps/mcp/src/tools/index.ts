import type { ToolDef } from '../tooling.js';
import { agentTools } from './agents.js';
import { apiKeyTools } from './api-keys.js';
import { appointmentTools } from './appointments.js';
import { billingTools } from './billing.js';
import { callTools } from './calls.js';
import { realtimeTools } from './realtime.js';
import { campaignTools } from './campaigns.js';
import { engineTools } from './engines.js';
import { knowledgeBaseTools } from './knowledge-bases.js';
import { leadTools } from './leads.js';
import { phoneNumberTools } from './phone-numbers.js';
import { sipTrunkTools } from './sip-trunks.js';
import { webhookTools } from './webhooks.js';

/** Every tool the server exposes, in the order a client lists them. */
export const allTools: ToolDef<any>[] = [
    ...engineTools,
    ...agentTools,
    ...callTools,
    ...realtimeTools,
    ...sipTrunkTools,
    ...phoneNumberTools,
    ...leadTools,
    ...campaignTools,
    ...knowledgeBaseTools,
    ...appointmentTools,
    ...webhookTools,
    ...billingTools,
    ...apiKeyTools,
];
