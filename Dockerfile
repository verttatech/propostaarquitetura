# TODA — proposta comercial (site estático)
FROM nginx:1.27-alpine

# Remove a página padrão do nginx
RUN rm -rf /usr/share/nginx/html/*

COPY nginx.conf   /etc/nginx/conf.d/default.conf
COPY index.html   /usr/share/nginx/html/index.html
COPY robots.txt   /usr/share/nginx/html/robots.txt
COPY proposta-implantacao.pdf /usr/share/nginx/html/proposta-implantacao.pdf
COPY o-que-acrescenta.pdf      /usr/share/nginx/html/o-que-acrescenta.pdf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://127.0.0.1/ >/dev/null 2>&1 || exit 1

CMD ["nginx", "-g", "daemon off;"]
