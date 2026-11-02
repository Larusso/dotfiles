// Asks each llmserve port which single model it is serving and registers that list.

const FIRST_PORT = 8080;
const PORT_COUNT = 20;
const PROBE_MS = 1000;
const COST = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 };

interface ListedModel {
	id?: unknown;
	meta?: { n_ctx?: unknown };
}

interface ProbeResult {
	models: ReturnType<typeof toModel>[];
	errors: string[];
}

function shortName(id: string): string {
	const base = id.split("/").pop() || id;
	return base.replace(/\.gguf$/i, "");
}

function failure(error: unknown, port: number): string | undefined {
	const cause = error instanceof Error && error.cause instanceof Error ? error.cause : error;
	const code =
		cause && typeof cause === "object" && "code" in cause && typeof cause.code === "string" ? cause.code : undefined;
	// A closed port is ECONNREFUSED. A timeout means the connect never finished.
	if (code === "ECONNREFUSED") return undefined;
	const message = cause instanceof Error ? cause.message : String(cause);
	return `${port}: ${message}`;
}

function toModel(id: string, port: number, contextWindow: number) {
	return {
		id,
		name: `${shortName(id)} :${port}`,
		api: "openai-completions" as const,
		baseUrl: `http://127.0.0.1:${port}/v1`,
		reasoning: false,
		input: ["text" as const],
		cost: COST,
		contextWindow,
		maxTokens: Math.min(4096, contextWindow),
	};
}

async function modelsOnPort(port: number): Promise<ProbeResult> {
	try {
		const response = await fetch(`http://127.0.0.1:${port}/v1/models`, { signal: AbortSignal.timeout(PROBE_MS) });
		if (!response.ok) return { models: [], errors: [] };
		const body = (await response.json()) as { data?: ListedModel[] };
		const listed = (body.data ?? []).filter(
			(model): model is ListedModel & { id: string } => typeof model.id === "string" && model.id.length > 0,
		);
		const friendly = listed.filter((model) => !model.id.startsWith("/"));
		const chosen = friendly.length > 0 ? friendly : listed;
		return {
			errors: [],
			models: chosen.map((model) => {
				const n = model.meta?.n_ctx;
				const contextWindow = typeof n === "number" && n > 0 ? n : 8192;
				return toModel(model.id, port, contextWindow);
			}),
		};
	} catch (error) {
		const message = failure(error, port);
		return { models: [], errors: message ? [message] : [] };
	}
}

async function discover(): Promise<ProbeResult> {
	const found = await Promise.all(
		Array.from({ length: PORT_COUNT }, (_, index) => modelsOnPort(FIRST_PORT + index)),
	);
	return {
		models: found.flatMap((entry) => entry.models),
		errors: found.flatMap((entry) => entry.errors),
	};
}

export default async function (pi: {
	registerProvider: (id: string, config: Record<string, unknown>) => void;
	on: (
		event: "session_start",
		handler: (event: unknown, ctx: { ui: { notify: (message: string, level?: "info" | "warning" | "error") => void } }) => void,
	) => void;
}) {
	let current = await discover();

	const config: Record<string, unknown> = {
		name: "llmserve",
		api: "openai-completions",
		apiKey: "local",
		authHeader: false,
		async refreshModels() {
			const next = await discover();
			if (next.models.length > 0) {
				current = next;
				return next.models;
			}
			if (next.errors.length > 0) throw new Error(`llmserve probe failed (${next.errors[0]})`);
			current = next;
			return current.models;
		},
	};
	if (current.models.length > 0) config.models = current.models;
	pi.registerProvider("llmserve", config);

	pi.on("session_start", (_event, ctx) => {
		if (current.models.length > 0) return;
		const detail = current.errors[0] ?? `no llmserve server answered on ${FIRST_PORT}–${FIRST_PORT + PORT_COUNT - 1}`;
		ctx.ui.notify(detail, "warning");
	});
}
