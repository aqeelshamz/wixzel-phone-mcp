import { z } from 'zod';
import { annotate, compact, defineTool } from '../tooling.js';
import { id, pagination } from '../schemas.js';

const kbFields = {
    name: z.string().min(1),
    description: z.string().optional().describe('What this knowledge base covers, for your own reference.'),
    basic_info: z.string().optional().describe('Free text the agent should know: hours, address, pricing, policies.'),
    faqs: z
        .array(z.object({ question: z.string(), answer: z.string() }))
        .optional()
        .describe('Question/answer pairs the agent can answer verbatim.'),
    other_info: z.string().optional().describe('Anything else, free text.'),
};

export const knowledgeBaseTools = [
    defineTool({
        name: 'list_knowledge_bases',
        title: 'List knowledge bases',
        description: 'List knowledge bases. Attach one to an agent with knowledge_base_id on create_agent or update_agent.',
        input: { ...pagination },
        annotations: annotate.read,
        scope: 'knowledge_bases:read',
        handler: (client, args) => client.get('/v1/knowledge-bases', args),
    }),
    defineTool({
        name: 'get_knowledge_base',
        title: 'Retrieve a knowledge base',
        description: 'Fetch one knowledge base with its full content.',
        input: { id },
        annotations: annotate.read,
        scope: 'knowledge_bases:read',
        handler: (client, { id }) => client.get(`/v1/knowledge-bases/${encodeURIComponent(id)}`),
    }),
    defineTool({
        name: 'create_knowledge_base',
        title: 'Create a knowledge base',
        description: 'Create a knowledge base of facts and FAQs an agent can draw on during calls.',
        input: kbFields,
        annotations: annotate.write,
        scope: 'knowledge_bases:write',
        handler: (client, args) => client.post('/v1/knowledge-bases', compact(args)),
    }),
    defineTool({
        name: 'update_knowledge_base',
        title: 'Update a knowledge base',
        description: 'Change a knowledge base. Only the fields you send are changed. Sending faqs replaces the whole list.',
        input: { id, ...kbFields, name: kbFields.name.optional() },
        annotations: annotate.write,
        scope: 'knowledge_bases:write',
        handler: (client, { id, ...rest }) =>
            client.patch(`/v1/knowledge-bases/${encodeURIComponent(id)}`, compact(rest)),
    }),
    defineTool({
        name: 'delete_knowledge_base',
        title: 'Delete a knowledge base',
        description: 'Permanently delete a knowledge base. Agents referencing it lose that context. Not reversible.',
        input: { id },
        annotations: annotate.destructive,
        scope: 'knowledge_bases:write',
        handler: async (client, { id }) => {
            await client.delete(`/v1/knowledge-bases/${encodeURIComponent(id)}`);
            return { deleted: true, id };
        },
    }),
];
