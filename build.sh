#!/usr/bin/env bash
# Regenera index.html (autocontido) a partir de orcamento-toda.html.
# Uso:  bash build.sh     (a partir da raiz do repositório)
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGEM="$RAIZ/orcamento-toda.html"
DESTINO="$RAIZ/index.html"

[ -f "$ORIGEM" ] || { echo "erro: não encontrei $ORIGEM"; exit 1; }

# Divide o arquivo no fim do bloco <style>: o que vem antes vai para o <head>.
FIM_STYLE="$(grep -n '^</style>' "$ORIGEM" | head -1 | cut -d: -f1)"
[ -n "$FIM_STYLE" ] || { echo "erro: não encontrei </style> em $ORIGEM"; exit 1; }

{
  cat <<'HEAD'
<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="description" content="Monte o seu TODA: escolha as telas que quer agora e veja o investimento na hora. Proposta da verttatech para a Todaka.">
<meta name="author" content="verttatech">

<!-- Proposta comercial: nao deve aparecer em buscadores -->
<meta name="robots" content="noindex, nofollow">

<!-- Previa ao compartilhar no WhatsApp, LinkedIn, etc. -->
<meta property="og:type" content="website">
<meta property="og:site_name" content="verttatech">
<meta property="og:title" content="TODA - Monte o seu orcamento">
<meta property="og:description" content="Marque as telas que voce quer agora e veja o valor, o prazo e as parcelas na hora.">
<meta property="og:locale" content="pt_BR">
<meta name="twitter:card" content="summary">

<meta name="theme-color" content="#C9A94F">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Crect width='32' height='32' fill='%23C9A94F'/%3E%3Cpath d='M6 7l10 18L26 7l-6 0-4 8-4-8z' fill='%2317181A'/%3E%3C/svg%3E">
HEAD
  sed -n "1,${FIM_STYLE}p" "$ORIGEM"
  printf '</head>\n<body>\n'
  sed -n "$((FIM_STYLE + 1)),\$p" "$ORIGEM"
  printf '</body>\n</html>\n'
} > "$DESTINO"

echo "index.html regerado: $(wc -l < "$DESTINO") linhas, $(du -h "$DESTINO" | cut -f1)"
