// consultar-nfce/index.ts
// Supabase Edge Function — consulta NFC-e na SEFAZ estadual e retorna dados estruturados.
// Recebe: { url: string }  — URL bruta do QR code da NFC-e
// Retorna: NfceResult (JSON)

import {
  DOMParser,
  Element,
} from "https://deno.land/x/deno_dom@v0.1.46/deno-dom-wasm.ts";

// ---------------------------------------------------------------------------
// CORS
// ---------------------------------------------------------------------------
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------
interface NfceEstabelecimento {
  cnpj: string;
  nome: string;
  endereco: string;
  cidade: string | null;
  estado: string | null;
  latitude: number | null;
  longitude: number | null;
}

interface NfceItem {
  nome: string;
  ean: string | null;
  quantidade: number;
  precoUnitario: number;
  precoTotal: number;
}

interface NfceResult {
  chave: string;
  estabelecimento: NfceEstabelecimento;
  itens: NfceItem[];
  total: number;
  dataCompra: string; // ISO-8601
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const qrUrl: string = body?.url ?? "";

    if (!qrUrl) {
      return Response.json(
        { error: "Campo 'url' obrigatório" },
        { status: 400, headers: corsHeaders },
      );
    }

    // 1. Extrai chave de 44 dígitos da URL do QR code
    const chave = extractChave(qrUrl);

    // 2. Busca HTML na SEFAZ
    const html = await fetchSefaz(qrUrl);

    // 3. Parseia HTML → dados estruturados
    const result = parseSefazHtml(html, chave);

    // 4. Geocodifica endereço (falha silenciosa — não bloqueia a resposta)
    if (result.estabelecimento.endereco) {
      try {
        const coords = await geocode(
          result.estabelecimento.endereco,
          result.estabelecimento.cidade,
          result.estabelecimento.estado,
        );
        result.estabelecimento.latitude = coords.lat;
        result.estabelecimento.longitude = coords.lon;
      } catch {
        // geocoding é opcional
      }
    }

    return Response.json(result, { headers: corsHeaders });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.error("[consultar-nfce] error:", message);
    return Response.json(
      { error: message },
      { status: 500, headers: corsHeaders },
    );
  }
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Extrai a chave de acesso de 44 dígitos da URL do QR code.
 * Padrão nacional: ?p=CHAVE44|versao|...|hash
 * Alguns estados: chNFe=CHAVE44
 */
function extractChave(url: string): string {
  const patterns = [
    /[?&]p=([0-9]{44})/,
    /chNFe=([0-9]{44})/,
    /([0-9]{44})/,
  ];
  for (const pattern of patterns) {
    const m = url.match(pattern);
    if (m) return m[1];
  }
  throw new Error(
    "Chave NFC-e de 44 dígitos não encontrada na URL: " + url,
  );
}

async function fetchSefaz(url: string): Promise<string> {
  const resp = await fetch(url, {
    headers: {
      "User-Agent":
        "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 " +
        "(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36",
      Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Language": "pt-BR,pt;q=0.9",
    },
    signal: AbortSignal.timeout(20_000),
  });

  if (!resp.ok) {
    throw new Error(
      `SEFAZ retornou status ${resp.status} para URL: ${url}`,
    );
  }

  return await resp.text();
}

// ---------------------------------------------------------------------------
// HTML Parser — multi-estado
// ---------------------------------------------------------------------------
function parseSefazHtml(html: string, chave: string): NfceResult {
  const doc = new DOMParser().parseFromString(html, "text/html");
  if (!doc) throw new Error("Falha ao parsear HTML da SEFAZ");

  const cnpj = extractCnpj(doc, html);
  const nome = extractNome(doc, html);
  const { endereco, cidade, estado } = extractEndereco(doc, html);
  const itens = extractItens(doc, html);
  const total = extractTotal(doc, html);
  const dataCompra = extractDataCompra(doc, html);

  return {
    chave,
    estabelecimento: {
      cnpj,
      nome,
      endereco,
      cidade,
      estado,
      latitude: null,
      longitude: null,
    },
    itens,
    total,
    dataCompra,
  };
}

// --- CNPJ ---------------------------------------------------------------
function extractCnpj(
  doc: ReturnType<DOMParser["parseFromString"]>,
  html: string,
): string {
  // 1. Busca no texto de qualquer elemento com "CNPJ"
  const cnpjRegex = /[0-9]{2}\.?[0-9]{3}\.?[0-9]{3}\/[0-9]{4}-[0-9]{2}/;

  // Via DOM — elementos que contenham "CNPJ"
  const allText = doc?.querySelectorAll("*") ?? [];
  for (const el of allText) {
    const t = (el as Element).textContent ?? "";
    if (t.includes("CNPJ") || cnpjRegex.test(t)) {
      const m = t.match(cnpjRegex);
      if (m) return m[0];
    }
  }

  // Fallback — regex direto no HTML
  const m = html.match(cnpjRegex);
  return m ? m[0] : "";
}

