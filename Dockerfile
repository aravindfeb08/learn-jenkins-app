FROM mcr.microsoft.com/playwright:v1.62.0-jammy
RUN npm install -g netlify-cli serve
RUN install --help
RUN apt update && install jq