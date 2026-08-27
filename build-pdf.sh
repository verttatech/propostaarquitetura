#!/usr/bin/env bash
# Gera proposta-29400-sem-ia.pdf a partir do HTML de mesmo nome.
# O HTML define folhas A4 explícitas (.capa e .pagina), então a quebra de página
# é decidida no documento e não pelo navegador.
# Uso:  bash build-pdf.sh
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGEM="$RAIZ/proposta-29400-sem-ia.html"
DESTINO="$RAIZ/proposta-29400-sem-ia.pdf"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

[ -f "$ORIGEM" ]  || { echo "erro: não encontrei $ORIGEM"; exit 1; }
[ -x "$CHROME" ]  || { echo "erro: Google Chrome não encontrado em $CHROME"; exit 1; }

rm -f "$DESTINO"
"$CHROME" --headless --disable-gpu --no-sandbox --no-pdf-header-footer \
          --virtual-time-budget=6000 --print-to-pdf="$DESTINO" "file://$ORIGEM" 2>/dev/null

PAGINAS=$(python3 -c "
import re,sys
d=open('$DESTINO','rb').read()
print(len(re.findall(rb'/Type\s*/Page[^s]', d)))
")
ESPERADO=$(grep -c 'class="pagina"\|class="capa"' "$ORIGEM")

echo "PDF gerado: $(du -h "$DESTINO" | cut -f1), $PAGINAS páginas"
if [ "$PAGINAS" != "$ESPERADO" ]; then
  echo "ATENÇÃO: o HTML define $ESPERADO folhas mas o PDF saiu com $PAGINAS."
  echo "Alguma página transbordou — encurte o conteúdo dela antes de enviar."
  exit 1
fi
echo "Alinhamento conferido: cada folha do HTML virou uma página do PDF."