// --- Nome ---------------------------------------------------------------
function extractNome(
  doc: ReturnType<DOMParser["parseFromString"]>,
  html: string,
): string {
  // Seletores comuns nos portais SEFAZ estaduais
  const selectors = [
    ".txtTopo",
    "#u20 .txtTopo",
    "#u20 b",
    ".nomeEmitente",
    "#nomeEmitente",
    ".x-hidden-clip",
    "h4.text-center",
    ".razaoSocial",
  ];

  for (const sel of selectors) {
    const el = doc?.querySelector(sel);
    if (el) {
      const t = (el as Element).textContent?.trim() ?? "";
      if (t.length > 2) return t;
    }
  }

  // Fallback — primeira linha em negrito no cabeçalho
  const boldEls = doc?.querySelectorAll("b, strong") ?? [];
  for (const el of boldEls) {
    const t = (el as Element).textContent?.trim() ?? "";
    // Nome de empresa: geralmente com letras maiúsculas e comprimento razoável
    if (t.length > 5 && t.length < 200 && /[A-ZÁÉÍÓÚÃÕ]/.test(t)) {
      return t;
    }
  }

  // Regex no HTML — texto em destaque antes do CNPJ
  const m = html.match(/<[^>]*class="[^"]*txtTopo[^"]*"[^>]*>([^<]+)</i);
  if (m) return m[1].trim();

  return "Estabelecimento";
}

// --- Endereço -----------------------------------------------------------
function extractEndereco(
  doc: ReturnType<DOMParser["parseFromString"]>,
  html: string,
): { endereco: string; cidade: string | null; estado: string | null } {
  // Seletores comuns
  const selectors = [
    ".enderecoEmit",
    "#enderecoEmit",
    ".endereco",
    "#u20 .text",
    ".dadosEmitente",
  ];

  for (const sel of selectors) {
    const el = doc?.querySelector(sel);
    if (el) {
      const t = (el as Element).textContent?.trim() ?? "";
      if (t.length > 5) {
        return parseEndereco(t);
      }
    }
  }

  // Busca padrão CEP + UF: "Rua X, 123 - Cidade/UF"
  const endRegex =
    /([A-ZÀ-Ú][^\n,]{3,80}),\s*\d{1,6}[^,\n]*[-–]\s*([A-ZÀ-Ú][a-zà-ú\s]{2,40})\/([A-Z]{2})/u;
  const m = html.replace(/<[^>]+>/g, " ").match(endRegex);
  if (m) {
    return {
      endereco: m[0].trim(),
      cidade: m[2].trim(),
      estado: m[3].trim(),
    };
  }

  return { endereco: "", cidade: null, estado: null };
}

function parseEndereco(
  raw: string,
): { endereco: string; cidade: string | null; estado: string | null } {
  // Tenta extrair cidade/UF do padrão "... - Cidade/UF" ou "... Cidade - UF"
  const m =
    raw.match(/[-–]\s*([A-ZÀ-Úa-zà-ú\s]{2,40})\s*[-\/]\s*([A-Z]{2})\b/) ||
    raw.match(/\b([A-ZÀ-Úa-zà-ú\s]{2,40})\s*[/-]\s*([A-Z]{2})\s*$/) ;
  return {
    endereco: raw.replace(/\s+/g, " ").trim(),
    cidade: m ? m[1].trim() : null,
    estado: m ? m[2].trim() : null,
  };
}

// --- Itens --------------------------------------------------------------
function extractItens(
  doc: ReturnType<DOMParser["parseFromString"]>,
  html: string,
): NfceItem[] {
  // Tenta encontrar tabela de itens
  const tableSelectors = [
    "#tabResult",
    ".toItens",
    "table.table-striped",
    "#tabelaItens",
    ".itens",
  ];

  for (const sel of tableSelectors) {
    const table = doc?.querySelector(sel);
    if (table) {
      const rows = table.querySelectorAll("tbody tr, tr.odd, tr.even");
      if (rows.length > 0) {
        const items = parseItemRows(rows);
        if (items.length > 0) return items;
      }
    }
  }

  // Fallback — qualquer tabela com ≥ 4 colunas que pareça conter itens
  const tables = doc?.querySelectorAll("table") ?? [];
  for (const table of tables) {
    const rows = (table as Element).querySelectorAll("tbody tr");
    if (rows.length === 0) continue;
    const firstRow = rows[0] as Element;
    const cells = firstRow.querySelectorAll("td");
    if (cells.length >= 4) {
      const items = parseItemRows(rows);
      if (items.length > 0) return items;
    }
  }

  return [];
}

