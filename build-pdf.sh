#!/usr/bin/env bash
# Gera os PDFs a partir dos HTML de mesmo nome.
# Cada HTML define folhas A4 explícitas (.capa e .pagina), então a quebra de
# página é decidida no documento e não pelo navegador. O script confere isso:
# se o PDF sair com mais páginas do que o HTML define, alguma folha transbordou.
# Uso:  bash build-pdf.sh
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || { echo "erro: Google Chrome não encontrado em $CHROME"; exit 1; }

DOCS=(proposta-implantacao o-que-acrescenta)
FALHOU=0

for D in "${DOCS[@]}"; do
  ORIGEM="$RAIZ/$D.html"
  DESTINO="$RAIZ/$D.pdf"
  [ -f "$ORIGEM" ] || { echo "erro: não encontrei $ORIGEM"; exit 1; }

  rm -f "$DESTINO"
  "$CHROME" --headless --disable-gpu --no-sandbox --no-pdf-header-footer \
            --virtual-time-budget=6000 --print-to-pdf="$DESTINO" "file://$ORIGEM" 2>/dev/null

  PAGINAS=$(python3 -c "
import re
d=open('$DESTINO','rb').read()
print(len(re.findall(rb'/Type\s*/Page[^s]', d)))")
  ESPERADO=$(grep -c 'class="pagina"\|class="capa"' "$ORIGEM")

  printf "%-26s %s, %s páginas" "$D.pdf" "$(du -h "$DESTINO" | cut -f1)" "$PAGINAS"
  if [ "$PAGINAS" != "$ESPERADO" ]; then
    printf "  ← ATENÇÃO: o HTML define %s folhas\n" "$ESPERADO"
    FALHOU=1
  else
    printf "  ✓ alinhado\n"
  fi
done

[ "$FALHOU" = 0 ] || { echo; echo "Alguma folha transbordou — encurte o conteúdo antes de enviar."; exit 1; }
