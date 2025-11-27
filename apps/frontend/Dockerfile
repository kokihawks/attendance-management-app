FROM node:20-bookworm

ENV PNPM_HOME=/home/node/.local/share/pnpm
ENV PATH=${PNPM_HOME}:${PATH}
ENV NODE_ENV=development

RUN corepack enable

WORKDIR /workspace/apps/frontend

USER node

CMD ["pnpm", "dev", "--host", "0.0.0.0", "--port", "3000"]



