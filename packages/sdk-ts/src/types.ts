/**
 * The public types. Everything with a name in the OpenAPI document is
 * re-exported from the generated file; the handful of shapes the document
 * only describes inline (query parameters, the transcript, the engine list)
 * are derived from `paths` here so they cannot drift either.
 */

import type { components, paths } from './generated/openapi.js';

export type {
    Agent, AgentList, CreateAgent, UpdateAgent,
    VoiceConfig, SttConfig, LlmConfig, TtsConfig, RealtimeConfig, TurnTaking,
    Lead, LeadList, CreateLead, UpdateLead, BulkCreateLeads, BulkLeadResult,
    Campaign, CampaignList, CreateCampaign,
    KnowledgeBase, KnowledgeBaseList, CreateKnowledgeBase, UpdateKnowledgeBase,
    PhoneNumber, PhoneNumberList, CreatePhoneNumber, UpdatePhoneNumber,
    SipTrunk, SipTrunkList, CreateSipTrunk, UpdateSipTrunk, SipTrunkStatus, SipTrunkTest, SipLogEntry, SipLogList,
    Appointment, AppointmentList, CreateAppointment, UpdateAppointment,
    Call, CallDetail, CallList, CreateCall, CallError, TranscriptEntry,
    UsageEvent, UsageEventList, UsageSummary,
    Balance, LedgerEntry, LedgerEntryList, Topup, CreateTopup,
    ApiKey, ApiKeyList, CreateApiKey, CreatedApiKey,
} from './generated/openapi.js';

/** The error envelope the API returns on every failure. */
export type ApiErrorBody = components['schemas']['Error']['error'];
export type ErrorType = ApiErrorBody['type'];

/** The envelope every list endpoint returns. */
export interface ListResponse<T> {
    object: 'list';
    data: T[];
    has_more: boolean;
    next_cursor: string | null;
}

type Query<P extends keyof paths> = paths[P] extends { get: { parameters: { query?: infer Q } } }
    ? NonNullable<Q>
    : never;

export type PaginationQuery = Query<'/v1/agents'>;
export type CallListQuery = Query<'/v1/calls'>;
export type LeadListQuery = Query<'/v1/leads'>;
export type UsageEventsQuery = Query<'/v1/usage/events'>;
export type UsageSummaryQuery = Query<'/v1/usage/summary'>;
export type SipTrunkLogsQuery = Query<'/v1/sip-trunks/{id}/logs'>;

export type CallStatus = NonNullable<CallListQuery['status']>;
export type CallDirection = NonNullable<CallListQuery['direction']>;
export type UsageComponent = NonNullable<UsageEventsQuery['component']>;

export type Transcript = paths['/v1/calls/{id}/transcript']['get']['responses'][200]['content']['application/json'];
export type EngineList = paths['/v1/engines']['get']['responses'][200]['content']['application/json'];
export type Engine = EngineList['data'][number];

export type Scope = components['schemas']['CreateApiKey']['scopes'][number];