function parseItemRows(
  rows: ReturnType<Element["querySelectorAll"]>,
): NfceItem[] {
  const items: NfceItem[] = [];

  for (const row of rows) {
    const cells = (row as Element).querySelectorAll("td");
    if (cells.length < 4) continue;

    const cellTexts = Array.from(cells).map((c) =>
      (c as Element).textContent?.trim() ?? ""
    );

    // Detecta layout: [código, descrição, qtd, un, vlUnit, vlTotal]
    // ou [descrição, qtd, vlUnit, vlTotal]
    let nome = "";
    let ean: string | null = null;
    let quantidade = 1;
    let precoUnitario = 0;
    let precoTotal = 0;

    if (cellTexts.length >= 6) {
      // Layout completo: código | descrição | qtd | un | vlUnit | vlTotal
      const codigo = cellTexts[0];
      nome = cellTexts[1];
      quantidade = parseBrNumber(cellTexts[2]);
      precoUnitario = parseBrNumber(cellTexts[4]);
      precoTotal = parseBrNumber(cellTexts[5]);
      // EAN: código numérico de 8, 12 ou 13 dígitos
      if (/^[0-9]{8,14}$/.test(codigo)) ean = codigo;
    } else if (cellTexts.length >= 4) {
      // Layout reduzido: descrição | qtd | vlUnit | vlTotal
      nome = cellTexts[0];
      quantidade = parseBrNumber(cellTexts[1]);
      precoUnitario = parseBrNumber(cellTexts[2]);
      precoTotal = parseBrNumber(cellTexts[3]);
    }

    // Ignora linhas de totais ou cabeçalhos
    if (!nome || precoTotal === 0) continue;
    if (/total|subtotal|desconto|frete/i.test(nome)) continue;

    items.push({ nome, ean, quantidade, precoUnitario, precoTotal });
  }

  return items;
}

// --- Total --------------------------------------------------------------
function extractTotal(
  doc: ReturnType<DOMParser["parseFromString"]>,
  html: string,
): number {
  // Busca texto "Valor total" ou "Total" próximo a um valor
  const totalRegex =
    /(?:valor\s+total|total\s+a\s+pagar|total\s+nf)[^0-9R$]*R?\$?\s*([0-9]{1,3}(?:[.,][0-9]{3})*[.,][0-9]{2})/i;

  const plainText = html.replace(/<[^>]+>/g, " ");
  const m = plainText.match(totalRegex);
  if (m) return parseBrNumber(m[1]);

  // Seletores comuns para o total
  const selectors = [
    "#totalNota",
    ".totalNota",
    "#vNF",
    ".vNF",
    "#pTot td:last-child",
  ];
  for (const sel of selectors) {
    const el = doc?.querySelector(sel);
    if (el) {
      const t = (el as Element).textContent?.trim() ?? "";
      const v = parseBrNumber(t);
      if (v > 0) return v;
    }
  }

  return 0;
}

// --- Data da compra -----------------------------------------------------
function extractDataCompra(
  doc: ReturnType<DOMParser["parseFromString"]>,
  html: string,
): string {
  // Padrão: DD/MM/YYYY HH:MM:SS ou DD/MM/YYYY
  const dateRegex = /(\d{2})\/(\d{2})\/(\d{4})(?:\s+(\d{2}):(\d{2})(?::(\d{2}))?)?/;
  const plainText = html.replace(/<[^>]+>/g, " ");

  // Procura próximo a "emissão" ou "data"
  const contextRegex =
    /(?:emiss[aã]o|data[^:]*:)[^0-9]*(\d{2}\/\d{2}\/\d{4}[^<]*)/i;
  const ctxMatch = plainText.match(contextRegex);
  if (ctxMatch) {
    const dm = ctxMatch[1].match(dateRegex);
    if (dm) return buildIso(dm);
  }

  // Qualquer data no HTML
  const dm = plainText.match(dateRegex);
  if (dm) return buildIso(dm);

  return new Date().toISOString();
}

function buildIso(m: RegExpMatchArray): string {
  const [, dd, mm, yyyy, hh = "00", min = "00", ss = "00"] = m;
  return `${yyyy}-${mm}-${dd}T${hh}:${min}:${ss}.000-03:00`;
}

// ---------------------------------------------------------------------------
// Geocoding via Nominatim (OpenStreetMap)
// ---------------------------------------------------------------------------
async function geocode(
  endereco: string,
  cidade: string | null,
  estado: string | null,
): Promise<{ lat: number; lon: number }> {
  const query = [endereco, cidade, estado, "Brasil"]
    .filter(Boolean)
    .join(", ");

  const url =
    "https://nominatim.openstreetmap.org/search?" +
    new URLSearchParams({ q: query, format: "json", limit: "1" });

  const resp = await fetch(url, {
    headers: { "User-Agent": "comprai-app/1.0 (tiagohlatki@db1.com.br)" },
    signal: AbortSignal.timeout(8_000),
  });

  if (!resp.ok) throw new Error("Nominatim error: " + resp.status);

  const results = await resp.json();
  if (!results?.length) throw new Error("Endereço não encontrado no Nominatim");

  return {
    lat: parseFloat(results[0].lat),
    lon: parseFloat(results[0].lon),
  };
}

// ---------------------------------------------------------------------------
// Utils
// ---------------------------------------------------------------------------

/** Converte número no formato BR "1.234,56" ou "1234.56" para float */
function parseBrNumber(s: string): number {
  if (!s) return 0;
  const clean = s.replace(/[^\d.,]/g, "");
  // Formato BR: ponto como milhar, vírgula como decimal
  if (clean.includes(",")) {
    return parseFloat(clean.replace(/\./g, "").replace(",", ".")) || 0;
  }
  return parseFloat(clean) || 0;
}
